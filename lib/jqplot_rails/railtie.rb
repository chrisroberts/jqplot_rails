module JqPlotRails
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'jqplot_rails/tasks'
    end

    config.to_prepare do
      require 'jqplot_rails/jqplot_action_view'
      # Load base files first
      Dir.glob(Rails.root.join('public', 'jqplot_rails', 'javascripts', '*.js')).each do |path|
        path = File.join('/', 'jqplot_rails', 'javascripts', File.basename(path))
        ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jqplot_rails => path
        ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :plugins => path
      end
      # And now load the plugins
      # NOTE: The reverse is to let us lazily load everything in the right order. If dependencies change
      # this will probably stop working at which point I'll just throw in an array with order of load
      Dir.glob(Rails.root.join('public', 'jqplot_rails', 'javascripts', 'plugins', '*.js')).reverse.each do |path|
        path = File.join('/', 'jqplot_rails', 'javascripts', 'plugins', File.basename(path))
        ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jqplot_rails => path
        ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :plugins => path
      end
      ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :jqplot_rails => '/jqplot_rails/stylesheets/jquery.jqplot.min.css'
      ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :plugins => '/jqplot_rails/stylesheets/jquery.jqplot.min.css'
      ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :jqplot_rails => '/jqplot_rails/stylesheets/jqplot_rails_overrides.css'
      ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :plugins => '/jqplot_rails/stylesheets/jqplot_rails_overrides.css'
    end
  end
end
