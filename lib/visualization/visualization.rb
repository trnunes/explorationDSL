module Xpair
  module Visualization
    @@labels_by_type = {}
    @@image_label_relations_hash = {}
    @@domain_label_relations_hash = {}

    def self.label_relations_for(type)
      @@labels_by_type[Xpair::Namespace.expand_uri(type)] || []
    end
  
    def self.label_for_type(type_id, *relation_ids)
      if !@@labels_by_type.has_key?(Xpair::Namespace.expand_uri(type_id))
        @@labels_by_type[Xpair::Namespace.expand_uri(type_id)] = []
      end
      relation_ids.each do |r_id|
        @@labels_by_type[Xpair::Namespace.expand_uri(type_id)] << Xpair::Namespace.expand_uri(r_id)
      end
    end
    
    def self.label_for_image(relation_id, label_relation)
      @@image_label_relations_hash[Xpair::Namespace.expand_uri(relation_id)] = [Xpair::Namespace.expand_uri(label_relation)]
    end
    
    def self.label_for_domain(relation_id, label_relation)
      @@domain_label_relations_hash[Xpair::Namespace.expand_uri(relation_id)] = [Xpair::Namespace.expand_uri(label_relation)]
    end
    
    def self.label_relations
      @@labels_by_type.values.flatten
    end
    
    def self.domain_label_relations(relation_id)
      @@domain_label_relations_hash[Xpair::Namespace.expand_uri(relation_id)] || []
    end
    
    def self.image_label_relations(relation_id)
      @@image_label_relations_hash[Xpair::Namespace.expand_uri(relation_id)] || []
    end
    
    def self.types
      @@labels_by_type.keys
    end
  end
end