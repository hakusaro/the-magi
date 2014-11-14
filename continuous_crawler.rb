require_relative 'crawl'

while true
  crawl_now
  calculate_platinums
  sleep 60
end