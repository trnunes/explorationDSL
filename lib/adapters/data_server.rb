require 'rdf'
require 'sparql/client'

class DataServer
  include Searchable
  include Navigational
  
  ###
  ### Inform whether the server can handle relation paths as arguments
  ###
  ACCEPT_PATH_QUERY = false

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
  
  #TODO ANALYZE whether theres a better place for this (maybe an enumerable mixin)
  def paginate(items_list, page_size)
    
    return [items_list] if !(page_size.to_i > 0)
    
    offset = 0
    pages = []
    while offset < items_list.size
      pages << items_list[offset..(offset+page_size)]
      offset += page_size
    end
    pages
  end 

  
end