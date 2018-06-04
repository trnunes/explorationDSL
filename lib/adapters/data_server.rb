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
  
  def paginate(items_list, page_size)
    offset = 0
    pages = []
    while offset < items_list.size
      pages << items_list[offset..(offset+page_size)]
      offset += page_size
    end
    pages
  end 

  
end