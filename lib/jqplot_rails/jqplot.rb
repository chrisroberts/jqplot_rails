module JqPlotRails
  class JqPlot
    class << self
      # args:: Plugins to load. Symbols are allowed which will be camelcased automatically.
      # Enables jqplot by loading required JS and CSS. Loads all plugins if no plugins are provided. Prevent
      # any plugins loading by supplying :no_plugins
      def enable(*args)
        # Load base files first
        Dir.glob(Rails.root.join('public', 'jqplot_rails', 'javascripts', '*.js')).each do |path|
          path = File.join('/', 'jqplot_rails', 'javascripts', File.basename(path))
          ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jqplot_rails => path
          ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :plugins => path
        end
        # And now load the plugins
        unless(args.delete(:no_plugins))
          if(args.empty?)
            # NOTE: The reverse is to let us lazily load everything in the right order. If dependencies change
            # this will probably stop working at which point I'll just throw in an array with order of load
            Dir.glob(Rails.root.join('public', 'jqplot_rails', 'javascripts', 'plugins', '*.js')).reverse.each do |path|
              path = File.join('/', 'jqplot_rails', 'javascripts', 'plugins', File.basename(path))
              ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jqplot_rails => path
              ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :plugins => path
            end
          else
            args.each do |plugin|
              ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jqplot_rails => "/jqplot_rails/javascripts/jqplot.#{plugin.to_s.camelize.sub(/^./, plugin[0,1].downcase)}.min.js"
              ::ActionView::Helpers::AssetTagHelper.register_javascript_expansion :plugins => "/jqplot_rails/javascripts/jqplot.#{plugin.to_s.camelize.sub(/^./, plugin[0,1].downcase)}.min.js"
            end
          end
        end
        ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :jqplot_rails => '/jqplot_rails/stylesheets/jquery.jqplot.min.css'
        ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :plugins => '/jqplot_rails/stylesheets/jquery.jqplot.min.css'
        ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :jqplot_rails => '/jqplot_rails/stylesheets/jqplot_rails_overrides.css'
        ::ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :plugins => '/jqplot_rails/stylesheets/jqplot_rails_overrides.css'
      end
    end
  end
end
