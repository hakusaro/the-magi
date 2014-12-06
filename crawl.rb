require 'nokogiri'
require 'open-uri'
require 'pry'
require 'mongo_mapper'
require_relative 'Score'
MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')

def crawl_now
  begin
    @document = Nokogiri::HTML(open("http://54.243.195.23/"))
  rescue
    puts "Failed to connect to CCS's live output system."
    return nil
  end
  @nodeset = @document.css("tr.clickable") # @document.xpath("//tr")

  @nodeset.each do |row|
    if row.children[0].children[0].to_s.include? "CPOC" # CPOC is the CyberPatriot Operation Center (CPOC, CPOC_gol, CPOC_pla, CPOC_sil)
      next
    end
    team_score = {
      :id => row.children[0].children[0].to_s, 
      :division => row.children[1].children[0].to_s, 
      :state => row.children[2].children[0].to_s,
      :images => row.children[4].children[0].to_s.to_i,
      :time => row.children[5].children[0].to_s,
      :score => row.children[6].children[0].to_s.to_i,
      :warnings => row.children[7].children[0].to_s,
      :tier => row.children[3].children[0].to_s
    }

    division = team_score[:division].downcase

    if division.include?('open')
      division = 'open'
    elsif division.include?('service')
      division = 'all-service'
    elsif division.include?('middle')
      division = 'ms'
    end

    score = Score.where({:team_id => team_score[:id]}).first
    if (score == nil)
      new_score = Score.new({
        :team_id => team_score[:id],
        :division => division,
        :r1_score => 0,
        :r2_score => 0,
        :r3_score => team_score[:score],
        :time => team_score[:time],
        :warnings => team_score[:warnings],
        :images => team_score[:images],
        :state => team_score[:state],
        :total_score => team_score[:score]
      })
      if new_score.save
        puts "Created a new team #{team_score[:id]} in #{team_score[:division]}."
      else
        puts "Failed to create new team #{team_score[:id]}"
      end
    else
      if score.division != division
        puts "Redefined #{score.team_id} from division #{score.division} to #{division}."
      end
      score.division = division
      score.state = team_score[:state]
      score.images = team_score[:images]
      score.time = team_score[:time]
      score.r3_score = team_score[:score]
      score.warnings = team_score[:warnings]
      score.total_score = team_score[:score]
      if (score.save)
        # puts "Team is #{team_score[:id]}. They're at #{team_score[:score]} in #{team_score[:state]}'s #{team_score[:division]} division."
      else
        puts "Failed to save #{team_score[:id]}."
      end
    end
  end
  puts "Crawl run ok."
  return true
end

def calculate_state_rank
  locations = Array.new
  divisions = ['open', 'all-serivce']
  tiers = ['Silver', 'Gold', 'Platinum']
  File.readlines('location_list.txt').each do |line|
    locations.push(line)
  end

  locations.each do |location|
    divisions.each do |division|
      tiers.each do |tier|
        score_count = Score.where({:division => division, :state => location, :tier => tier}).count

        scores = Score.where({:division => division, :state => location, :tier => tier}).sort(:r3_score.desc)

        advancement = 3
        rank = 1
        scores.each do |score|
          if advancement > 0
            score.top3 = true
          else
            score.top3 = false
          end

          score.state_rank = rank
          rank += 1

          if score.warnings != nil
            if score.warnings.include?('M')
              score.warned_multi = true
            else
              score.warned_multi = false
            end

            if score.warnings.include?('T')
              score.warned_time = true
            else
              score.warned_time = false
            end
          else
            score.warned_multi = false
            score.warned_time = false
          end

          score.save

        end
      end
    end
  end


end

def calculate_platinums

  divisions = ['open', 'all-service']

  divisions.each do |division|
    score_count = Score.where({:division => division}).count

    scores = Score.where({:division => division}).sort(:total_score.desc)

    plat_slots = (score_count * 0.3).round(0)
    plat_slots_save = plat_slots
    scores.each do |score|
      if plat_slots > 0 
        score.platinum = true
        plat_slots -= 1
      else
        score.platinum = false
      end

      if score.warnings != nil
        if score.warnings.include?('M')
          score.warned_multi = true
        else
          score.warned_multi = false
        end

        if score.warnings.include?('T')
          score.warned_time = true
        else
          score.warned_time = false
        end
      else
        score.warned_multi = false
        score.warned_time = false
      end

      score.save
    end
  end
  puts "Calculation of platinums ok."
end

# binding.pry

