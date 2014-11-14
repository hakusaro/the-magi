require 'sinatra'
require_relative 'Score'

class Magi < Sinatra::Base
  get '/:state/:division/?' do

    unless params[:division] == 'all-service' || params[:division] == 'open'
      return erb :error, :locals => {:error => "Invalid division specified. Must either be 'open' or 'all-service'."}
    end

    score_count = Score.where({:state => params[:state], :division => params[:division]}).count

    unless score_count > 0
      return erb :error, :locals => {:error => "That state is either invalid, or no teams from that state's #{params[:division]} division have competed in this round yet."}
    end

    scores = Score.where({:state => params[:state], :division => params[:division]}).sort(:total_score.desc)

    plat_slots = (score_count * 0.3).round(0)
    plat_slots_save = plat_slots
    scores.each do |score|
      if plat_slots > 0 
        score.platinum = true
        plat_slots -= 1
      else
        score.platinum = false
      end
      score.save
    end
    puts "Returning #{score_count}."
    erb :state_platinum, :locals => {:plat_slots => plat_slots_save, :scores => scores, :teams => score_count, :division => params[:division], :state => params[:state]}
  end

  get '/:division/?' do
    unless params[:division] == 'all-service' || params[:division] == 'open'
      return erb :error, :locals => {:error => "Invalid division specified. Must either be 'open' or 'all-service'."}
    end

    score_count = Score.where({:division => params[:division]}).count

    scores = Score.where({:division => params[:division]}).sort(:total_score.desc)

    plat_slots = (score_count * 0.3).round(0)
    plat_slots_save = plat_slots
    scores.each do |score|
      if plat_slots > 0 
        score.platinum = true
        plat_slots -= 1
      else
        score.platinum = false
      end
      score.save
    end
    erb :div_platinum, :locals => {:plat_slots => plat_slots_save, :scores => scores, :teams => score_count, :division => params[:division], :state => params[:state]}
  end

  get '/' do
    redirect to ('/open')
  end

  configure do
    MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
  end
end