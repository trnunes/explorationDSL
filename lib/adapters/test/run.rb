Dir[File.dirname(File.absolute_path(__FILE__)) + '/**/*_test.rb'].each do |file|
  puts "---------------RUNNING------------"
  puts file.to_s
  require file
  
end