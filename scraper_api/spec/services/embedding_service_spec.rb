require "rails_helper"

RSpec.describe EmbeddingService do
  let(:client) { instance_double(OpenAI::Client) }
  let(:service) { described_class.new(openai_client: client) }

  it "stores averaged embedding into document.embedding" do
    website = Website.create!(url: "https://example.com")
    document = website.documents.create!(content: "Sentence one. Sentence two. Sentence three.")

    fake_response = {
      "data" => [
        { "embedding" => Array.new(5, 0.1) },
        { "embedding" => Array.new(5, 0.3) }
      ]
    }

    expect(client).to receive(:embeddings).and_return(fake_response)

    service.embed_document!(document)

    expect(document.reload.embedding).to be_a(Array)
    expect(document.embedding.length).to eq(5)
    expect(document.embedding.first).to be_within(1e-6).of(0.2)
  end
end


