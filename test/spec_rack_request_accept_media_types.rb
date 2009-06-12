require 'test/spec'
require 'rack/request/accept_media_types'

require 'phocus'

Accept = Rack::Request::AcceptMediaTypes

context "Rack::Request::AcceptMediaTypes" do

  specify "parses media type into a list" do
    header = 'text/html,text/plain'
    Accept.new(header).to_set.should.equal(%w( text/html text/plain ).to_set)
  end

  specify "orders types by quality value (highest first)" do
    header = 'text/html;q=0.5,text/plain;q=0.9'
    Accept.new(header).should.equal(%w( text/plain text/html ))
  end

  specify "default quality value is 1" do
    header = 'text/plain;q=0.1,text/html'
    Accept.new(header).should.equal(%w( text/html text/plain ))
  end

  specify "equal quality types keep original order" do
    header = 'text/html,text/plain;q=0.9,application/xml'
    Accept.new(header).should.equal(%w( text/html application/xml text/plain ))
  end

  specify "selects prefered type" do
    header = 'text/html;q=0.2,text/plain;q=0.5'
    Accept.new(header).prefered.should.equal('text/plain')
  end

  specify "types with out of range quality values are ignored" do
    header = 'text/html,text/plain;q=1.1'
    Accept.new(header).should.equal(%w( text/html ))

    header = 'text/html,text/plain;q=0'
    Accept.new(header).should.equal(%w( text/html ))
  end

  specify "custom media types are NOT ignored" do
    # verifying that the media types exist in Rack::Mime::MIME_TYPES is
    # explicitly outside the scope of this library.
    header = 'application/x-custom'
    Accept.new(header).should.equal(%w( application/x-custom ))
  end

  specify "media-range parameters are discarted" do
    header = 'text/html;version=5;q=0.5,text/plain'
    Accept.new(header).should.equal(%w( text/plain text/html ))
  end

  specify "accept-extension parameters are discarted" do
    header = 'text/html;q=0.5;token=value,text/plain'
    Accept.new(header).should.equal(%w( text/plain text/html ))
  end

  specify "nil accept header means all media types accepted" do
    header = nil
    Accept.new(header).should.equal(%w( */* ))
  end

  specify "empty accept header results in empty list" do
    header = ''
    Accept.new(header).should.equal([])
  end

  specify "all accepted types being invalid results in empty list" do
    header = 'text/html;q=2,application/xml;q=0'
    Accept.new(header).should.equal([])
  end
end

__END__
http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
14.1 Accept

  Accept         = "Accept" ":"
                  #( media-range [ accept-params ] )

  media-range    = ( "*/*"
                  | ( type "/" "*" )
                  | ( type "/" subtype )
                  ) *( ";" parameter )
  accept-params  = ";" "q" "=" qvalue *( accept-extension )
  accept-extension = ";" token [ "=" ( token | quoted-string ) ]

http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.9
3.9 Quality Values

  qvalue = ( "0" [ "." 0*3DIGIT ] )
         | ( "1" [ "." 0*3("0") ] )
