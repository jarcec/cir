require 'rake/testtask'
require 'yard'

# rake test: run tests
Rake::TestTask.new do |t|
    t.libs << 'test'
end

# rake yard: Generate API docs
YARD::Rake::YardocTask.new

# And by default run tests
task :default => :test
