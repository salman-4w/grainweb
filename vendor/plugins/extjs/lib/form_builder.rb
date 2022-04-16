module ExtJS
  class FormBuilder < ActionView::Helpers::FormBuilder
    [
     { :method => 'misc_field', :xtype => 'miscfield'},
     { :method => 'password_field', :xtype => 'textfield', :input_type => 'password'},
     { :method => 'text_field', :xtype => 'textfield'},
     { :method => 'number_field', :xtype => 'numberfield'},
     { :method => 'text_area', :xtype => 'textarea'},
     { :method => 'date_field', :xtype => 'datefield'},
     { :method => 'hidden_field', :xtype => 'hidden'}
    ].each do |control_info|
      method_name = control_info.delete(:method)

      define_method method_name do |field, *args|
        options = args.extract_options!

        control_options = {
          :value => object.send(field),
          :field_label => (options.delete(:label) || field.to_s.titleize),
          :id => "#{object_name}_#{field.to_s}",
          :name => "#{object_name}[#{field.to_s}]"
        }.merge(control_info)

        control(control_options.reverse_merge(options))
      end

      define_method "#{method_name}_tag" do |name, value, *args|
        value ||= nil
        options = args.extract_options!

        control_options = {
          :value => value,
          :field_label => options.delete(:label) || name.to_s.titleize,
          :id => name,
          :name => name
        }.merge(control_info)

        control(control_options.reverse_merge(options))
      end
    end

    def select(field, choices, options = {})
      default_options = {
        :value => object.send(field),
        :label => (options.delete(:label) || field.to_s.titleize),
        :id => "#{object_name}_#{field.to_s}",
      }.merge(choices_to_store(choices))

      select_tag("#{object_name}[#{field.to_s}]", nil, options.merge(default_options))
    end

    def select_tag(name, choices = nil, options = {})
      control_options = {
        :type_ahead => true,
        :trigger_action => 'all',
        :empty_text => options.delete(:empty_text) || 'Select a value...',
        :field_label => options.delete(:label) || name.to_s.titleize,
        :id => options.delete(:id) || name,
        :name => name,
        :force_selection => true,
        :auto_select => true
      }

      if options[:store]
        control_options[:store] = options.delete(:store)
      else
        control_options.merge!(choices_to_store(choices))
      end

      ("new Ext.form.ComboBox(" + control(options.merge(control_options)).sub(/,$/, '') + "),").html_safe
    end

    def state_select(field, options = {})
      state_select_tag("#{object_name}[#{field.to_s}]", options.merge(:value => object.send(field), :id => "#{object_name}_#{field.to_s}"))
    end

    def state_select_tag(name, options = {})
      states = [
        ['AL', 'Alabama'],
        ['AK', 'Alaska'],
        ['AZ', 'Arizona'],
        ['AR', 'Arkansas'],
        ['CA', 'California'],
        ['CO', 'Colorado'],
        ['CT', 'Connecticut'],
        ['DE', 'Delaware'],
        ['DC', 'District of Columbia'],
        ['FL', 'Florida'],
        ['GA', 'Georgia'],
        ['HI', 'Hawaii'],
        ['ID', 'Idaho'],
        ['IL', 'Illinois'],
        ['IN', 'Indiana'],
        ['IA', 'Iowa'],
        ['KS', 'Kansas'],
        ['KY', 'Kentucky'],
        ['LA', 'Louisiana'],
        ['ME', 'Maine'],
        ['MD', 'Maryland'],
        ['MA', 'Massachusetts'],
        ['MI', 'Michigan'],
        ['MN', 'Minnesota'],
        ['MS', 'Mississippi'],
        ['MO', 'Missouri'],
        ['MT', 'Montana'],
        ['NE', 'Nebraska'],
        ['NV', 'Nevada'],
        ['NH', 'New Hampshire'],
        ['NJ', 'New Jersey'],
        ['NM', 'New Mexico'],
        ['NY', 'New York'],
        ['NC', 'North Carolina'],
        ['ND', 'North Dakota'],
        ['OH', 'Ohio'],
        ['OK', 'Oklahoma'],
        ['OR', 'Oregon'],
        ['PA', 'Pennsylvania'],
        ['RI', 'Rhode Island'],
        ['SC', 'South Carolina'],
        ['SD', 'South Dakota'],
        ['TN', 'Tennessee'],
        ['TX', 'Texas'],
        ['UT', 'Utah'],
        ['VT', 'Vermont'],
        ['VA', 'Virginia'],
        ['WA', 'Washington'],
        ['WV', 'West Virginia'],
        ['WI', 'Wisconsin'],
        ['WY', 'Wyoming']
      ]
      extjs_store = "new Ext.data.SimpleStore({fields: ['abbr', 'state'], data:"
      extjs_store << states.to_json
      extjs_store << "})"

      default_options = {
        :store => extjs_store,
        :value_field => 'abbr',
        :display_field  => 'state',
        :mode => 'local',
        :empty_text => 'Select a state...'
      }

      select_tag(name, nil, options.merge(default_options))
    end

    def submit_button(label = 'Save', *args)
      options = args.extract_options!

      buttons_content = @template.instance_variable_get("@content_for_buttons_for_#{@options[:form_id]}").to_s
      button = buttons_content.blank? ? "" : ","
      button << "{text: '#{label}', formBind: true, handler: function() { Ext.getCmp('#{@options[:form_id]}').getForm().submit(); }"
      unless options.blank?
        button << ","
        button << options.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last.to_json}" unless pair.last.blank? }.compact.join(',')
      end
      button << "}"
      @template.content_for(:"buttons_for_#{@options[:form_id]}", button.html_safe)
      return nil
    end

    def object
      @object || (@template.instance_variable_get("@#{@object_name}") rescue nil)
    end

    private
    def validations(hash)
      hash ||= {}

      booleans = %w{ true false }
      hash.inject('') do |result, pair|
        pair_val = pair.last.to_s
        pair_val = booleans.include?(pair_val) ? "#{pair_val}" : "'#{pair_val}'"
        result << "#{pair.first.to_s.camelize(:lower)}: #{pair_val},"
      end
    end

    def control(options)
      content = "{#{validations(options.delete(:validation))}"
      content << "validator: #{options.delete(:validator)}," if options[:validator]
      content << "listeners: #{options.delete(:listeners)}," if options[:listeners]
      content << "store: #{options.delete(:store)}," if options[:store]
      content << "editable: #{options.delete(:editable)}," unless options[:editable].nil?
      content << options.map { |pair| "#{pair.first.to_s.camelize(:lower)}: #{pair.last.to_json}" unless pair.last.blank? }.compact.join(',')
      content << "},"
      content.html_safe
    end

    def choices_to_store(choices)
      {}.tap do |options|
        if choices && choices.first.is_a?(Array)
          options[:store] = "new Ext.data.SimpleStore({fields: ['label', 'value'], data: #{choices.to_json} })"
          options[:value_field] = 'value'
          options[:display_field] = 'label'
          options[:mode] = 'local'
        else
          options[:store] = choices.to_json
        end
      end
    end
  end
end
