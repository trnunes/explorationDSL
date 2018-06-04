Gem::Specification.new do |s|
  s.name        = 'xplain'
  s.version     = '0.0.1'
  s.date        = '2018-05-14'
  s.summary     = "Xplain"
  s.description = "XPlain exploration DSL"
  s.authors     = ["Thiago Nunes"]
  s.email       = 'thiagorinu@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/**/*.rb')
  s.require_paths      = %w(lib)
  s.homepage    =
    'https://github.com/trnunes/explorationDSL'
  s.license       = 'MIT'
end