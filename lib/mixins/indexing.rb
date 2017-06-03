module Indexing
  
  def self.find_entry(index_entries, entry_key)
    index_entries.each do |child|
      return child if child.indexing_item == entry_key
    end
    return nil
  end
  
  def find_item_at(index_keys, item_id)
    
    index_children = @index.children
    item = nil
    item_root_index = Entry.new('root')
    item_index = item_root_index
    while(!index_keys.empty?)
      key = index_keys.shift
      
      entry_found = index_children.select{|i| i.indexing_item == key}.first
      if(entry_found)
        index_children = entry_found.children
        item_index.children << entry_found.copy
      else
        break
      end
    end
    
    if(entry_found)
      item = entry_found.indexed_items.select{|item| item.to_s == item_id}.first
      item.index = item_root_index
    end
    
    item
  end
  def add_item(item)
    
    build_tree(item.index.find_root, @index)
    append_item(item)
  end
  
  
  def each_item(&block)
    
    items = leaves.map{|leaf_entry| leaf_entry.indexed_items}.flatten
    # binding.pry
    if(block_given?)
      items.each &block
    else
      items
    end
  end
  
  def leaves
    children = @index.children
    leaves = [@index]
    while(!children.empty?)
      leaves = children
      children = children.map{|c| c.children}.flatten
    end
    leaves
  end
    
  def build_tree(pair_index, my_index)
    
    
    pair_indexing_children = pair_index.children.map{|child| [child.indexing_item, child]}.to_h
    my_index_children = my_index.children.map{|child| [child.indexing_item, child]}.to_h
    
    common_indexes = pair_indexing_children.keys & my_index_children.keys
    
    common_indexes.each do |indexing_item|
      build_tree(pair_indexing_children[indexing_item], my_index_children[indexing_item])
    end
    
    common_indexes = Set.new(common_indexes)
    if(my_index_children.empty?)
      my_index.children = pair_index.copy_structure.children
    else
      pair_indexing_children.each do |indexing_item, child|
        if(!(common_indexes.include? indexing_item))
          my_index.add_child pair_indexing_children[indexing_item].copy_structure
        end
      end
    end
  end
  
  def append_item(item)
    find_leaf(item.index.find_root, @index).append_item(item)
  end
  
  def find_leaf(pair_index, my_index)
    pair_indexing_children = pair_index.children.map{|child| [child.indexing_item, child]}.to_h
    my_index_children = my_index.children.map{|child| [child.indexing_item, child]}.to_h
    
    common_indexes = pair_indexing_children.keys & my_index_children.keys
    
    common_indexes.each do |indexing_item|
      return find_leaf(pair_indexing_children[indexing_item], my_index_children[indexing_item])
    end
    
    if(pair_index.children.empty?)
      if(pair_index.indexing_item == my_index.indexing_item)
        return my_index
      end
    end
    
  end
  
  ########## PAGINATION ####################
  ##########################################
  
  # def paginate_items(max_items)
  #   @index.paginate_items(max_items)
  # end
  #
  # def paginate_groups(max_groups)
  #   @index.paginate_groups(max_groups)
  # end
  #
  # def count_item_pages
  #   @index.count_item_pages
  # end
  #
  # def count_group_pages
  #   @index.count_group_pages
  # end

  
  class Entry
    attr_accessor :indexing_item, :children, :indexed_items, :parent
    
    def initialize(indexing_item, parent = nil, children = [])
      @indexing_item = indexing_item
      @children = children
      @indexed_items = []
      @parent = parent
      if(parent)
        parent.children << self
      end
      
    end
    
    def <<(item)
      item.index = self
      @indexed_items << item
    end
    
    def add_child(entry)
      entry.parent = self
      # binding.pry
      @children << entry
    end
    
    def delete_child(entry)
      entries_to_delete = @children.select{|c| c.indexing_item == entry.indexing_item}
      entries_to_delete.each{|e| @children.delete(e)}
    end
    
    def copy
      if(children.empty?)
        copy_entry = Entry.new(@indexing_item)
        copy_entry.indexed_items = @indexed_items.dup.map{|item| item.shallow_clone}
        return copy_entry
      else
        my_copy = Entry.new(@indexing_item)
        children.each do |child|
          my_copy.add_child child.copy
        end
        return my_copy
      end
      
    end

    
    def copy_structure
      if(children.empty?)
        return Entry.new(@indexing_item)
      else
        my_copy = Entry.new(@indexing_item)
        children.each do |child|
          my_copy.children << child.copy_structure
        end
        return my_copy
      end
    end
    
    def get_entry(index_key)
      children.each do |child|
        return child if child.indexing_item == index_key
      end
      return nil
    end
    
    def eql?(item)
      item.class == self.class && @indexing_item == item.indexing_item && @parent == item.parent
    end
  
    def hash
      @id.hash
    end
    
    def children=(children)
      children.each{|child| child.parent = self}
      @children = children
    end
    
    def children(page = nil)
      if(page && @total_groups_per_page)
        @children[group_offset(page)..group_limit(page)] || []
      else
        @children
      end
    end
    
    def indexed_items=(indexed_items)
      @indexed_items = indexed_items
      @indexed_items.each{|item| item.index = self}
    end
        
    def indexed_items(page=nil)
      if(page && @total_items_per_page)
        @indexed_items[items_offset(page)..items_limit(page)] || []
      else
        @indexed_items
      end
    end
    
    def append_item(item)
      @indexed_items << item
      item.index = self
    end
    
    def find_root
      parent = @parent
      root = self
      while(!parent.nil?)
        root = parent
        parent = parent.parent
      end
      root
    end

  
    def to_s
      str = "\n"
      describe(str, 0)
      str
    end
    
    def describe(str, level)
      level += 2
      level.times{|t| str << " "}
      str << @indexing_item.to_s + " : " + "[" + indexed_items.map{|p| p.to_s}.join(", ") + "]\n"

      children.each do |c|

        c.describe(str, level)
      end
      str
    end
    
    def empty?
      if children.empty? 
        return indexed_items.empty?
      end
      false
    end
    
    def inspect
      to_s
    end
    
    ########## PAGINATION ####################
    ##########################################
    def total_groups_per_page
      if(@total_groups_per_page.to_i <= 0)
        @children.size
      else
        @total_groups_per_page
      end
    end

    def total_items_per_page
      if(@total_items_per_page.to_i <= 0)
        @indexed_items.size
      else
        @total_items_per_page
      end
    end

    def paginate_groups(max_groups)
      @max_groups = max_groups
      @total_groups_per_page = max_groups
      @children.each do |child|
        child.paginate_groups(max_groups)
      end
    end
    
    def paginate_items(max_items)
      @total_items_per_page = max_items
      @children.each do |child|
        child.paginate_items(max_items)
      end
    end
    
    def paginate(total_by_page)
      if(@children.empty?)
        paginate_items(total_by_page)
      else
        paginate_groups(total_by_page)
      end
    end
    
    
    def number_of_pages(size, total_by_page)
      if total_by_page == 0
        return 0
      end
    
      (size.to_f/total_by_page.to_f).ceil
    end
    
    def count_pages
      if(@children.empty?)
        count_item_pages()
      else
        count_group_pages()
      end
    end
    
    def limit(size, total_by_page, page)
      if size == 0 || total_by_page == 0
        return 0
      end
      number_of_pages = (size.to_f/total_by_page.to_f).ceil

      if page.to_f == number_of_pages
        size
      else
        (total_by_page * page) - 1
      end
    end
    
    def offset(page, total_by_page)
      (page - 1) * total_by_page
    end
    
    def count_group_pages
      number_of_pages(@children.size, total_groups_per_page())
    end
    
    def count_item_pages
      number_of_pages(@indexed_items.size, total_items_per_page())
    end
    
    def group_offset(page)
      offset(page, total_groups_per_page())
    end

    def items_offset(page)
      offset(page, total_items_per_page())
    end
    
    def group_limit(page)
      limit(@children.size, total_groups_per_page(), page)
    end
    
    def items_limit(page)
      limit(@indexed_items.size, total_items_per_page(), page)
    end
    
  end
  

end
# require 'set'
# class Pair
#   attr_accessor :index, :item
#   def initialize(item)
#     @item = item
#   end
#   def to_s
#     @item.to_s
#   end
#   def inspect
#     to_s
#   end
# end

# p1 = Pair.new('p1')
# p2 = Pair.new('p2')
# p3 = Pair.new('p3')
# p4 = Pair.new('p4')
# p5 = Pair.new('p5')
# p1.index = Indexing::Entry.new('root')
# p1.index.children = [Indexing::Entry.new('a1')]
# p1.index.children.first.children = [Indexing::Entry.new('2005')]
#
# p2.index = Indexing::Entry.new('root')
# p2.index.children = [Indexing::Entry.new('a1')]
# p2.index.children.first.children = [Indexing::Entry.new('2005')]
#
# p3.index = Indexing::Entry.new('root')
# p3.index.children = [Indexing::Entry.new('a1')]
# p3.index.children.first.children = [Indexing::Entry.new('2010')]
#
# p4.index = Indexing::Entry.new('root')
# p4.index.children = [Indexing::Entry.new('a2')]
# p4.index.children.first.children = [Indexing::Entry.new('2005')]
#
# p5.index = Indexing::Entry.new('root')
# p5.index.children = [Indexing::Entry.new('a2')]
# p5.index.children.first.children = [Indexing::Entry.new('2005')]
#
# index = Indexing::Index.new
# index.add_item p1
# index.add_item p2
# index.add_item p3
# index.add_item p4
# index.add_item p5
# index.root