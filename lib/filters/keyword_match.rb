module Filtering
  class KeywordMatch < Filtering::Filter
    def initialize(*args)
      raise "Invalid number of arguments #{args.size} for 1" if args.size != 1
      @keyword_pattern = args.first
    end
    
    def contains_keyword(item, keyword)
      item.text.to_s.downcase.include?(keyword.downcase)
    end
    
    def prepare(items, server)
      
      @filtered_items = Set.new
      keep_item = false
      
      items.each do |item|
        keep_item = true

        @keyword_pattern.each do |pattern|
            keep_item = false if (!contains_keyword(item, pattern))
        end
        @filtered_items << item if !keep_item
      end
      @filtered_items
    end
    
    def filter(item)
      @filtered_items.include? item
    end
    
    def expression
      "keywords: #{@keyword_pattern.to_s}"
    end
  end
  
  def self.keyword_match(args)
    if args[:keywords].nil?
      raise "MISSING KEYWORD PATTERN!"
    end
    
    self.add_filter KeywordMatch.new(args[:keywords])
  end
end