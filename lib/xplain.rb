require 'set'
require 'forwardable'
require 'mixins/graph_converter'
require 'mixins/operation_factory'
require 'adapters/memory/memory_repository'
require 'mixins/config.rb'
require 'mixins/writable.rb'
require 'mixins/readable.rb'
require 'execution/workflow.rb'

require 'mixins/enumerable'
require 'mixins/relation'
require 'exceptions/missing_relation_exception'
require 'exceptions/missing_value_exception'
require 'exceptions/invalid_input_exception'
require 'exceptions/disconnected_operation_exception'
require 'exceptions/missing_auxiliary_function_exception'
require 'exceptions/numeric_item_required_exception'

require 'model/node'
require 'model/edge'
require 'model/entity'
require 'model/type'
require 'model/literal'
require 'model/schema_relation'
require 'model/computed_relation'
require 'model/path_relation'
require 'model/namespace'
require 'model/result_set'
require 'model/relation_handler'

require 'mixins/model_factory'
require 'adapters/navigational'
require 'adapters/searchable'
require 'adapters/data_server'
require 'adapters/rdf/rdf_navigational'
require 'adapters/rdf/sparql_helper'
require 'adapters/rdf/rdf_data_server'
require 'adapters/rdf/blazegraph_data_server'
require 'visualization/visualization'
require 'securerandom'
require 'operations/auxiliary_function'
require 'operations/operation'
require 'operations/set_operation'
require 'operations/group_by/grouping_relation'

require 'operations/filter/filter_factory'
require 'operations/filter/generic_filter'
require 'operations/filter/simple_filter'
require 'operations/filter/composite_filter'
require 'operations/filter/in_memory_filter_interpreter'
require 'adapters/rdf/filter_interpreter'
require 'execution/dsl_parser.rb'

module Xplain
  @@base_dir = $LOAD_PATH.grep(/xplain-/).first.to_s + "/"
  class << self
    def base_dir=(base_dir_path)
      @@base_dir = base_dir_path
    end
    
    def base_dir
      @@base_dir
    end
    
    def const_missing(name)
      
  
      instance = nil
      
      begin
        require Xplain.base_dir + "operations/" + name.to_s.to_underscore + ".rb"
        
      rescue Exception => e

        puts e.to_s
      end
      
      begin
        klass = Object.const_get "Xplain::" + name.to_s.to_camel_case
      rescue Exception => e

      end
  
      if !Xplain::Operation.operation_class? klass
        raise NameError.new("Operation #{klass.to_s} not supported!")           
      end
          
      return klass
    end
  end
end