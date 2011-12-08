require 'fileutils'

namespace :jqplot_rails do

  desc 'Install jqPlot Rails'
  task :install do
    FileUtils.mkdir_p(File.join(Rails.root, 'public', 'jqplot_rails'))
    Rake::Task['jqplot_rails:install_javascripts'].invoke
    Rake::Task['jqplot_rails:install_stylesheets'].invoke
    Rake::Task['jqplot_rails:install_version'].invoke
    puts 'jqPlot Rails installation complete'
  end

  task :install_javascripts do
    jqplot_install_items('javascripts')
  end

  task :install_stylesheets do
    jqplot_install_items('stylesheets')
  end

  task :install_version do
    f = File.open(File.join(Rails.root, 'public', 'jqplot_rails', 'version'), 'w')
    f.write JqPlotRails::VERSION
    f.close
    puts 'Version file written'
  end

  desc 'Output current version information'
  task :version do
    asset_version = nil
    if(File.exists?(File.join(Rails.root, 'public', 'jqplot_rails', 'version')))
      asset_version = File.read(File.join(Rails.root, 'public', 'jqplot_rails', 'version')).strip
    end
    puts "Current jqPlot Rails version: #{JqPlotRails::VERSION}"
    puts "Current jqPlot Rails assets version: #{asset_version}"
    if(JqPlotRails::VERSION != asset_version.to_s)
      puts "WARNING #{'*' * 50}"
      puts 'jqPlot Rails assets within project are out of date'
      puts 'Please run: rake jqplot_rails:install'
      puts "WARNING #{'*' * 50}"
    end
  end
end

def jqplot_install_items(item)
  if(File.directory?(File.join(File.dirname(__FILE__), '..', '..', 'files', item)))
    FileUtils.mkdir_p(File.join(Rails.root, 'public', 'jqplot_rails', item))
    FileUtils.cp_r(
      File.join(File.dirname(__FILE__), '..', '..', 'files', item, File::SEPARATOR, '.'), 
      File.join(Rails.root, 'public', 'jqplot_rails', item)
    )
    puts "#{item.titleize} files installed."
  else
    puts "Nothing to install for: #{item}"
  end
end

