module RankingFunctions
  
  class ImageCount
    attr_accessor :image_set
    
    def initialize(image_set)
      @image_set = image_set
    end
    
    def score(set, item)
      item_image = @image_set.extension[item]
      if item_image.nil?
        return 0
      end      
      item_image.each do |relation, values|
        if values.is_a? Hash
          item_image += values.keys
        else
          item_image += values.to_a
        end          
      end
      item_image.size
    end    
    
    def name
      "each_image_count"
    end
  end
  
  class AlphabeticalSort
    def score(set, item)
      item.to_s
    end
    
    def name
      "alpha_sort"
    end
  end
  
  class RelationRank
    attr_accessor :relation
    def initialize(relation)
      @relation = relation
    end
    def score(set, item)
      @pivot_set ||= set.pivot(@relation)
      
    end
    def name
      "relation_rank"
    end
  end
  
  def self.each_image_count(image_set)
    ImageCount.new(image_set)
  end
  
  def self.alpha_sort
    AlphabeticalSort.new()
  end
  
  def self.relation_rank(relation)
    RelationRank.new(relation)
  end
  
  def self.custom_rank(function)
    CustomRank.new(function)
  end
  
end