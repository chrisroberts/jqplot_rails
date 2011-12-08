$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jqplot_rails/version'
Gem::Specification.new do |s|
  s.name = 'jqplot_rails'
  s.version = JqPlotRails::VERSION.to_s
  s.summary = 'jqPlot for Rails'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'http://bitbucket.org/chrisroberts/jqplot_rails'
  s.description = 'jqPlot for Rails'
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc']
  s.add_dependency 'rails', '~> 3.0'
  s.add_dependency 'rails_javascript_helpers', '~> 1.0'
  s.files = %w(LICENSE README.rdoc CHANGELOG.rdoc) + Dir.glob("{files,lib}/**/*")
end
