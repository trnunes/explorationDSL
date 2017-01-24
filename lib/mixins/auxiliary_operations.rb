module AuxiliaryOperations

  def group_by_relation
  end

  def group_by_value
  end

  def group_by_domain
  end
  
  def project(relation)
    @projections
  end

  def group_by_domain_and_relation
    grouped_hash = {}
    self.extension.each do |item, relations|
      grouped_hash[item] ||= {}
      relations.each do |image, relation|
        grouped_hash[item][relation] ||= Set.new()
        grouped_hash[item][relation] << image
      end
    end
    grouped_hash
  end

  def count_by_image
  end

  def count_by_domain
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

  def relations_set
    mappings = {}
    if root?
      @server.all_relations{|r| mappings[r] = {}} 
    else
    end
  
    mount_result_set("#{self.intention}.relations", mappings)  
  end

  def root?
    resulted_from.nil? && extension.empty?
  end

  def path?(relation)
    relation.respond_to? :each
  end
  
end


