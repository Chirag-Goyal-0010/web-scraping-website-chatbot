namespace :scrape do
  desc "Scrape a single URL and store raw text into documents (usage: rake scrape:url[\"https://example.com\"])"
  task :url, [:target_url] => :environment do |_t, args|
    url = args[:target_url]
    unless url
      puts "Missing URL. Usage: rake scrape:url[\"https://example.com\"]"
      exit 1
    end

    service = ScraperService.new(url)
    result = service.call

    if result[:skipped]
      puts "Skipped: #{url} (reason: #{result[:reason]})"
      next
    end

    website = Website.find_or_create_by!(url: url)
    document = website.documents.create!(content: result[:content])
    website.update!(scraped_at: Time.current)

    puts "Stored document ##{document.id} for website ##{website.id}"
  end
end


