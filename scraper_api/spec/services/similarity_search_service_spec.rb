require 'rails_helper'

RSpec.describe SimilaritySearchService, type: :service do
	let!(:website) { Website.create!(url: 'https://example.com') }

	def insert_doc!(content:, vector:)
		vector_literal = "[#{vector.join(',')}]"
		ActiveRecord::Base.connection.execute(<<~SQL)
			INSERT INTO documents (website_id, content, embedding, created_at, updated_at)
			VALUES (#{website.id}, '#{content.gsub("'", "''")}', '#{vector_literal}', NOW(), NOW());
		SQL
		Document.order(:id).last
	end

	let!(:doc_a) { insert_doc!(content: 'A', vector: Array.new(1536, 0.0)) }
	let!(:doc_b) { insert_doc!(content: 'B', vector: Array.new(1536, 0.5)) }
	let!(:doc_c) { insert_doc!(content: 'C', vector: Array.new(1536, 1.0)) }

	it 'orders by distance using <-> operator and returns nearest first' do
		query = Array.new(1536, 0.49)
		results = SimilaritySearchService.search(query_embedding: query, limit: 3)
		expect(results.length).to eq(3)
		expect(results.first.id).to eq(doc_b.id)
	end
end
