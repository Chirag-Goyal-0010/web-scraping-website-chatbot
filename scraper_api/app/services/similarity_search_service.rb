class SimilaritySearchService
	# Executes a similarity search against the documents table using the pgvector <-> operator.
	# Returns an array of Document records ordered by ascending distance (nearest first).
	#
	# Parameters:
	# - query_embedding: Pgvector::Vector or Array of Float matching dimension (1536)
	# - limit: Integer limit on number of results (default 5)
	def self.search(query_embedding:, limit: 5)
		vector =
			if defined?(Pgvector::Vector) && query_embedding.is_a?(Pgvector::Vector)
				query_embedding
			elsif query_embedding.is_a?(Array)
				Pgvector::Vector.new(query_embedding)
			else
				raise ArgumentError, 'query_embedding must be Pgvector::Vector or Array'
			end

		# Ensure vector literal format: '[1,2,3]'
		vector_literal = "[#{vector.to_a.join(',')}]"

		Document.order(Arel.sql("embedding <-> '#{vector_literal}'"))
			.limit(limit)
	end
end
