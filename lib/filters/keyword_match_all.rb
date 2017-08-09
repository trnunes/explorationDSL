module Filtering
  class KeywordMatchAll < Filtering::Filter
    def initialize(*args)
      raise "Invalid number of arguments #{args.size} for 1" if args.size != 1
      @keyword_pattern = args.first
    end
    
    def prepare(items, server, args)
      binding.pry
      input_set = args[:input]
      if input_set.root?
        @filtered_items = server.match_all(@keyword_pattern, args[:out_offset] || 0, args[:out_limit] || 0)
      else
        @filtered_items = Set.new
        keep_item = false
      
        items.each do |item|
          keep_item = true

          @keyword_pattern.each do |pattern|
              keep_item = false if (!contains_keyword(item, pattern))
          end
          @filtered_items << item if !keep_item
        end
      end
      binding.pry
      @filtered_items
    end
    
    def filter(item)
      @filtered_items.include? item
    end
    
    def expression
      "keywords: #{@keyword_pattern.to_s}"
    end
  end
  
  def self.match_all(args)
    if args[:keywords].nil?
      raise "MISSING KEYWORD PATTERN!"
    end
    binding.pry
    self.add_filter KeywordMatchAll.new(args[:keywords])
    binding.pry
  end
end