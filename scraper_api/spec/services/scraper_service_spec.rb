require "rails_helper"

RSpec.describe ScraperService do
  describe "#call" do
    let(:html_page) do
      <<~HTML
        <html>
          <head>
            <title>Example</title>
            <style>.hidden{display:none}</style>
            <script>console.log('ignore');</script>
          </head>
          <body>
            <header>Site Header</header>
            <nav>Navigation</nav>
            <main>
              <h1>Hello World</h1>
              <p>This is a test page.</p>
              <script>var a = 1;</script>
              <style>p { color: red; }</style>
            </main>
            <footer>Footer</footer>
          </body>
        </html>
      HTML
    end

    it "extracts visible text and skips scripts/styles/navs" do
      allow(HTTParty).to receive(:get).and_return(
        instance_double("Response", code: 200, body: html_page, headers: { "content-type" => "text/html; charset=utf-8" })
      )

      result = described_class.new("https://example.com").call
      expect(result[:skipped]).to be(false)
      expect(result[:content]).to include("Hello World")
      expect(result[:content]).to include("This is a test page.")
      expect(result[:content]).not_to include("Navigation")
      expect(result[:content]).not_to include("console.log")
      expect(result[:content]).not_to include("color: red")
    end

    it "skips non-HTML content" do
      allow(HTTParty).to receive(:get).and_return(
        instance_double("Response", code: 200, body: "%PDF-1.4...", headers: { "content-type" => "application/pdf" })
      )

      result = described_class.new("https://example.com/file.pdf").call
      expect(result[:skipped]).to be(true)
      expect(result[:reason]).to eq(:non_html)
    end

    it "handles timeout errors" do
      allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)

      result = described_class.new("https://slow.example.com").call
      expect(result[:skipped]).to be(true)
      expect(result[:reason]).to eq(:request_failed)
    end
  end
end


