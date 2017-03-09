module HashHelper
  
  def self.add_hash(hash1, hash2)





    hash1.merge!(hash2)


  end

  
  def self.join(source_hash, target_hash)





    merged_hash = {}
    if source_hash.empty?
      return target_hash
    end
    if target_hash.empty?
      return source_hash
    end
    source_hash.each do |key, values|
      source_hash.delete(key) if values.empty?
    end

    target_hash.each do |key, values|
      target_hash.delete(key) if values.empty?
    end
    
    source_hash.each do |key, values|
      merged_hash[key] ||= {}
      if !self.empty_values?(values)
        merged_value = self.join(values, target_hash)
        merged_hash[key].merge!(merged_value)


      else
        values.merge(target_hash) do |value_key, value1, value2| 
          merged_hash[key][value_key] ||= {}
          merged_hash[key][value_key].merge!(value1).merge!(value2)
        end
      end
    end


    
    merged_hash
  end
  
  def self.unite(hash1, hash2)
    hash1.merge!(hash2){|join_key, v1, v2| v1}
    self.unite_values(hash1, hash2)
  end
  
  def self.unite_values(hash1, hash2)

    


  #

    
    hash1.each do |h1_key, h1_values|
      hash2.each do |h2_key, h2_values|        
        if(h1_key == h2_key)
          self.unite_values(h1_values, h2_values)
          h1_values.merge!(h2_values){|join_key, v1, v2| v1}         
        end
      end
    end


  end
  
  def self.empty_values?(hash)
    hash.values.select{|v| !v.empty?}.empty?
  end
  
  def self.append_leaf_children(hash, parents_hash, items)


    self.add_hash(hash, parents_hash)
    father = self.leaves(parents_hash).first
    fathers_hash = self.subhash_search(hash, father)
    self.join(fathers_hash, items).each do |key, values|
      fathers_hash[key] = values
    end


  end
  
  def self.print_hash(hash, level=1)
    hash.each do |key, values|
      level_str = ""
      level.times{|t| level_str << " "}
      puts level_str + key.to_s

      if values.is_a? Hash
        print_hash(values, level+1)
      else
        values.each do |value|
          puts level_str + " " + value.to_s
        end
      end        
    end
  end
    
  def self.leaves(hash)
    leaves = Set.new()
    self.find_leaves(hash, leaves)
    leaves
  end
  
  def self.copy(hash)
    Marshal.load(Marshal.dump(hash))
  end
  
  def self.subhash_search(hash, subhash_key)


    

    if hash.has_key? subhash_key
      return hash[subhash_key]
    else
      if(!self.empty_values?(hash))
        hash.values.each do |value|
          return self.subhash_search(value, subhash_key)
        end
      end
    end
    return nil
  end
  
  def self.find_leaves(hash, leaves)

    if(self.empty_values?(hash))
      leaves.merge(hash.keys)
    else
      hash.values.each do |value|
        if self.empty_values?(value)
          leaves.merge(value.keys)

        else
          self.find_leaves(value, leaves)
        end
      end      
    end
  end
  
end