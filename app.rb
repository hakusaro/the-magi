require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require_relative 'Score'

class Magi < Sinatra::Base

  get '/rhs/?' do
    redirect to('/teams/08-0001,08-0002,08-0003,08-0004,08-0005')
  end

  get '/all/?' do
    score_count = Score.all.count

    scores = Score.sort(:r1_score.desc)

    plat_slots = 0
    last_update = Score.where({:team_id => "CPOC"}).first.updated_at
    erb :div_platinum, :locals => {:last_update => last_update, :plat_slots => plat_slots, :scores => scores, :teams => score_count, :division => "N/A", :state => params[:state]}
  end

  get '/:division/?' do
    unless params[:division] == 'all-service' || params[:division] == 'open' || params[:division] == 'ms'
      return erb :error, :locals => {:error => "Invalid division specified. Must either be 'open', 'middle', or 'all-service'."}
    end

    score_count = Score.where({:division => params[:division]}).count

    scores = Score.where({:division => params[:division]}).sort(:r1_score.desc)

    plat_slots = (score_count * 0.3).round(0)
    mst50_slots = (score_count * 0.5).round(0)
    last_update = Score.where({:team_id => "CPOC"}).first.updated_at

    erb :div_platinum, :locals => {:last_update => last_update, :plat_slots => plat_slots, :mst50_slots => mst50_slots, :scores => scores, :teams => score_count, :division => params[:division], :state => params[:state]}
  end


  get '/' do
    erb :select_division
  end

  configure do
    MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
  end

  get '/team/:teamid/?' do
    scores = Score.where({:team_id => params[:teamid]}).sort(:r1_score.desc)

    if scores.count == 0
      return erb :error, :locals => {:error => "Invalid team ID specified. Team must be a fully qualified ID, e.g. 07-0152."}
    end
    last_update = Score.where({:team_id => params[:teamid]}).first.updated_at
    erb :team, :locals => {:scores => scores, :division => scores.first.division, :state => scores.first.state, :last_update => last_update}
  end

  get '/teams/:teamids/?' do

    unless (params[:teamids].include?(','))
      return erb :error, :locals => {:error => "Invalid team CSV specified. Separate TeamIDs by commas."}
    end

    teams = Array.new
    params[:teamids].split(',').each do |team|
      sc = Score.where({:team_id => team}).sort(:r1_score.desc).first

      unless sc == nil
        teams.push(sc)
      end
    end

    if teams.count == 0
      return erb :error, :locals => {:error => "Invalid team IDs specified. Teams must be fully qualified, e.g. 07-0152,06-0238, etc."}
    end

    last_update = teams[0].updated_at
    erb :teams, :locals => {:teams => teams, :last_update => last_update}
  end

  get '/:state/:division/?' do
    score_count = Score.where({:division => params[:division], :state => params[:state]}).count

    if score_count == 0
      return erb :error, :locals => {:error => 'Invalid state / division combo specified. No data found.'}
    end

    teams = Score.where({:division => params[:division], :state => params[:state]}).sort(:r1_score.desc)

    erb :teams, :locals => {:teams => teams}
  end
end