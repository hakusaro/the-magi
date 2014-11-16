require_relative 'crawl'

while true
  unless crawl_now == nil
  	calculate_platinums
  end
  sleep 60
end