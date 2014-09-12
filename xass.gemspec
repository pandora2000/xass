Gem::Specification.new do |s|
  s.name = 'xass'
  s.version = '0.2.0'
  s.authors = ['Tetsuri Moriya']
  s.email = ['tetsuri.moriya@gmail.com']
  s.summary = 'Sass namespace extension'
  s.description = 'Namespace in sass'
  s.homepage = 'https://github.com/pandora2000/xass'
  s.license = 'MIT'
  s.files = `git ls-files`.split("\n")
  s.add_development_dependency 'rspec', '>= 0'
  s.add_development_dependency 'rails', '>= 0'
  s.add_development_dependency 'haml', '>= 0'
  s.add_runtime_dependency 'activesupport', '~> 4.0'
  s.add_runtime_dependency 'sass', '>= 0'
  s.add_runtime_dependency 'csspool', '>= 0'
  s.add_runtime_dependency 'nokogiri', '>= 0'
end
