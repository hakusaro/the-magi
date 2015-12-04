require_relative 'Score'

# Score.where({:wildcard => true, :top3 => true}).each do |score|
#   score.wildcard = false
#   score.save
# end

Score.all.each do |score|
  score.time = ""
  score.warnings = ""
  score.save
end