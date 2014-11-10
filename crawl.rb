require 'nokogiri'
require 'open-uri'
require 'pry'

@document = Nokogiri::HTML(open("http://54.243.195.23/"))
@nodeset = @document.css("tr.clickable") # @document.xpath("//tr")

@nodeset.each do |row|
  puts "GETTING A TEAM SCORE"
  row.children.each do |cr|
    puts "#{cr.children[0].to_s}"
    
  end
end

# binding.pry