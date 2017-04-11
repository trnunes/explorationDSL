module AuxiliaryOperations

  def group_by_relation
  end

  def group_by_value
  end

  def group_by_domain
  end
  
  def project(relation)
    items_hash = {}
    self.each_item do |item|
      items_hash[item.id] = item
    end
    
    self.pivot_forward([relation]).extension.each do |item, values|
      literal = ""
      labels = []
      values.each_item do |label|
        labels << label
      end
      
      items_hash[item.id].text = labels.join " | "
    end
    self    
  end

  def group_by_image_and_relation
    @projection = {}

    self.extension.each do |item, relations|      
      relations.each do |image, relation|
        @projection[image] ||= {}
        @projection[image][relation] ||= Set.new()
        @projection[image][relation] << item
      end
    end
    self
  end
  def group_by_domain_and_relation
    self.projection = {}
    self.extension.each do |item, relations|      
      relations.each do |image, relation|
        self.projection[item] ||= {}
        self.projection[item][relation] ||= Set.new()
        self.projection[item][relation] << image
      end
    end
    self
  end
  
  def domain_items

    @projection = {}
    self.extension.keys.each do |item|

      @projection[item] = {}
    end
    self
  end

  def count_by_image
  end

  def count_by_domain
  end
  
  def relations_hash
    relations_hash = {}
    self.each_item do |image_item, backward_relations|
      backward_relations.each do |domain_item, relation|
        relations_hash[relation] ||= Set.new()
        relations_hash[relation] << image_item
      end
    end
    relations_hash
  end
  
  def common_relations
    relations = []
    query = @server.begin_nav_query do |q|
      each do |item|
        q.on(item)      
      end
      q.find_relations_in_common
    end
    query.execute.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        relations << relation
      end
    end
    relations
  end
  
  

  
  def pivot_hash(hash)
    pivoted_hash = {}
    hash.each do |item, relation_hash|
      relation_hash.each do |relation, values|
        if values.is_a? Hash
          pivoted_value = pivot_hash(values)
          pivoted_value.each do |value_key, value_relations|
            pivoted_hash[value_key] ||= {}
            pivoted_hash[value_key][item] ||= {}
            pivoted_hash[value_key][item][relation] = pivoted_value[value_key]
          end            
        else
          values.each do |value|
            pivoted_hash[value] ||= {}
            pivoted_hash[value][item] = relation
          end
        end
      end
    end
    pivoted_hash
  end
  
  def print_hash(hash = extension, level=1)
    hash.each do |key, values|
      level_str = ""
      level.times{|t| level_str << " "}


      if values.is_a? Hash
        print_hash(values, level+1)
      else
        values.each do |value|

        end
      end        
    end
  end
  
  def relations_set
    mappings = {}
    if root?
      @server.all_relations{|r| mappings[r] = {}} 
    else
    end
  
    mount_result_set("#{self.intention}.relations", mappings)  
  end

  def root?
    resulted_from.nil?
  end

  def path?(relation)
    relation.respond_to? :each
  end
  
end


