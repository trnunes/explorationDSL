require 'rdf'
require 'sparql/client'

class DataServer
  include Searchable
  include Navigational
  include Filterable
  
  def accept_path_query?
    false
  end
    
  

  def find_relations(entity)
  end
 
  def execute(query, options = {})
    []
  end
  
  def sort(items, sorting_relation)
  end
  
  def group(items, grouping_relation)
  end
  
  def correlate(origin_item, target_item)
  end
  
end