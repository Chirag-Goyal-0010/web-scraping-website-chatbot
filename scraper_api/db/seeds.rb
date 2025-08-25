# Seed dummy data with random embeddings
require "securerandom"

ActiveRecord::Base.transaction do
	Website.destroy_all
	Document.destroy_all

	website = Website.create!(url: "https://example.com", scraped_at: Time.current)

	# Create 10 documents with random 1536-dim embeddings
	10.times do |i|
		content = "Dummy document ##{i + 1} - #{SecureRandom.hex(8)}"
		embedding = Array.new(1536) { rand } # uniform [0,1)
		Document.create!(website: website, content: content, embedding: embedding)
	end
end
