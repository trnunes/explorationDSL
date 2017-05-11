module Explorable
  class Rank < Explorable::Operation
    
    def eval
      start_time = Time.now
      multiplier = -1

      if(@args[:order] == "ASC")
        multiplier = 1
      end
      mappings = {}
      ranking_function = @args[:ranking_function]
      ranking_function ||= Ranking.alpha_rank
      ranking_function.source_set = @args[:input]
    
      mappings = @args[:input].each_image.to_a.sort do |item1, item2|
        comparable1 = item1
        comparable2 = item2

        score_1 = ranking_function.score(comparable1)
        score_2 = ranking_function.score(comparable2)
        # binding.pry
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
      puts "EXECUTED RANK: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "rank(#{@args[:input].id}){#{@args[:ranking_function].expression}}"
    end
  end
  
  def rank(args = {}, &block)
    if(block_given?)
      args[:ranking_function] = yield(Ranking)
    end
    
    execute_operation(Rank, args)
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
#         # binding.pry
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
#       puts "EXECUTED RANK: " << (finish_time - start_time).to_s
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