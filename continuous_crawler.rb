require 'benchmark'
require_relative 'crawl'

class Crawler
  def crawl
    while true
      @@recalculate = false
      puts Benchmark.measure { @@recalculate = crawl_now }
      if @@recalculate == true
        puts Benchmark.measure { calculate_state_rank }
      end
      recalculate = false
      sleep 60
    end
  end
end

Crawler.new.crawl