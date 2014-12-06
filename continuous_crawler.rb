require_relative 'crawl'

while true
  unless crawl_now == nil
  	calculate_state_rank
  end
  sleep 60
end