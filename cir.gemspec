Gem::Specification.new do |s|
  s.name        = 'cir'
  s.version     = '0.0.1'
  s.date        = '2016-03-31'
  s.summary     = "Configs in Repository"
  s.description = "Simple tool to manage various configuration files in repository"
  s.authors     = ["Jarek Jarcec Cecho"]
  s.email       = 'jarcec@jarcec.net'
  s.files       = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'LICENSE*']
  s.executables << 'cir'
  s.homepage    = 'https://github.com/jarcec'
  s.license     = 'Apache-2.0'

  # Dependencies
  s.add_development_dependency 'test-unit', '~> 3.1'
  s.add_runtime_dependency 'trollop', '~> 2.1'
  s.add_runtime_dependency 'rugged', '~> 0.24'

end
