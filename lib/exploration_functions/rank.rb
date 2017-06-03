module Explorable
  class Rank < Explorable::Operation
    
    def prepare(args)
      @args[:ranking_function].prepare(args, @args[:input].server)
    end
    
    def compare(item1, item2)
      score_1 = @ranking_function.score(item1)
      score_2 = @ranking_function.score(item2)

      comparison = (score_1 <=> score_2 )
      if comparison.nil?
        if score_1 == -Float::INFINITY
          1
        elsif score_2 == -Float::INFINITY
          -1
        else
          (score_1.to_s <=> score_2.to_s) * @multiplier
        end 
      else
        (score_1 <=> score_2 ) * @multiplier
      end
    end
    
    def is_last_level(index_entries)
      index_entries.each{|entry| return false if !entry.children.empty?}
      return true
    end
    
    def domain_rank(index_entries)

      sorted_entries = index_entries.sort do |entry1, entry2|
        comparison_value = 1
        if(@args[:position] == "domain")
          comparison_value = compare(entry1.indexing_item, entry2.indexing_item)
        else
          entry1.indexed_items.each do |item1|
            entry2.indexed_items.each do |item2|
              comparison_value = compare(item1, item2)
            end
          end
        end
        comparison_value
      end
      index_entries.first.parent.children = sorted_entries
    end
    
    def eval_set(index_entries)
      @ranking_function = @args[:ranking_function]
      @ranking_function ||= Ranking.alpha_rank
      @multiplier = -1

      if(@args[:order] == "ASC")
        @multiplier = 1
      end
      
      rank_by_domain = @ranking_function.domain_rank? || (@args[:position] == "domain")

      if(rank_by_domain && is_last_level(index_entries))

        domain_rank(index_entries)


      else
        
        index_entries.each do |index_entry|
        
          if(index_entry.children.empty?)
            self.prepare(@args)

            sorted_entries = index_entry.indexed_items.sort do |item1, item2|
              compare(item1, item2)
            end
            index_entry.indexed_items = sorted_entries
          else
            eval_set(index_entry.children)
          end
        end
      end
    end
    
    def eval_items(item1, item2)
      start_time = Time.now
      multiplier = -1

      if(@args[:order] == "ASC")
        multiplier = 1
      end
      mappings = {}
    
      mappings = @args[:input].each_item.to_a.sort do |item1, item2|
        comparable1 = item1
        comparable2 = item2

        score_1 = ranking_function.score(comparable1)
        score_2 = ranking_function.score(comparable2)

        comparison = (score_1 <=> score_2 )
        if comparison.nil?
          if score_1 == -Float::INFINITY
            1
          elsif score_2 == -Float::INFINITY
            -1
          else
            (score_1.to_s <=> score_2.to_s) * multiplier
          end
                  
        else
          (score_1 <=> score_2 ) * multiplier
        end      
      end.map{|i| [i, {}]}.to_h
      finish_time = Time.now

      mappings
    end
    
    def v_expression
      "Rank_#{@args[:position].to_s.downcase}_"+@args[:order].to_s.downcase+"(#{@args[:ranking_function].expression})"
    end
    
    def expression
      "#{@args[:input].id}.rank_#{@args[:position].to_s.downcase}_"+@args[:order].to_s.downcase+"(#{@args[:ranking_function].expression})"
    end
  end
  
  def rank(args = {}, &block)
    if(block_given?)
      args[:ranking_function] = yield(Ranking)
    end
    
    execute_exploration_operation(Rank, args)
  end
  
  def v_rank(args = {}, &block)
    if(block_given?)
      args[:ranking_function] = yield(Ranking)
    end
    execute_visualization_operation(Rank, args)
  end
  
end
# module Explorable
#   class Rank < Explorable::Operation
#
#     def eval
#       start_time = Time.now
#       multiplier = -1
#
#       if(@args[:order] == "ASC")
#         multiplier = 1
#       end
#       mappings = {}
#       ranking_function = @args[:ranking_function]
#       ranking_function ||= Ranking.alpha_rank
#       ranking_function.source_set = @args[:input]
#
#       mappings = @args[:input].extension.sort do |item1_array, item2_array|
#         comparable1 = (item1_array[1].nil? || item1_array[1].empty?) ? item1_array[0] : item1_array[1]
#         comparable2 = (item2_array[1].nil? || item2_array[1].empty?) ? item2_array[0] : item2_array[1]
#
#         score_1 = ranking_function.score(comparable1)
#         score_2 = ranking_function.score(comparable2)

#         comparison = (score_1 <=> score_2 )
#         if comparison.nil?
#           if score_1 == -Float::INFINITY
#             1
#           elsif score_2 == -Float::INFINITY
#             -1
#           else
#             (score_1.to_s <=> score_2.to_s) * multiplier
#           end
#
#         else
#           (score_1 <=> score_2 ) * multiplier
#         end
#       end.to_h
#       finish_time = Time.now

#       mappings
#     end
#
#     def expression
#       "rank(#{@args[:input].id}){#{@args[:ranking_function].expression}}"
#     end
#   end
#
#   def rank(args = {}, &block)
#     if(block_given?)
#       args[:ranking_function] = yield(Ranking)
#     end
#
#     execute_operation(Rank, args)
#   end
# end