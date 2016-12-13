module RankingFunctions
  
  class ImageCount
    attr_accessor :image_set
    def initialize(image_set)
      @image_set = image_set
    end
    def score(item)
      size = @image_set.each_image([item]).size
      
      size
    end
    def intention
      "RankingFunctions.each_image_count(#{image_set.intention})"
    end
  end
  
  def self.each_image_count(image_set)
    ImageCount.new(image_set)
  end
  
end