module Xplain
  class SchemaRelation
    include Xplain::Relation
    attr_accessor :id, :server, :root, :inverse, :cursor, :text
  
    def initialize(args={})
      @id = args[:id]
      @text = args[:text]
      @server = server
      @inverse = args[:inverse] || false
      @server = args[:server]
      @root = Node.new(self)
    end
  
    def fetch_graph(items, limit=nil, offset=nil)
      restricted_image(items, {limit: limit, offset: offset}).map{|item| item.parent}.uniq
    end
  
    def schema?
      true
    end
    
    def reverse
      Xplain::SchemaRelation.new(id: id, inverse: !inverse?)
    end
  
    def to_s
      @id
    end
  
    def get_level(level, parents_restriction = [], children_restriction = [], offset = 0, limit = -1)
      if(level == 2)
        if(!children_restriction.empty?)
          fetch_restricted_domain(children_restriction, {offset: offset, limit: limit})
        else
          domain(offset, limit)
        end
      elsif (level == 3)
        if(!parents_restriction.empty?)
          fetch_restricted_image(parents_restriction, {offset: offset, limit: limit})
        else
          image(offset, limit)
        end      
      
      end
    end
  
  
    def image(offset=0, limit=nil)
        @server.image(self, [], offset, limit)
    end
  
    def domain(offset=0, limit=-1)
        @server.domain(self, [], offset, limit)
    end
  
  
    def each_domain(offset=0, limit=-1, &block)

      domains = domain(offset, limit)
      domains.each &block
      domains
    end
  
    def each_image(offset=0, limit=-1, &block)
      image(offset, limit).each &block    
    end
  
    def fetch_restricted_image(restriction, options= {})
      options[:restriction] = restriction
      options[:relation] = self
      @server.restricted_image(options)
    end
  
    def fetch_restricted_domain(restriction, options = {})
      options[:restriction] = restriction
      options[:relation] = self
      @server.restricted_domain(options)
    end
  
    def leaves()
      image()
    end
  
    def inverse?
      @inverse
    end
  
    def inspect
      to_s
    end
    
    def eql?(relation)
      relation.is_a?(self.class) && relation.id == self.id && relation.inverse? == self.inverse?
    end
  
    def hash
      @id.hash * @inverse.hash
    end
  
    alias == eql?
    
  end
end