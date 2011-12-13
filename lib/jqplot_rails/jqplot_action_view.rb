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
      _j_wrap(opts[:raw], output)
    end

    # dom_id:: DOM ID used for the plot
    # opts:: Ooptions hash for building plot binding
    #   - :function -> RawJS instance with full function defined
    #   - :link_to -> {:url, :remote}
    # Bind to click event on data and make request
    def jqplot_data_onclick(dom_id, opts={})
      output = jqplot_setup
      raise 'Only :function or :link_to may be defined, not both.' if opts[:function].present? && opts[:link_to].present?
      raise 'Must provide :function or :link_to for event.' if opts[:function].blank? && opts[:link_to].blank?
      function = opts[:link_to].present? ? _j_build_click_url_event(dom_id, opts[:link_to]) : opts[:function]
      output << jqplot_exists(dom_id) do
        "jQuery(#{format_type_to_js(format_id(dom_id))}).bind('jqplotDataClick', #{format_type_to_js(function)});".html_safe
      end
      _j_wrap(opts[:raw], output)
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
      _j_wrap(args.include?(:raw), output)
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
      _j_wrap(args.include?(:raw), output)
    end

    private
  
    # Setups up environment for plots (creates storage area)
    def jqplot_setup
      output = ''
      unless(@_jqplot_setup)
        output << 'if(window._jqplot_rails == undefined){ window._jqplot_rails = {}; }'
      end
      output.html_safe
    end

    # dom_id:: DOM ID used for the plot
    # Check for plot instance before continuing
    def jqplot_exists(dom_id)
      "if(window._jqplot_rails['#{_j_key(dom_id)}'] != undefined){ #{yield} } else { alert('Failed to locate requested plot instance'); }".html_safe
    end

    # dom_id:: DOM ID used for the plot
    # Returns the plot instance
    def jqplot_instance(dom_id)
      "window._jqplot_rails['#{_j_key(dom_id)}']".html_safe
    end

    # key:: DOM ID for plot
    # Helper to remove hash prefix if found
    def _j_key(key)
      key.sub('#', '').html_safe
    end

    # raw:: Boolean. Raw or wrapped string
    # string:: Javascript string
    # Helper to wrap javascript within tag if required
    def _j_wrap(raw, string)
      raw ? string.html_safe : javascript_tag{ string.html_safe }
    end

    # opts:: Hash
    #   - :url -> Path or symbole
    #   - :use_ticks -> Map index to tick name and pass tick name instead (true defaults to x-axis or :x/:y)
    #   - :remote -> Boolean for ajax call
    #   - :args -> extra arguments for url building
    def _j_build_click_url_event(dom_id, opts={})
      output = 'function(ev, seriesIndex, pointIndex, data){'
      index = opts[:use_ticks] ? "#{jqplot_instance(dom_id)}.axes.#{opts[:use_ticks] == :y ? 'y' : 'x'}axis.ticks[data[0] - 1]" : "data[0]"
      if(opts[:url].is_a?(Symbol))
        args = ['000']
        args += opts[:args] if opts[:args].present?
        url = RawJS.new("'#{Rails.application.routes.url_helpers.send(opts[:url].to_s.sub('_url', '_path').to_sym, *args)}'.replace('000', #{index})")
      else
        url = RawJS.new("'#{opts[:url]}#{opts[:url].include?('?') ? '&' : '?'}jqplot_id='+#{index}")
      end
      if(opts[:remote])
        output << "jQuery.get(#{format_type_to_js(url)}, null, 'script');"
      else
        output << "window.location = #{format_type_to_js(url)};"
      end
      output << '}'
      output.html_safe
    end
  end
end

ActionView::Base.send(:include, JqPlotRails::ActionView)
