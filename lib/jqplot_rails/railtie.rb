module JqPlotRails
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'jqplot_rails/tasks'
    end

    config.to_prepare do
      require 'jqplot_rails/jqplot_action_view'
      require 'jqplot_rails/jqplot'
    end
  end
end
