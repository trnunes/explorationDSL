module Indexable
  def domain
    @index.indexing_item
  end

  # def get_entry
  #   children = @index.children
  #   entry = @index.indexing_item
  #
  #   while(!children.empty?)
  #     entry = children.first
  #     children = children.first.children
  #   end
  #   entry
  # end

  def neighbors
    indexed_items = @index.indexed_items.dup
    indexed_items.delete(self)
    indexed_items
  end
end
