class RelationHandler
  def initialize(item)
    @item = Xplain::Node.new item: item
  end
  
  def handle_call(m, *args, &block)
    relation_id = ""
    relation_ns = ""
    relation_name = m.to_s
    
    if m.to_s.include?('__')
      relation_ns = m.to_s.split('__').first
      relation_name = m.to_s.split('__').last
      relation_id = relation_ns + ':'
    end
    relation_id += relation_name
    
    inverse = false
    if !args.empty?
      inverse = (args.first == :inverse)
    end
    
    relation = Xplain::SchemaRelation.new(server: Xplain.default_server, id: relation_id, inverse: inverse)
    relation.restricted_image([@item]).sort_asc
  end
end