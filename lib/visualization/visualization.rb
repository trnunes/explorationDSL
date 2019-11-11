module Xplain
  module Visualization
    class Profile
      #TODO implement profiles creation, update, load and list
      
      attr_accessor :name
      def initialize(name)
        @labels_by_type = {}
        @image_label_relations_hash = {}
        @domain_label_relations_hash = {}
        @text_properties_hash = {}
        @inverse_relation_hash = {}
        @name = name
      end
      
      
      def set_view_properties(nodes)
        nodes.each do |node| 
          if !node.item.is_a? Xplain::Literal
            node.item.text = @text_properties_hash[Xplain::Namespace.expand_uri(node.item.id)].dup if @text_properties_hash[Xplain::Namespace.expand_uri(node.item.id)]
          end
        end
      end
      
      def inverse_relation_text_for(relation_id, text)
        @inverse_relation_hash[Xplain::Namespace.expand_uri(relation_id)] = text
      end
      
      def inverse_relation_text(relation_id)
        @inverse_relation_hash[Xplain::Namespace.expand_uri(relation_id)]
      end
      
      def text_for(item_id, text)
        @text_properties_hash[Xplain::Namespace.expand_uri(item_id)] = text
      end
      
      def label_relations_for(type)
        
        @labels_by_type[Xplain::Namespace.expand_uri(type)] || []
      end
    
      def label_for_type(type, *relations)
        if !@labels_by_type.has_key?(Xplain::Namespace.expand_uri(type))
          @labels_by_type[Xplain::Namespace.expand_uri(type)] = []
        end
        relations.each do |r|
          @labels_by_type[Xplain::Namespace.expand_uri(type)] << Xplain::Namespace.expand_uri(r)
        end
      end
      
      def label_for_image(relation, label_relation)
        @image_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] = [Xplain::Namespace.expand_uri(label_relation)]
      end
      
      def label_for_domain(relation, label_relation)
        @domain_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] = [Xplain::Namespace.expand_uri(label_relation)]
      end
      
      def label_relations
        @labels_by_type.values.flatten
      end
      
      def domain_label_relations(relation)
        @domain_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] || []
      end
      
      def image_label_relations(relation)
  
        @image_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] || []
      end
      
      def types
        @labels_by_type.keys
      end
    end
    @@current_profile = Profile.new('default')
    
    def self.current_profile
      @@current_profile    
    end

  end
  

end