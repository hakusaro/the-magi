require 'nokogiri'
require 'open-uri'
require 'pry'
require 'mongo_mapper'
require_relative 'Score'
MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')

@document = Nokogiri::HTML(open("http://54.243.195.23/"))
@nodeset = @document.css("tr.clickable") # @document.xpath("//tr")

@nodeset.each do |row|
  if row.children[0].children[0].to_s == "CPOC"
    next
  end
  team_score = {
    :id => row.children[0].children[0].to_s, 
    :division => row.children[1].children[0].to_s, 
    :state => row.children[2].children[0].to_s,
    :images => row.children[3].children[0].to_s.to_i,
    :time => row.children[4].children[0].to_s,
    :score => row.children[5].children[0].to_s.to_i,
    :warnings => row.children[6].children[0].to_s
  }
  score = Score.where({:team_id => team_score[:id]}).first
  if (score == nil)
    team_score[:division] = team_score[:division].downcase.include?('open') ? 'open' : 'all-service'
    new_score = Score.new({
      :team_id => team_score[:id],
      :division => team_score[:division],
      :r1_score => nil,
      :r2_score => team_score[:score],
      :time => team_score[:time],
      :warnings => team_score[:warnings],
      :images => team_score[:images],
      :state => team_score[:state]
    })
    if new_score.save
      puts "Created a new team #{team_score[:id]} in #{team_score[:division]}."
    else
      puts "Failed to create new team #{team_score[:id]}"
    end
  else
    score.state = team_score[:state]
    score.images = team_score[:images]
    score.time = team_score[:time]
    score.r2_score = team_score[:score]
    score.warnings = team_score[:warnings]
    if (score.save)
      # puts "Team is #{team_score[:id]}. They're at #{team_score[:score]} in #{team_score[:state]}'s #{team_score[:division]} division."
    else
      puts "Failed to save #{team_score[:id]}."
    end
  end

end

# binding.pry

