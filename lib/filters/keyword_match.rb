module Filtering
  class KeywordMatch < Filtering::Filter
    def initialize(*args)
      raise "Invalid number of arguments #{args.size} for 1" if args.size != 1
      @keyword_pattern = args.first
    end
    
    def eval(set)
      
      extension = set.extension_copy
      filtered_items = Set.new
    
      relations_query = build_nav_query(set)
      relations_query.find_relations
    
      keep_item = false
      
      relations_query.execute.each_pair do |item, relations|
        keep_item = false        
      
        relations.values.each do |related_item|
          @keyword_pattern.each do |pattern|
            if pattern.respond_to? :each
              pattern.each do |disjunctive_keyword|
                keep_item = true if related_item.to_s.include?(disjunctive_keyword)
              end
            else
              keep_item = false if !related_item.to_s.include?(pattern)
            end
          end
        end

        extension.delete(item) if !keep_item        
      end
      super(extension, set)
    end
    
    def expression
      "keyword_match"
    end
  end
  
  def self.keyword_match(keyword_pattern)
    self.add_filter KeywordMatch.new(keyword_pattern)
  end
end