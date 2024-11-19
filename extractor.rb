require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

# Blunt instrument for seeding

API_URL = 'https://en.wikipedia.org/w/api.php'

def fetch_wiki_articles
  uri = URI(API_URL)
  params = {
    action: 'parse',
    page: 'Wikipedia:Unusual_articles',
    format: 'json',
    prop: 'text',
  }
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  html_content = data.dig('parse', 'text', '*')
  html_content
end

def extract_wiki_links(html_content)
  doc = Nokogiri::HTML(html_content)
  
  # Wikipedia standardised formatting FTW -- find all links inside <b> tags within table cells 
  links = doc.css('td b a').map do |link| 
    title = link.text.strip
    href = link['href']
    puts link

    # Only include links to other Wikipedia articles
    if href&.start_with?('/wiki/') && !href.include?(':')
      { title: title, href: "https://en.wikipedia.org#{href}" }
    end
  end

  links.compact # Filter out nil entries
end

def wiki_main
  html_content = fetch_wiki_articles
  articles = extract_wiki_links(html_content)
  result = { count: articles.size, articles: articles }
  File.open('articles.json', 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end
end


def extract_misc_links
  url = 'https://endwalker.com/archive.html'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  doc = Nokogiri::HTML(response)
  result = doc.css('a').select { |a_tag| a_tag.at('b') }.map.with_index do |a_tag, index|
    {
      text: a_tag.at('b').text.strip,
      link: a_tag['href'],
      order: index + 1
    }
  end
  result.sort_by! { |entry| entry[:order] }
  File.open('misc_articles.json', 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end
end

# extract_misc_links
# wiki_main
