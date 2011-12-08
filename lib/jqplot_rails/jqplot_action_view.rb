require 'rails_javascript_helpers'

module JqPlotRails
  module ActionView

    include RailsJavaScriptHelpers

    # dom_id:: DOM ID to contain plot (also used for referencing instance)
    # data:: Array of plot data
    # opts:: Options hash provided to jqplot
    # Creates a new plot instance
    # NOTE: If :raw => true is passed in the opts, the result will be the raw javascript not wrapped within tags
    def jqplot(dom_id, data, opts={})
      output = jqplot_setup
      output << "window._jqplot_rails['#{_j_key(dom_id)}'] = jQuery.jqplot('#{_j_key(dom_id)}', #{format_type_to_js(data)}, #{format_type_to_js(opts)});".html_safe
      if(opts.delete(:raw))
        output
      else
        javascript_tag do
          output
        end
      end
    end

    # dom_id:: DOM ID used for the plot
    # args:: Extra arguments
    # Resets the plot to its original state
    # NOTE: If :raw is passed in the args, the result will be the raw javascript not wrapped within tags
    def jqplot_reset_plot(dom_id, *args)
      output = jqplot_setup
      output << jqplot_exists(dom_id) do
        "#{jqplot_instance(dom_id)}.replot({clear:true,resetAxes:true});"
      end
      if(args.include?(:raw))
        output.html_safe
      else
        javascript_tag do
          output.html_safe
        end
      end
    end

    # text:: Button text
    # dom_id:: DOM ID used for the plot
    # args:: Extra arguments passed to #button_to_function
    # Returns a button for resetting the given plot
    def jqplot_reset_plot_button(text, dom_id, *args)
      button_to_function(text, jqplot_reset_plot(dom_id, :raw), *args)
    end

    # text:: Link text
    # dom_id:: DOM ID used for the plot
    # args:: Extra arguments passed to #link_to_function
    # Returns a link for resetting the given plot
    def jqplot_reset_plot_link(text, dom_id, *args)
      link_to_function(text, jqplot_reset_plot(dom_id, :raw), *args)
    end

    # dom_id:: DOM ID used for the plot
    # args:: Extra arguments
    # Makes the provided plot resizable
    # NOTE: If :raw is passed in the args, the result will be the raw javascript not wrapped within tags
    def jqplot_resizable(dom_id, *args)
      resize_args = args.last if args.last.is_a?(Hash)
      resize_args ||= {:delay => 20}
      output = jqplot_setup
      output << jqplot_exists(dom_id) do
        "jQuery(#{format_type_to_js(format_id(dom_id))}).resizable(#{format_type_to_js(resize_args)});" +
        "jQuery(#{format_type_to_js(format_id(dom_id))}).bind('resize', function(event,ui){ #{jqplot_instance(dom_id)}.replot(); });"
      end
      if(args.include?(:raw))
        output.html_safe
      else
        javascript_tag{ output.html_safe }
      end
    end

    private

    def jqplot_setup
      output = ''
      unless(@_jqplot_setup)
        output << 'if(window._jqplot_rails == undefined){ window._jqplot_rails = {}; }'
      end
      output
    end

    # dom_id:: DOM ID used for the plot
    # Check for plot instance before continuing
    def jqplot_exists(dom_id)
      "if(window._jqplot_rails['#{_j_key(dom_id)}'] != undefined){ #{yield} } else { alert('Failed to locate requested plot instance'); }".html_safe
    end

    # dom_id:: DOM ID used for the plot
    # Returns the plot instance
    def jqplot_instance(dom_id)
      "window._jqplot_rails['#{_j_key(dom_id)}']"
    end

    def _j_key(key)
      key.sub('#', '')
    end
  end
end

ActionView::Base.send(:include, JqPlotRails::ActionView)
