require 'mongo_mapper'
MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')

class Score
  include MongoMapper::Document

  key :team_id, String, :unique => true
  key :r1_score, Integer
  key :r2_score, Integer
  key :division, String
  key :state, String
  key :images, Integer
  key :time, String
  key :warnings, String

  Score.ensure_index(:team_id)
  Score.ensure_index(:state)
  Score.ensure_index(:division)
  timestamps!
end