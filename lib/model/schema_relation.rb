module Xplain
  class SchemaRelation
    include Xplain::Relation
    attr_accessor :id, :server, :root, :inverse, :cursor, :text
  
    def initialize(args={})
      @id = args[:id]
      @text = args[:text]
      @server = server
      @inverse = args[:inverse] || false
      @server = args[:server] || Xplain.default_server
      @root = Node.new(self)
    end
    
    def schema?
      true
    end
    
    def reverse
      Xplain::SchemaRelation.new(id: id, inverse: !inverse?)
    end
    
    def image(offset=0, limit=nil)
        ResultSet.new(@server.image(self, [], offset, limit))
    end
  
    def domain(offset=0, limit=-1)
        ResultSet.new(@server.domain(self, [], offset, limit))
    end
  
    def restricted_image(restriction, options= {})
      options[:restriction] = restriction
      options[:relation] = self
      ResultSet.new(@server.restricted_image(options))
    end
  
    def restricted_domain(restriction, options = {})
      options[:restriction] = restriction
      options[:relation] = self
      ResultSet.new(@server.restricted_domain(options))
    end
    
    def group_by_image(nodes)
      ResultSet.new(@server.group_by(nodes, self))
    end
  end
end