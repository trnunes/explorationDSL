
Dir[File.dirname(File.absolute_path(__FILE__)) + '/**/*_test.rb'].each do |file|

  puts "------------------RUNNING #{file.to_s}----------------------"
  require file if !(file.include?("xplain_unit_test") || file.include?("functional"))
  
end