module Xplain
  module Visualization
    @@labels_by_type = {}
    @@image_label_relations_hash = {}
    @@domain_label_relations_hash = {}

    def self.label_relations_for(type)
      
      @@labels_by_type[Xplain::Namespace.expand_uri(type)] || []
    end
  
    def self.label_for_type(type, *relations)
      if !@@labels_by_type.has_key?(Xplain::Namespace.expand_uri(type))
        @@labels_by_type[Xplain::Namespace.expand_uri(type)] = []
      end
      relations.each do |r|
        @@labels_by_type[Xplain::Namespace.expand_uri(type)] << Xplain::Namespace.expand_uri(r)
      end
    end
    
    def self.label_for_image(relation, label_relation)
      @@image_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] = [Xplain::Namespace.expand_uri(label_relation)]
    end
    
    def self.label_for_domain(relation, label_relation)
      @@domain_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] = [Xplain::Namespace.expand_uri(label_relation)]
    end
    
    def self.label_relations
      @@labels_by_type.values.flatten
    end
    
    def self.domain_label_relations(relation)
      @@domain_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] || []
    end
    
    def self.image_label_relations(relation)

      @@image_label_relations_hash[Xplain::Namespace.expand_uri(relation.id)] || []
    end
    
    def self.types
      @@labels_by_type.keys
    end
  end
end