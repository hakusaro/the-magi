require 'nokogiri'
require 'open-uri'
require 'pry'
require 'mongo_mapper'
require_relative 'Score'
MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')

@document = Nokogiri::HTML(open("http://54.243.195.23/"))
@nodeset = @document.css("tr.clickable") # @document.xpath("//tr")

@nodeset.each do |row|
  puts "GETTING A TEAM SCORE"
  team_score = {
    :id => row.children[0].children[0], 
    :division => row.children[1].children[0], 
    :state => row.children[2].children[0],
    :images => row.children[3].children[0],
    :time => row.children[4].children[0],
    :score => row.children[5].children[0],
    :warnings => row.children[6].children[0]
  }
  puts "Team is #{team_score[:id]}. They're at #{team_score[:score]} in #{team_score[:state]}'s #{team_score[:division]} division."

end

# binding.pry

