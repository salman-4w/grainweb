module ActionView::Helpers
  module FormHelper
    def form_for(record_or_name_or_array, *args, &block)
      raise ArgumentError, "Missing block" unless block_given?

      options = args.extract_options!

      case record_or_name_or_array
      when String, Symbol
        object_name = record_or_name_or_array
      when Array
        object = record_or_name_or_array.last
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!(record_or_name_or_array, options)
        args.unshift object
      else
        object = record_or_name_or_array
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!([object], options)
        args.unshift object
      end

      form_options = (options.delete(:html) || {}).merge(
        :object => object,
        :object_name => object_name
      )

      form_tag(options.delete(:url) || {}, form_options, &block)
    end

    def button(title, options = {})
      html_id = options.delete(:id) || "#{title.underscore}-button"

      button_options = options.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last}" }.join(',')
      button_options << "," unless button_options.blank?

      content = '<script type="text/javascript" charset="utf-8">'
      content << %{
Ext.onReady(function(){
  new Ext.Button({
    #{button_options}
    text: '#{title}',
    renderTo: '#{html_id}'
  });
});
}
      content << "</script>"
      content_tag(:div, content.html_safe, :id => html_id, :class => 'form-container')
    end
  end

  module FormTagHelper
    def form_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
      raise ArgumentError, "Missing block" unless block_given?

      render_form(options.delete(:object_name), options.delete(:object), self, url_for_options, options, &block)
    end

    def field_set_tag(legend = nil, options = nil, &block)
      options = {
        :width => 210
      }.merge(options)

      header = "{ xtype: 'fieldset', checkboxToggle: false, title: '#{legend}', collapsible: false,"
      header << "autoHeight: #{ (auto_height = options.delete(:auto_height).to_s).blank? ? 'true' : auto_height},"
      header << options.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last.to_json}" unless pair.last.blank? }.compact.join(',')
      header << ', items :['

      safe_concat(header)
      safe_concat(remove_last_comma(capture(&block)))
      safe_concat(']},')
      nil
    end

    # Render 'column' layout inside form elements
    # used for place some controls on one line
    def columns(&block)
      concat <<JS
{
  layout:'column',
  items :[
JS
      concat(remove_last_comma(capture(&block)))
      concat(']},')
    end

    # Render individual column for 'columns' layout
    def column(options = {}, &block)
      header = "{ columnWidth: #{options.delete(:width) || '.5'}, layout: 'form',"
      header << options.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last.to_json}" unless pair.last.blank? }.compact.join(',')
      header << ',' unless options.blank?
      header << 'items: ['

      concat(header)
      concat(remove_last_comma(capture(&block)))
      concat(']},')
    end

    private
    def remove_last_comma(source)
      result = source.gsub(/\n/, '').strip
      result[result.length - 1] = ''
      result
    end

    def render_form(object_name, object, template, url_for_options, options, &block)
      content_for(:head, ::ASSET_PACKAGER_INSTALLED ? javascript_include_merged(:forms) : javascript_include_tag('form/MiscField', 'form/validators'))

      render_options = {
        :id => 'form',
        :method => :post,
        :label_width => 170,
        :label_align => 'right',
        :button_align => 'center',
        :width => 500,
        :controls_width => 200,
        :ajax_form => false,
        :border => true,
        :listeners => nil,
        :handle_enter_key => false
      }.merge(html_options_for_form(url_for_options, options).except("accept-charset").symbolize_keys)

      content = content_tag(:div, '', :id => "#{render_options[:id]}-container", :class => 'form-container')
      content << '<script type="text/javascript" charset="utf-8">'.html_safe
      content << render(partial: 'shared/forms/form_header', formats: [:js], locals: render_options)
      safe_concat(content)

      yield ExtJS::FormBuilder.new(object_name, object, template, options.merge(:form_id => render_options[:id]), block)

      content = render(partial: 'shared/forms/form_bottom', formats: [:js], locals: render_options)
      content << '</script>'.html_safe
      safe_concat(content)
      nil
    end
  end
end
