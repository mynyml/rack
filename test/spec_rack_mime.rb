require 'test/spec'
require 'rack/mime'

Type = Rack::Mime::MimeType

context "Rack::Mime" do
  context "MimeType" do

    specify "parses media-range" do
      type = Type.new('text/plain;q=0.6;k=v')
      type.range.should.equal('text/plain')
    end

    specify "parses quality" do
      Type.new('text/html;q=0.5').quality.should.equal(0.5)
    end

    specify "default quality is 1" do
      Type.new('text/html').quality.should.equal(1.0)
    end

    specify "parses media-range parameters" do
      Type.new('text/html;a=b;x=y').params.should.equal(
        {'a' => 'b', 'x' => 'y'}
      )
    end

    specify "quality is not in parameter list" do
      Type.new('text/html;q=0.8;a=b;x=y').params.should.equal(
        {'a' => 'b', 'x' => 'y'}
      )
    end

    context "Validity" do

      specify "types with out of range quality values are invalid" do
        Type.new('text/plain;q=0.001' ).should.be.valid
        Type.new('text/plain;q=1.000' ).should.be.valid
        Type.new('text/plain;q=0.0009').should.not.be.valid
        Type.new('text/plain;q=1.0001').should.not.be.valid
      end

      specify "custom media types are NOT invalid" do
        # verifying that the media types exist in Rack::Mime::MIME_TYPES is
        # explicitly outside the scope of this library.
        Type.new('application/x-custom').should.be.valid
      end
    end

    context "Ordering" do

      specify "by quality" do
        a = Type.new('text/html;q=0.9')
        b = Type.new('text/plain;q=0.8')
        a.should.be > b
      end

      specify "by specificity when quality is equal" do
        a = Type.new('text/html')
        b = Type.new('*/*')
        a.should.be > b

        a = Type.new('text/html')
        b = Type.new('application/*')
        a.should.be > b

        a = Type.new('text/*')
        b = Type.new('*/*')
        a.should.be > b

        a = Type.new('text/html;k=v')
        b = Type.new('application/json')
        a.should.be > b

        a = Type.new('text/html;a=b;x=y')
        b = Type.new('application/xml;k=v')
        a.should.be > b

        a = Type.new('text/*;k=v')
        b = Type.new('application/*')
        a.should.be > b

        a = Type.new('text/html')
        b = Type.new('application/*;k=v')
        a.should.be > b
      end
    end
  end
end
