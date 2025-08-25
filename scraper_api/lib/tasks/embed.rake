namespace :embed do
  desc "Embed all documents lacking embeddings"
  task documents: :environment do
    service = EmbeddingService.new
    scope = Document.where(embedding: nil)
    puts "Embedding #{scope.count} document(s)..."
    scope.find_each(batch_size: 50) do |doc|
      begin
        service.embed_document!(doc)
        puts "Embedded document ##{doc.id}"
      rescue => e
        warn "Failed to embed document ##{doc.id}: #{e.class} #{e.message}"
      end
    end
  end
end


