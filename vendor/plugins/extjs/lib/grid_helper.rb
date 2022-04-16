module ExtJS
  module GridHelper

    # This helper does not use asset_packager when available,
    # due extjs files was merged with other application js files usually.
    # So you should add these files into rules by hand
    if Rails.env.production?
      def ext_js_include
        libraries = %w{ ext-base ext-all ext-custom-renderers ext-fixes grid/GridExtensions }
        content = stylesheet_link_tag 'ext-all'
        content << javascript_include_tag(*libraries)
        content
      end
    else
      def ext_js_include
        libraries = %w{ ext-base ext-all-debug ext-custom-renderers ext-fixes grid/GridExtensions }
        content = stylesheet_link_tag 'ext-all'
        content << javascript_include_tag(*libraries)
        content
      end
    end

    def grid_fields(mapping)
      mapping.map { |value| "'#{value[:grid_id] || value[:method]}'" }.join(',').html_safe
    end

    def grid_columns(mapping, editors = {})
      editors ||= {}

      mapping.map do |value|
        js_id = value[:grid_id] || value[:method]
        config = "{id: '#{js_id}', dataIndex: '#{js_id}', header: '#{value[:title]}', sortable: #{value[:sortable]}"
        config << ", hidden: #{value[:hidden]}" if value[:hidden]
        config << ", renderer: #{value[:renderer]}" if value[:renderer]
        config << ", summaryType: '#{value[:summary_type]}'" if value[:summary_type]
        config << ", summaryRenderer: #{value[:summary_renderer]}" if value[:summary_renderer]
        if editors[js_id] && !editors[js_id].blank?
          editor = editors[js_id].dup
          config << ", editor: new #{editor.delete(:type)}({"
          config << "store: #{editor.delete(:store)}," if editor.has_key?(:store)
          config << "tpl: #{editor.delete(:tpl)}," if editor.has_key?(:tpl)
          config << editor.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last.to_json}" }.compact.join(',')
          config << "})"
        end
        config << '}'
        config
      end.join(',').html_safe
    end

    def record_variable(class_name, editors)
      result = "var #{class_name} = Ext.data.Record.create(["
      result << editors.map do |key, value|
        row = '{'
        row << "name: '#{key}'"
        # TODO: check this for number fields and other custom types
        # row << ", type: '#{value[:simple_type]}'" if value[:simple_type]
        row << ", type: '#{value[:type]}'" if value[:type]
        row << '}'
      end.join(',')
      result << ']);'
      result
    end

    def summary_required?(mapping)
      mapping.any? { |value| value[:summary_type] }
    end

    def render_grid(options = {}, &block)
      html_options = {
        :id => 'data_grid',
        :class => 'grid-container'
      }.merge(options[:html] || {})

      grid_key = options.delete(:grid_for) || controller_name

      filters = options[:klass].grid_filters_for(grid_key)
      if filters
        js_files = if ::ASSET_PACKAGER_INSTALLED
          javascript_include_merged :grid_filters
        else
          javascript_include_tag(
            'menu/EditableItem',
            'menu/RangeMenu',
            'grid/GridFilters',
            'grid/filter/Filter',
            'grid/filter/StringFilter',
            'grid/filter/DateFilter',
            'grid/filter/ListFilter',
            'grid/filter/NumericFilter',
            'grid/filter/BooleanFilter')
        end
        content_for(:head, js_files)
      end

      if options[:search_bar]
        content_for(:head, ::ASSET_PACKAGER_INSTALLED ? javascript_include_merged(:forms) : javascript_include_tag('form/SearchField'))
      end

      mapping = options[:klass].grid_mapping_for(grid_key)
      editors = options[:klass].grid_editors_for(grid_key)

      render_options = {
        :title => options[:title],
        :div_id => html_options[:id],
        :url => options[:url],
        :mapping => mapping,
        :editors => editors,
        :items_title => options[:items_title] || options[:klass].to_s.downcase.pluralize,
        :class_name => options[:klass].to_s,
        :search_bar => options[:search_bar] || false,
        :print_button => options[:print_button] || false,
        :filters => filters,
        :stateful => (options[:stateful].blank? ? true : options[:stateful]),
        :default_sort => options[:default_sort] || [mapping.first[:grid_id] || mapping.first[:method], 'asc'],
        :select_multiple_rows => options[:select_multiple_rows] || false,
        :custom_elements => block_given? ? capture(&block) : nil
      }

      size = options.delete(:size) || ''
      render_options[:width], render_options[:height] = size.split("x")

      content = javascript_tag(render(:partial => 'shared/grid.js.erb', :locals => render_options))
      content << content_tag(:div, '', html_options)

      if block_given?
        safe_concat(content)
        nil
      else
        content
      end
    end
  end
end
