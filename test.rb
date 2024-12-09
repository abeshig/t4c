require 'minitest/autorun'
Dir.chdir(File.dirname(__FILE__))
for f in Dir.glob('**/*_test.rb') do
  require_relative f
end