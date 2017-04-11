
Dir[File.dirname(File.absolute_path(__FILE__)) + '/**/*_test.rb'].each do |file|


  require file if !(file.include?("xpair_unit_test"))
  
end