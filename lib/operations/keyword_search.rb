class Xplain::KeywordSearch < Xplain::Operation
  def initialize(args = {}, &block)
    super(args, &block)
    @keyword_phrase = args[:keyword_phrase]
  end
  
  ##return a set of nodes
  def get_results()
    restriction_nodes = []
    
    if !(@inputs.nil? || @inputs.empty? || @inputs.first.empty?)
      restriction_nodes= inputs.first.to_tree.leaves
    end
    results = @server.match_all(parse_keyword_phrase(), restriction_nodes)    
    results.map{|item| Node.new(item)}
  end
  
  def validate()
    if @keyword_phrase.to_s.empty?
      raise MissingArgumentException.new('keyword phrase', 'Keyword Search')
    end      
  end
  
  #TODO implement the parsing of disjunctive keywords, separated by "|"
  def parse_keyword_phrase()
    @keyword_phrase.to_s.split(" ")
  end
  
end