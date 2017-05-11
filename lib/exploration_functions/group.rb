module Explorable
  class Group < Explorable::Operation
    attr_accessor :grouping_function
    def horizontal?
      grouping_function.horizontal?
    end
    def eval
      start_time = Time.now
      input_set = @args[:input]
      @grouping_function = @args[:function]
      mappings = {}
      result_relation_index = {}
      parents_hash = {}
      # binding.pry
      if input_set.has_subsets?
        input_set.each_image do |subset|
        # binding.pry
          grouped_subset = subset.group{grouping_function}
          if(!grouped_subset.empty?)
            mappings[subset] = Xsubset.new(subset.key){|s|s.server = input_set.server; s.extension = grouped_subset.extension}
          end
          # binding.pry
        end
      else
        groups = grouping_function.group(input_set)
        mappings = {}
        groups.each do |group_key, group_values|
          
          subset = Xsubset.new(group_key){|s| s.server = input_set.server; s.extension = group_values}
          subset.server = input_set.server
          mappings[group_key] = subset
          # binding.pry
        end    
      end
      finish_time = Time.now
      puts "EXECUTED GROUP: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "group(#{@args[:input].id}){#{@args[:function].expression}}"
    end
  end
  
  def group(args = {})
    args[:function] = yield(Grouping)
    execute_operation(Group, args)
  end
end