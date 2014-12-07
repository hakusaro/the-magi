require_relative 'Score'

projected_plat = Score.where({:division => 'open', :platinum => true}).count
actual_plat = Score.where({:division => 'open', :tier => 'Platinum'}).count
open_total = Score.where({:division => 'open'}).count

puts "We projected #{projected_plat} slots, but actually have #{actual_plat} slots."
puts "Actual % of total: #{actual_plat.to_f / open_total.to_f * 100}."

match_plat = Score.where({:division => 'open', :platinum => true, :tier => 'Platinum'}).count

puts "We matched #{match_plat} platinum slots."

promoted = Score.where({:division => 'open', :platinum => false, :tier => 'Platinum'}).count

puts "CPOC promoted #{promoted} teams into platinum that we didn't predict."

demoted = Score.where({:division => 'open', :platinum => true, :tier => 'Gold'}).count +
  Score.where({:division => 'open', :platinum => true, :tier => 'Silver'}).count

far_demoted = Score.where({:division => 'open', :platinum => true, :tier => 'Silver'}).count

puts "CPOC demoted #{demoted} from our projections to gold or silver (#{demoted - far_demoted} to gold)."
puts "CPOC demoted #{far_demoted} from our projected platinums to silver!"