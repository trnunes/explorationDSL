module Xplain
  
  # class BaseNamespaceClass
  #   def method_missing(m, *args, &block)
  #     operation_instance = nil
  #     # begin
  #     operation_klass = Object.const_get m.capitalize
  #     args.unshift(self)
  #     operation_instance = operation_klass.new(*args, &block)
  #     # rescue
  #     #   raise "Operation not Supported!"
  #     # end
  #     operation_instance.execute
  #   end
  # end
  
  class Namespace
    @@namespace_map = {}
    attr_accessor :prefix, :uri
    class << self
      def each(&block)
        @@namespace_map.values.each &block
      end
    
      def expand_uri(uri)
        prefix, suffix = uri.to_s.split(":", 2)
        expanded_uri = uri
        if @@namespace_map.has_key?(prefix)
          expanded_uri = @@namespace_map[prefix].uri + suffix
        end        
        expanded_uri.gsub(" ", "%20")
      end
    
      def colapse_uri(uri)
        @@namespace_map.values.each do |namespace|
          if(uri.include?(namespace.uri))
            prefix = namespace.prefix 
            if uri.split(namespace.uri).size > 1
              return prefix +":"+ uri.split(namespace.uri)[1]
            end
          end
        end
        return uri
      end
    end
  
    def initialize(prefix, uri)
      @prefix = prefix
      @uri = uri
      @@namespace_map[prefix] = self
    end
  end
  Xplain::Namespace.new("owl", "http://www.w3.org/2002/07/owl#")
  Xplain::Namespace.new("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
  Xplain::Namespace.new("xsd", "http://www.w3.org/2001/XMLSchema#")
  Xplain::Namespace.new("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
  Xplain::Namespace.new("dcterms", "http://purl.org/dc/terms/")
  Xplain::Namespace.new("foaf", "http://xmlns.com/foaf/0.1/")
  Xplain::Namespace.new("rss", "http://purl.org/rss/1.0/")
  
end