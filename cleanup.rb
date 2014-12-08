require_relative 'Score'

Score.where({:wildcard => true, :top3 => true}).each do |score|
  score.wildcard = false
end