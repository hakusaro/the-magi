require_relative 'Score'

match_advancement = Score.where({:division => 'open', :top3 => true, :state_finalist => true}).count

total_advancement = Score.where({:division => 'open', :state_finalist => true}).count

puts "We matched #{match_advancement} advanecment slots (out of #{total_advancement} advancing slots)."
puts "%error: #{((total_advancement.to_f - match_advancement.to_f) / total_advancement.to_f * 100)}%"

promoted = Score.where({:division => 'open', :top3 => false, :wildcard => false, :state_finalist => true}).count

puts "CPOC promoted #{promoted} teams that we didn't predict."

top3_demoted = Score.where({:division => 'open', :top3 => true, :state_finalist => false}).count

demoted = top3_demoted

puts "CPOC demoted #{demoted} from our projections."
puts "CPOC demoted #{top3_demoted} top3 teams from our projections."
