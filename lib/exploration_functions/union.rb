module Explorable
  class Union < Explorable::Operation
    
    def eval
      input_set = @args[:input]
      target_set = @args[:target]
      start_time = Time.now
      mappings = input_set.extension_copy
      self_images = input_set.each_image
      target_images = target_set.each_image
      mappings = (self_images + target_images).map do |image| 
        if image.is_a? Xsubset
          [image, image]
        else
          [image, {}]
        end
      end.to_h
      finish_time = Time.now
      puts "EXECUTED UNION: " << (finish_time - start_time).to_s

      if @args[:inplace]
        input_set.extension = mappings
        self
      end
      mappings
      
    end
    
    def expression
      "union(#{@args[:input].id}, #{@args[:target].id})"
    end
  end
  
  def union(target, args={})
    args = {target: target}    
    execute_operation(Union, args)
  end
end