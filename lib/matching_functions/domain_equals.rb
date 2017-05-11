module Matching
  class ImageEquals
    def match(pair1, pair2)
      pair1.image == pair2.image
    end
  end
  
  def image_equals
    return ImageEquals.new
  end
end