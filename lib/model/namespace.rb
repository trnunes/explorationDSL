module Xplain
    
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
end