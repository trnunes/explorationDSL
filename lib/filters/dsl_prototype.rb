# # #Subtask1: mean publication year of the references
# s1 = p.pivot{relation "cite"}
# s2 = s1.pivot{relation "year"}
# s3 = s2.map{mean}
# #
# # #Subtask2: find missing relevant citations
# s4 = d.refine{match_all "Semantic Web"}
# s5 = s4.group{relation "cite"}
# s6 = s5.map{count}
# s7 = s6.rank{score_by_image level: 1}[0..19]
# s8 = s7.diff s1
# #
# # #Subtask3: finding the amount of self-citations of the paper
# s9 = p.pivot{relation "isDocumentContextFor", "isHeldBy"}
# s10 = s9.pivot{relation inverse("isHeldBy"), inverse("isDocumentContextFor")}
# s11 = s1.intersect s10
# s12 = s11.map{count}

require 'pry'
require './adapters/rdf/sparql_helper.rb'
require './adapters/filterable'
require './adapters/navigational'
require './adapters/searchable'
require './adapters/data_server'
require './adapters/rdf/rdf_navigational.rb'
require './adapters/rdf/rdf_data_server.rb'

require './adapters/rdf/cache.rb'
require './adapters/rdf/filter_interpreter.rb'
require 'forwardable'
require './mixins/xplain'
require './mixins/relation'
require './mixins/enumerable'
require './mixins/model_factory'
require './mixins/writable'
require './filters/filtering'
require './model/namespace'

require './visualization/visualization'
require 'securerandom'










module Explorable

  def self.server=(server)
    @@server = server
  end
  def self.server
    @@server
  end
  
end



# module Relation
#   attr_accessor :annotations, :id, :root, :domain_restriction, :image_restriction
#
#   def add_relation(parent, child)
#     root.add_child parent
#     parent.add_child child
#   end
#
#   def get_cursor(level, page_size)
#     Cursor.new(self, [], [], level, page_size)
#   end
#
#   def add_path(nested_items)
#
#
#     previous_item = @root
#     nested_items.each do|item|
#       item_copy = item.copy
#       previous_item.add_child item_copy
#       previous_item = item_copy
#     end
#   end
#
#   def fetch(items)
#     root.children = fetch_graph(items)
#   end
#
#   def fetch_graph(items)
#     return []
#   end
#
#   def build_tree(item1, item2)
#     parent1, parent2 = item1.parent, item2.parent
#     if parent1 == parent2
#       parent1.children = [item1, item2]
#       build_tree(parent1, parent1)
#     end
#   end
#
#   def to_hash
#     each_domain
#   end
#
#   def <<(item)
#     root.add_child item
#   end
#
#   def image
#   end
#
#   def build_image_results(query_results_hash)
#     restricted_image_rs = []
#     query_results_hash.each do |item, relations_hash|
#       relations_hash.each do |key, values|
#         values.each do |v|
#           v.parent = item
#           restricted_image_rs << v
#         end
#       end
#     end
#     restricted_image_rs
#   end
#
#   def build_domain_results(query_results_hash)
#     restricted_domain_rs = Set.new
#     query_results_hash.each do |item, relations_hash|
#       relations_hash.each do |relation, values|
#         values.each do |value|
#           item.add_child value
#           restricted_domain_rs << item
#         end
#       end
#     end
#
#     restricted_domain_rs
#   end
#
#   def restricted_image(restriction, options={})
#     Cursor.new(self, restriction, [], 3)
#   end
#
#   def fetch_restricted_domain(restriction, options={})
#   end
#
#   def fetch_restricted_image(restriction, options={})
#   end
#
#   def restricted_domain(restriction, options={})
#     Cursor.new(self, [], restriction, 2)
#   end
#
#
#   def each_level(&block)
#     levels = []
#
#     current_level = [root]
#
#     while !current_level.empty?
#       levels << current_level
#       if block_given?
#         yield(current_level)
#       end
#       current_level = current_level.map{|li| li.children}.flatten
#
#     end
#     levels
#   end
#
#   def count_levels
#     number_of_levels = 1
#     each_level{number_of_levels+=1}
#     number_of_levels
#   end
#
#   def get_level(level, parents_restriction=[], children_restriction= [], offset=0, limit=-1)
#     level_items = []
#     current_level = 0
#     each_level{|current_level_items| level_items = current_level_items if ((current_level += 1) == level)}
#     if(limit > 0 && offset >= 0 )
#       level_items = level_items[offset..(offset+limit)-1]
#     end
#     level_items
#   end
#
#   def leaves
#     each_level.last
#   end
#
#   def each
#   end
#
#   def each_domain
#     root.children
#   end
#
#   def each_image
#   end
#
#   def copy
#   end
#
#   def find_local(local_id)
#   end
#
#   def find_by_id(full_id)
#   end
#
#   def remove_branch(full_id)
#   end
#
#   def remove_relation(parent, child)
#   end
#
#   def paths
#     paths = []
#     bfs(root) do |item, current_path|
#       if(item.children.empty?)
#         paths << current_path.dup
#       end
#       # #binding.pry
#     end
#     paths
#   end
#
#   def bfs(item, current_path = [], &block)
#     current_path << item
#     if block_given?
#       yield(item, current_path)
#     end
#     item.children.each do |child|
#       bfs(child, current_path, &block)
#     end
#     current_path.pop
#   end
#
#   def inverse?
#     false
#   end
#
#   def schema?
#     false
#   end
#
# end

# class ComputedRelation
#   include Relation
#   def initialize(id = SecureRandom.uuid)
#     @id = id
#     @root = Entity.new(@id)
#   end
#
#   def fetch_graph(items)
#     @root.children && items
#   end
# end
#
# class FlattenedRelation
#   include Relation
# end
#
# class SchemaRelation
#   include Relation
#   attr_accessor :id, :server, :root, :inverse, :cursor
#
#   def initialize(args={})
#     @id = args[:id]
#     @server = server
#     @inverse = args[:inverse]
#     @server = args[:server] || Explorable.server
#     @root = Entity.new(@id)
#     @cursor = Cursor.new(self)
#   end
#
#   def fetch_graph(items, limit=nil, offset=nil)
#     restricted_image(items, {limit: limit, offset: offset}).map{|item| item.parent}.uniq
#   end
#
#   def schema?
#     true
#   end
#
#   def to_s
#     @id
#   end
#
#   def get_level(level, parents_restriction = [], children_restriction = [], offset = 0, limit = -1)
#     if(level == 2)
#       if(!children_restriction.empty?)
#         fetch_restricted_domain(children_restriction, {offset: offset, limit: limit})
#       else
#         domain(offset, limit)
#       end
#     elsif (level == 3)
#       if(!parents_restriction.empty?)
#         fetch_restricted_image(parents_restriction, {offset: offset, limit: limit})
#       else
#         image(offset, limit)
#       end
#
#     end
#   end
#
#
#   def image(offset=0, limit=nil)
#       build_image_results(@server.image(self, [], offset, limit))
#   end
#
#   def domain(offset=0, limit=-1)
#       build_domain_results(@server.domain(self, [], offset, limit))
#   end
#
#
#   def each_domain(offset=0, limit=-1, &block)
#
#     domains = domain(offset, limit)
#     domains.each &block
#     domains
#   end
#
#   def each_image(offset=0, limit=-1, &block)
#     image(offset, limit).each &block
#   end
#
#   def fetch_restricted_image(restriction, options= {})
#     options[:restriction] = restriction
#     options[:relation] = self
#     partial_path_results = @server.restricted_image(options)
#     build_image_results(partial_path_results)
#   end
#
#   def fetch_restricted_domain(restriction, options = {})
#     options[:restriction] = restriction
#     options[:relation] = self
#     partial_path_results = @server.restricted_domain(options)
#     build_domain_results(partial_path_results)
#   end
#
#   def leaves()
#     image()
#   end
#
#   def inverse?
#     @inverse
#   end
#
#   def inspect
#     to_s
#   end
# end
#
# class PathRelation
#   include Relation
#   extend Forwardable
#   attr_accessor :id, :server, :inverse, :text, :relations, :limit, :root
#   def_delegators :@relations, :map, :each, :size
#
#
#   def initialize(args = {})
#     @limit = args[:limit]
#     @relations = args[:relations]
#     @id = args[:id]
#     @server = args[:server] || Explorable.server
#     @domain_restriction = args[:domain_restriction] || []
#     @image_restriction = args[:image_restriction] || []
#
#     @root = Entity.new(@relations.map{|r| r.id}.join("/"))
#     @cursor = Cursor.new(self)
#   end
#
#
#   def id
#     @relations.map{|r| r.id}.join("/")
#   end
#
#   def can_fire_path_query
#     are_all_schema_relations = (@relations.select{|r| !r.schema?}.size == 0)
#     are_all_schema_relations
#   end
#
#   def inverse?
#     (@relations.select{|r| r.inverse?}.size == @relations.size)
#   end
#
#
#   def image(offset=0, limit=-1)
#       build_image_results(@server.image(self, [], offset, limit))
#   end
#
#   def domain(offset=0, limit=-1)
#       build_domain_results(@server.domain(self, [], offset, limit))
#   end
#
#   def restricted?
#     !(@image_restriction.empty? && @domain_restriction.empty?)
#   end
#
#   def each_domain(offset=0, limit=-1, &block)
#     # #binding.pry
#     domains = domain(offset, limit)
#     domains.each &block
#     domains
#   end
#
#
#   def server=(server)
#     @server = server
#     @relations.each{|r| r.server = server}
#   end
#
#
#   def mixed_path_restricted_image(items, options = {})
#     relations = @relations
#
#     result_items = items
#
#     relations.each do |r|
#
#       partial_images = r.restricted_image(Set.new(result_items), options)
#
#       partial_images_hash = {}
#
#       partial_images.each do |item|
#         if(!partial_images_hash.has_key? item.parent)
#           partial_images_hash[item.parent] = []
#         end
#         partial_images_hash[item.parent] << item
#
#       end
#
#       new_result_items = []
#       result_items.each do |item|
#
#         if(partial_images_hash.has_key? item)
#           partial_images_hash[item].each do |next_image|
#
#             next_image.parent = item
#             new_result_items << next_image
#           end
#         end
#       end
#
#       result_items = new_result_items
#
#     end
#     build_results result_items
#   end
#
#   def mixed_path_restricted_domain(items, options = {})
#     relations = @relations.reverse
#     result_pairs = []
#     result_pairs = items
#     relations.each do |r|
#       result_pairs = r.restricted_domain(Set.new(result_pairs), options)
#     end
#     build_results result_pairs
#   end
#
#   def schema_restricted_image(restriction, options = {})
#     server = Explorable.server
#     result_items = []
#     options[:restriction] = restriction
#     options[:relation] = self
#     partial_path_results = @server.restricted_image(options)
#
#     build_results(build_image_results(partial_path_results))
#   end
#
#   def build_results(result_items)
#     if(result_items.first.is_a? Entity)
#       Set.new(result_items)
#     else
#       result_items
#     end
#   end
#
#   def schema_restricted_domain(restriction, options = {})
#     result_items = []
#     options[:restriction] = restriction
#     options[:relation] = self
#     partial_path_results =Explorable.server.restricted_domain(options)
#     build_results(build_domain_results(partial_path_results))
#   end
#
#   def fetch_restricted_image(restriction, options = {})
#
#     if can_fire_path_query
#         schema_restricted_image(restriction, options)
#     else
#         mixed_path_restricted_image(restriction, options)
#     end
#   end
#
#   def fetch_restricted_domain(restriction, options = {})
#     if can_fire_path_query
#         schema_restricted_domain(restriction, options)
#     else
#         mixed_path_restricted_domain(restriction, options)
#     end
#   end
#
#   def get_level(level, parents_restriction = [], children_restriction = [], offset = 0, limit = -1)
#     if(level == 2)
#       if(!children_restriction.empty?)
#         fetch_restricted_domain(children_restriction, {offset: offset, limit: limit})
#       else
#         domain(offset, limit)
#       end
#     elsif (level == 3)
#       if(!parents_restriction.empty?)
#         fetch_restricted_image(parents_restriction, {offset: offset, limit: limit})
#       else
#         image(offset, limit)
#       end
#
#     end
#   end
#
#
#   def text
#     @relations.map{|r| r.text}.join("/")
#   end
#
#   def eql?(relation)
#     (self.id == relation.id) && (relation.inverse == self.inverse)
#   end
#
#   def hash
#     @id.hash * inverse.hash
#   end
#
#   def leaves
#     image()
#   end
#
#   alias == eql?
#
# end
#
# class Entity
#   extend Forwardable
#   attr_accessor :id, :text, :server, :parent, :children, :type
#   def_delegators :@children, :<<
#   def initialize(id)
#     @id = id
#     @children = []
#   end
#
#   def copy
#     self_copy = Entity.new(@id)
#     self_copy.text = @text
#     self_copy.server = @server
#     @children.each do |child|
#       self_copy.add_child child.copy
#     end
#
#     self_copy.type = @type
#     self_copy
#   end
#
#   def parent=(item)
#     @parent = item
#     item.add_child self
#   end
#
#   def set_parent(parent)
#     @parent = parent
#   end
#
#   def add_child(item)
#     @children << item
#     item.set_parent(self)
#   end
#
#   def set_children(children_set)
#     @children = children_set
#     children_set.each{|c| c.set_parent self}
#   end
#
#   def add_server(server)
#     @server = server
#   end
#
#   def to_s
#
#     "Entity: " + @id
#   end
#
#   def inspect
#     to_s
#   end
#
#   def eql?(item)
#     if !item.respond_to? :id
#       return false
#     end
#     @id == item.id
#   end
#
#   def hash
#     @id.hash
#   end
#
#   alias == eql?
# end
#
# class Literal
#   extend Forwardable
#
#   attr_accessor :value, :datatype, :parent, :children
#   def_delegators :@children, :<<
#
#   def initialize(value, type = "")
#     @value = value
#     @datatype = type
#     @children = []
#   end
#
#   def set_parent(parent)
#     @parent = parent
#   end
#
#   def add_child(item)
#     @children << item
#     item.set_parent(self)
#   end
#
#   def set_children(children_set)
#     @children = children_set
#     children_set.each{|c| c.set_parent self}
#   end
#
#   def copy
#     self_copy = Literal.new(@value, @datatype)
#     @children.each{|child| self_copy.add_child child.copy}
#     self_copy
#   end
#
#   def to_s
#     "Literal: " + @value.to_s
#   end
#
#   def inspect
#     to_s
#   end
# end


# module Writeable
#   attr_accessor :items
#   def self.included klass
#     klass.class_eval do
#       include ModelFactory
#     end
#   end
#
#   def add_relation(relation_id)
#     self << new_relation(relation_id)
#   end
#
#   def entity(entity_id)
#     self << new_entity(entity_id)
#   end
#
#   def literal(l_value)
#     self << new_literal(l_value)
#   end
#
#   def relations(*relations)
#     relations.each{|r| relation(r)}
#   end
#
#   def entities(*entities)
#     entities.each{|id| entity(id)}
#   end
#
#   def literals(*literals)
#     literals.each{|l| literal(l)}
#   end
# end
#
# module ModelFactory
#
#   def new_relation(*relations)
#
#     relations.map!{|r| (r.is_a?(Hash))? SchemaRelation.new(id: r.values.first, inverse: true) : SchemaRelation.new(id: r)}
#     if relations.size > 1
#       PathRelation.new(relations: relations)
#     else
#       relations.first
#     end
#   end
#
#   def new_entity(entity_id)
#     Entity.new(entity_id)
#   end
#
#   def inverse(relation)
#     {:inverse=>relation}
#   end
#
#   def new_literal(l_value)
#     l_value.is_a?(Hash)? Literal.new(l_value.values.first, l_value.keys.first) : Literal.new(l_value)
#   end
# end

# module FilterFactory
#   attr_accessor :values, :fvalue, :frelation
#   include ModelFactory
#   def relation(*relations)
#
#     @frelation = new_relation(*relations)
#   end
#
#   def entity(entity_id)
#     @fvalue = new_entity(entity_id)
#   end
#
#   def literal(l_value)
#     @fvalue = new_literal(l_value)
#   end
#
#   def entities(*entities)
#     @values = entities.map!{|id| new_entity(id)}
#   end
#
#   def literals(*literals)
#     @values = literals.map!{|l| new_literal(l)}
#   end
#
# end


# class SPARQLInterpreter
#   include SPARQLHelper
#
#   def accept_path_clause?
#     false
#   end
#
#   def initialize()
#     @relations_index = 1
#     @server = Explorable.server
#   end
#
#   def filter(var, operator, value)
#     if(value.is_a? Literal)
#       if !value.datatype.nil?
#         "#{var} #{operator} #{parse_item(value)}"
#       else
#         "#{var} #{operator} \"#{value.value.to_s}\""
#       end
#
#     else
#       "#{var} #{operator} #{parse_item(value)}"
#     end
#   end
#
#
#   def interpret(f)
#
#     filters = generate_filters(f.filters.first)
#     query = "SELECT ?s where{"
#     query << values_clause("?s", f.input_set)
#     query << filters.keys.join(". ")
#     filters_clauses = filters.values.flatten
#     if(!filters_clauses.empty?)
#       query << " FILTER(" + filters.values.flatten.join(" && ") + ")"
#     end
#
#     query << "}"
#     query
#     Explorable.server.execute(query)
#   end
#
#   def generate_where_hash(relation, operator, value)
#     hash = {}
#     where = path_clause(relation)
#     if relation
#       hash[where] ||= []
#       hash[where] << filter("?o", operator, value)
#     else
# #.*subject.*
#     end
#     hash
#   end
#
#   def generate_filters(f)
#
#     hash = {}
#     filter_clause =
#     if f.class == Refine::Equals
#
#       generate_where_hash(f.frelation, "=", f.fvalue)
#     elsif f.class == Refine::Contains
#       if(f.respond_to? :frelation)
#         where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
#
#         where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
#       else
# #.*subject.*
#       end
#       {where_clause => []}
#
#     elsif f.class == Refine::EqualsOne
#
#      if(f.respond_to? :frelation)
#        where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
#
#        where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
#      else
# #.*subject.*
#      end
#      {where_clause => []}
#     elsif f.class ==  Refine::Lt
#       generate_where_hash(f.frelation, "<", f.fvalue)
#     elsif f.class == Refine::LtEql
#       generate_where_hash(f.frelation, "<=", f.fvalue)
#     elsif f.class == Refine::Grt
#       generate_where_hash(f.frelation, ">", f.fvalue)
#     elsif f.class == Refine::GrtEql
#       generate_where_hash(f.frelation, ">=", f.fvalue)
#     elsif f.class == Refine::AndFilter
#       hash = {}
#       where_clauses = []
#       filters = []
#       f.filters.each do |af|
#         hash = generate_filters(af)
#         hash.each do |where, where_filters|
#           where_clauses << where.gsub("?o","?o#{@relations_index+=1}")
#           filters << ("(" + where_filters.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" && ") + ")")
#         end
#
#       end
#       where_clause = where_clauses.join(". ") << " Filter(" + filters.join(" && ") + ")"
#       {where_clause => []}
#
#     elsif f.class == Refine::OrFilter
#       hash = {}
#       where_clauses = []
#
#       filter_clause = ""
#       f.filters.each do |af|
#         hash.merge!(generate_filters(af)){|where, filters1, filters2| filters1 + filters2}
#       end
# #.*subject.*
#
#       hash.each do |where, fclauses|
#
#         where_copy = where.gsub("?o","?o#{@relations_index+=1}")
#         filter_clause = "(" + fclauses.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" || ") + ")"
#         where_clauses << "{" + where_copy + ". FILTER(#{filter_clause})}"
#       end
#
#       where_clause = where_clauses.join(" UNION ")
#       {where_clause => []}
#     elsif f.class == Refine::Not
#       "not implemented"
#     end
#     filter_clause
#   end
# end

# module Interpreter
#
#
#   def self.interpreter=(interpreter)
#     @@interpreter = interpreter
#   end
#
#   def interpret
#     @@interpreter ||= SPARQLInterpreter.new
#     @@interpreter.interpret self
#   end
# end

# module Filtering
#   attr_accessor :filters
#
#
#   class Equals
#     include FilterFactory
#   end
#
#   class Lt
#     include FilterFactory
#   end
#
#   class LtEql
#     include FilterFactory
#   end
#
#   class Grt
#     include FilterFactory
#   end
#
#   class GrtEql
#     include FilterFactory
#   end
#
#   class Not
#     include FilterFactory
#   end
#
#   class EqualsOne
#     include FilterFactory
#   end
#
#   class Contains
#     include FilterFactory
#   end
#
#   class AndFilter
#     include Filtering
#     attr_accessor :filters
#     def initialize
#       @filters = []
#     end
#   end
#
#   class OrFilter
#     include Filtering
#     attr_accessor :filters
#     def initialize
#       @filters = []
#     end
#   end
#
#   def And(&block)
#     i = AndFilter.new
#     i.instance_eval &block
#     @filters ||= []
#     @filters << i
#
#     i
#   end
#
#   def Or(&block)
#     i = OrFilter.new
#     i.instance_eval &block
#     @filters ||= []
#     @filters << i
#
#     i
#   end
#
#   def equals_one(&block)
#     i = EqualsOne.new
#
#     i.instance_eval &block
#     @filters ||=[]
#     @filters << i
#     i
#   end
#
#
#   def equals(&block)
#     i = Equals.new
#
#     i.instance_eval &block
#     @filters ||= []
#     @filters << i
#     i
#   end
#
#   def contains(&block)
#     i = Contains.new
#
#     i.instance_eval &block
#     @filters ||=[]
#     @filters << i
#     i
#
#   end
#
#   def match(&block)
#
#   end
#
# end


class Refine
  include Xplain::Filtering

  attr_accessor :input_set
  def initialize(input_set, &block)
    @input_set = input_set
    @filter_definition_block = block
  end
  
  def execute()
    self.instance_eval &@filter_definition_block
    rs = self.interpret
    Xset.new{rs.each{|r| entity r[:s].to_s}}
  end
end

class Pivot
  include Xplain::ModelFactory
  attr_accessor :relation
  def initialize(input_set, &block)
    @input_set = input_set
    @definition_block = block
  end
  
    
  def relation(*relations)
    @relation = new_relation(*relations)
  end
  
  def execute()
    self.instance_eval &@definition_block
    restricted_relation = @relation.restricted_image(@input_set)
    
    Xplain::Xset.new(relation: restricted_relation)
  end
end

class VerticalCursor
end

class HorizontalCursor

  attr_accessor :window_size, :relation, :pages_cache
  def initialize(relation, level = 2, window_size = 20)
    @pages_cache = {}
    @relation = relation
    @level = level
    reset(window_size)
  end
  
  def reset(window_size=20)
    @page = 0
    @offset = 0
    if @window_size != window_size
      @pages_cache = {}
    end
    @window_size = window_size
    @limit = window_size    
  end
  
  def next_page
    if(@pages_cache.has_key? page_number)
      return @pages_cache[page_number]
    end
    
    domain = @relation.execute(level, @offset, @limit)
    @page += 1
    @offset += @limit
    @pages_cache[@page] = domain
    domain
  end
  
  def get_page(page_number)
    if(@pages_cache.has_key?(page_number))
      return @pages_cache[page_number]
    end
    return [] if(page_number < 1)
    
    pg_offset = 0
    
    (page_number - 1).times{|pg| pg_offset += @limit}
    
    domains = @relation.each_domain(pg_offset, @limit)
    @pages_cache[page_number] = domains
    domains
  end
  
end


module Grouping
  class ByImage
    attr_accessor :restriction
    def initialize(*args)
      if(args.empty?)
        raise "Relation missing!"
      end
      @relation = args.first
      @relation_hash = {}
    end
    
    def prepare(items)
      @relations_hash = @relation.domain_restrict(items).each_domain.map{|ditem| [ditem, ditem.children]}.to_h
    end
    
    def find_grouping_items(item)
      #binding.pry
      grouping_items = @relations_hash[item] || []
    end
  end
end


class Group
  include ModelFactory
  include Grouping
  attr_accessor :grouping_relation, :input_set
  
  def initialize(input_set, &block)
    @input_set = input_set
    @definition_block = block
  end
  
  def relation(*relations)
    @relation = new_relation(*relations)
  end
  
  def execute
    self.instance_eval &@definition_block
    grouped_paths = []
    input_copy = @input_set.copy
    #binding.pry
    
    next_to_last_level = input_copy.get_level(@input_set.count_levels - 1)
    items_to_group = []
    next_to_last_level.each do |item|
      items_to_group += item.children
    end
    @grouping_relation.prepare(items_to_group)
    next_to_last_level.each do |item|
      children_by_grouping_items = {}
      item.children.each do |child|
        grouping_items = @grouping_relation.find_grouping_items child
        grouping_items.each do |gitem|
          # binding.pry
          if !children_by_grouping_items.has_key? gitem
            children_by_grouping_items[gitem] = []
          end
          children_by_grouping_items[gitem] << child
        end
      end
      item.children = []
      children_by_grouping_items.each do |key, grouped_items|
        item.add_child key
        grouped_items.each{|gitem| key.add_child gitem}
      end
    end
    input_copy
  end
  
  def method_missing(m, *args, &block)  
    operation_instance = nil
    # #binding.pry
    operation_klass = Object.const_get "Grouping::" << m.to_s.split("_").map{|pname| pname.capitalize}.join
    # #binding.pry
    operation_instance = operation_klass.new(*args, &block)

    @grouping_relation = operation_instance
  end
  
end

module Mapping
  class Aggregation
    def apply(items)
      
    end
  end
  
  class Transformation
  end
  
  class Combination
  end
  
  class Count < Aggregation
    def apply(items)
      Literal.new(items.size)
    end
  end
  
  class Mean < Aggregation
    def apply(items)
      Literal.new(items.inject(0){|sum, item| sum + item.value}/items.size.to_f)
    end
  end
  
  class Project < Transformation
    attr_accessor :relation
    def initialize(input_set, &block)
      @relation = relation
    end
    
    def apply(items)
      @relation.restricted_image(items)
    end
  end
  
end


class Map
  attr_accessor :mapping_function, :input_set, :level
  
  def initialize(input_set,level=nil, &block)

    @input_set = input_set
    @definition_block = block
    @level ||= @input_set.count_levels - 1
  end
  
  
  def execute()
    input_set_copy = @input_set.copy
    level_to_map = @input_set.get_level(@level)
    
    level_to_map.each do |level_item|
      map_results = @mapping_function.apply(level_item.children)
      if !map_results.respond_to? :each
        map_results = [map_results]
      end
      level_item.set_children map_results
    end
  end
  
  def relation(*relations)
    new_relation(*relations)
  end
  
  def method_missing(m, *args, &block)  
    operation_instance = nil
    # #binding.pry
    operation_klass = Object.const_get "Mapping::" << m.to_s.split("_").map{|pname| pname.capitalize}.join
    # #binding.pry
    operation_instance = operation_klass.new(*args, &block)

    @mapping_function = operation_instance
  end
end


# class Xset
#   include Writeable
#   extend Forwardable
#
#   attr_accessor :id, :title, :relation
#   def_delegators :@relation, :get_level, :count_levels, :leaves, :each_level, :<<, :restricted_image, :restricted_domain, :root
#
#   def initialize(args = {}, &block)
#
#     @id = args[:id]
#     @title = args[:title]
#     @items = []
#     @relation = args[:relation] || ComputedRelation.new
#     if block_given?
#       self.instance_eval &block
#     end
#   end
#
#
#   def copy
#     self_copy = Xset.new
#     r = ComputedRelation.new(root.id)
#     r.root = root.copy
#     #binding.pry
#     self_copy.relation = r
#     self_copy
#   end
#
#   def each(&block)
#     items = []
#
#     if relation.nested?
#       items = @relation.get_level(@relation.count_levels - 1)
#     else
#       items = @relation.leaves
#     end
#     if block_given?
#       items.each &block
#     else
#       items
#     end
#   end
#
#   def [](index)
#     @relation.leaves[index]
#   end
#
#   def empty?
#     each.empty?
#   end
#
#   def method_missing(m, *args, &block)
#     operation_instance = nil
#     operation_klass = Object.const_get m.capitalize
#     args.unshift(self)
#     operation_instance = operation_klass.new(*args, &block)
#     operation_instance.execute
#   end
#
#   def size
#     each.size
#   end
# end

#Refine
# rs = s.refine do
#   equals do
#     relation "_:cite"
#     entity "_:p2"
#   end
# end




# Explorable.server = @papers_server


# puts rs.inspect

# r = Xset.new.refine do
#   equals do
#     relation "rtest", "rtest2"
#     entity "s"
#   end
# end
#
# r = Xset.new.refine do
#   And do
#     equals do
#       relation "rtest", "rtest2"
#       entity "s"
#     end
#     equals do
#       relation "rtest", "rtest2"
#       entity "t"
#     end
#
#   end
# end
#
# r = Xset.new.refine do
#   And do
#     equals do
#       relation "rtest", "rtest2"
#       entity "s"
#     end
#     Or do
#       equals do
#         relation "rtest", "rtest2"
#         entity "s"
#       end
#       equals do
#         relation "rtest", "rtest2"
#         entity "t"
#       end
#     end
#   end
# end
#
# r = Xset.new.refine{And{equals{relation "r1", "r2"; entity "s"}; equals{relation "r1", "r2"; entity "t"}}}
#
# r = Xset.new.refine do
#   Or do
#     equals do
#       relation "rtest1"
#       entity "s"
#     end
#     equals do
#       relation "rtest2"
#       entity "t"
#     end
#   end
# end
#
#
#
#
# r = Xset.new.refine do
#   equals_one do
#     relation "rtest", inverse: "rtest2"
#     entities "s", "t", "z"
#   end
# end
#
# s1 = Xset.new do
#   entities "_:p1", "_:p2", "_:p3", "_:p4"
# end
# puts s1.inspect
# s2 = Xset.new do
#   literals "p1", "p2", "p3", "p4"
# end
# puts s2.inspect
# s3 = Xset.new do
#   relations "r1", "r2", "r3", "r4"
# end
# puts s3.inspect
