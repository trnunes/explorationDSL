module Xplain
  class Item
    extend ItemFactory
    #TODO Analyze the possibility of moving text and text_relation to nodes
    attr_accessor :id, :text, :server, :type, :text_relation

    #TODO standardize all initializers to receive hashes
    def self.create(id, text="", server=Xplain.default_server)
      super(id: id, text: text, server: server)
    end
    
    def initialize(params = {})
      @id = params[:id]
      @text = params[:text]
      @server = params[:server] || Xplain.default_server
      @type = params[:type]
      @text_relation = params[:text_relation]
      @text_relation = "xplain:has_text" if @text_relation.to_s.empty?
       
    end
    def <=>(other_entity)
      self.text <=> other_entity.text 
    end
    
    def text=(t)
      @text = t if !t.to_s.strip.empty?
    end
    
    def text_relation=(r)
      @text_relation = r if !r.to_s.strip.empty?
    end
    
    def text
      if @text.to_s.empty?
        return Xplain::Namespace.colapse_uri(id)
      end
      @text
    end
    
    def add_server(server)
      @server = server
    end
  
    def to_s
      "Item #{self.class.name}: " + id + " : " + text.to_s
    end
  
    def inspect
      to_s
    end
    
  
    def eql?(item)
      if !item.respond_to? :id
        return false
      end
      @id == item.id
    end    
  
    def hash
      @id.hash
    end
  
    alias == eql?


    def method_missing(m, *args, &block)
      RelationHandler.new(self).handle_call(m, *args, &block)
    end
    
  end
end