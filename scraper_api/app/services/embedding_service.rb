class EmbeddingService
  DEFAULT_MODEL = "text-embedding-3-small".freeze
  MAX_TOKENS_PER_CHUNK = 800 # approximate; using characters as proxy
  MAX_RETRIES = 3

  def initialize(openai_client: nil)
    @client = openai_client || OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def embed_document!(document)
    chunks = chunk_text(document.content.to_s)
    return false if chunks.empty?

    vectors = []
    attempt_with_backoff do
      response = @client.embeddings(parameters: { model: DEFAULT_MODEL, input: chunks })
      vectors = Array(response.dig("data")).map { |d| d["embedding"] }
    end

    # For now, store the average of chunk vectors into single embedding column
    averaged = average_vectors(vectors)
    return false unless averaged

    # Persist via SQL cast to vector to avoid AR type/OID issues on Windows
    array_sql = "[#{averaged.map { |v| v.to_f }.join(',')}]"
    Document.where(id: document.id).update_all(["embedding = ?::vector", array_sql])
  end

  private

  def chunk_text(text)
    normalized = text.gsub(/\s+/, " ").strip
    return [] if normalized.empty?

    # naive char-based chunking approximates token count
    chunks = []
    current = ""
    normalized.split(/(?<=[\.!?])\s+/).each do |sentence|
      if (current.length + sentence.length + 1) > (MAX_TOKENS_PER_CHUNK * 4) # ~4 chars/token heuristic
        chunks << current.strip unless current.strip.empty?
        current = sentence
      else
        current = current.empty? ? sentence : (current + " " + sentence)
      end
    end
    chunks << current.strip unless current.strip.empty?
    chunks
  end

  def attempt_with_backoff
    retries = 0
    begin
      yield
    rescue OpenAI::Error, Faraday::TimeoutError, Faraday::ConnectionFailed => e
      retries += 1
      raise e if retries > MAX_RETRIES
      sleep(2 ** retries)
      retry
    end
  end

  def average_vectors(vectors)
    return nil if vectors.empty?
    length = vectors.first.length
    sums = Array.new(length, 0.0)
    vectors.each do |vec|
      next unless vec && vec.length == length
      vec.each_with_index { |v, i| sums[i] += v.to_f }
    end
    sums.map { |s| s / vectors.length }
  end
end


