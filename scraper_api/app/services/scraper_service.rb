class ScraperService
  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36".freeze
  OPEN_TIMEOUT_SECONDS = 10
  READ_TIMEOUT_SECONDS = 20

  def initialize(url)
    @url = url
  end

  def call
    response = fetch_url(@url)
    return { content: nil, skipped: true, reason: :request_failed } unless response

    return { content: nil, skipped: true, reason: :non_html } unless html_response?(response)

    html = response.body
    text = extract_visible_text(html)
    return { content: nil, skipped: true, reason: :empty_text } if text.strip.empty?

    { content: text, skipped: false }
  rescue StandardError
    { content: nil, skipped: true, reason: :unexpected_error }
  end

  private

  def fetch_url(url)
    HTTParty.get(
      url,
      headers: { "User-Agent" => USER_AGENT, "Accept" => "text/html,application/xhtml+xml" },
      timeout: OPEN_TIMEOUT_SECONDS + READ_TIMEOUT_SECONDS,
      follow_redirects: true,
    )
  rescue Net::OpenTimeout, Net::ReadTimeout, HTTParty::Error, SocketError
    nil
  end

  def html_response?(response)
    return false unless response&.code.to_i.between?(200, 299)

    content_type = response.headers["content-type"] || response.headers["Content-Type"]
    return false unless content_type

    content_type.downcase.include?("text/html")
  end

  def extract_visible_text(html)
    document = Nokogiri::HTML(html)

    # Remove non-content elements
    document.search("script, style, noscript, svg, canvas, iframe, nav, header, footer, form, aside").remove
    # Remove common UI containers
    document.search("[role='navigation'], [role='banner'], [role='contentinfo']").remove

    # Get text from body
    body = document.at("body") || document
    text = body.inner_text

    # Normalize whitespace
    normalized = text.split(/\n|\r/)
                    .map { |line| line.gsub(/\s+/, " ").strip }
                    .reject(&:empty?)
                    .join("\n")

    normalized
  end
end


