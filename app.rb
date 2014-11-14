require 'sinatra'
require_relative 'Score'

class Magi < Sinatra::Base

  get '/rhs/?' do
    redirect to('/teams/07-0152,07-0327,07-1260,07-1262,07-1964,07-0158,07-0639,07-1818')
  end

  get '/:division/?' do
    unless params[:division] == 'all-service' || params[:division] == 'open'
      return erb :error, :locals => {:error => "Invalid division specified. Must either be 'open' or 'all-service'."}
    end

    score_count = Score.where({:division => params[:division]}).count

    scores = Score.where({:division => params[:division]}).sort(:total_score.desc)

    plat_slots = (score_count * 0.3).round(0)
    erb :div_platinum, :locals => {:plat_slots => plat_slots, :scores => scores, :teams => score_count, :division => params[:division], :state => params[:state]}
  end

  get '/' do
    redirect to ('/open')
  end

  configure do
    MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
  end

  get '/team/:teamid/?' do
    scores = Score.where({:team_id => params[:teamid]}).sort(:total_score.desc)

    if scores.count == 0
      return erb :error, :locals => {:error => "Invalid team ID specified. Team must be a fully qualified ID, e.g. 07-0152."}
    end

    erb :team, :locals => {:scores => scores, :division => scores.first.division, :state => scores.first.state}
  end

  get '/teams/:teamids/?' do

    unless (params[:teamids].include?(','))
      return erb :error, :locals => {:error => "Invalid team CSV specified. Separate TeamIDs by commas."}
    end

    teams = Array.new
    params[:teamids].split(',').each do |team|
      sc = Score.where({:team_id => team}).sort(:total_score.desc).first

      unless sc == nil
        teams.push(sc)
      end
    end

    if teams.count == 0
      return erb :error, :locals => {:error => "Invalid team IDs specified. Teams must be fully qualified, e.g. 07-0152,06-0238, etc."}
    end

    erb :teams, :locals => {:teams => teams}
  end
end