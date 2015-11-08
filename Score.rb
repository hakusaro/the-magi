require 'active_support'
require 'active_support/core_ext'
require 'mongo_mapper'
MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')

class Score
  include MongoMapper::Document

  key :team_id, String, :unique => true
  key :r1_score, Integer
  key :r2_score, Integer
  key :r3_score, Integer
  key :total_score, Integer
  key :division, String
  key :state, String
  key :images, Integer
  key :time, String
  key :warnings, String
  key :platinum, Boolean
  key :top3, Boolean
  key :state_rank, Integer
  key :wildcard, Boolean
  key :warned_time, Boolean
  key :warned_multi, Boolean
  key :tier, String
  key :state_finalist, Boolean
  Score.ensure_index(:team_id)
  Score.ensure_index(:state)
  Score.ensure_index(:division)
  timestamps!
end