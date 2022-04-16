module ApplicationHelper
  def logo_path
    "/images/#{Hmcustomers.config.namespace}-logo-#{Rails.env}.png"
  end

  def map_blue_marker_hack
    <<-CODE
<script type="text/javascript" charset="utf-8">
// Hack to use custom icon for 'my store'.
// We should initialize it here, because GoogleMaps JS throw strange error in other cases.
var blueIcon = new GIcon(G_DEFAULT_ICON);
blueIcon.image = "/images/blue-dot.png";
blueIcon.iconSize = new GSize(32, 32);
</script>
CODE
  end

  def page_title(title = nil)
    page_title = "GrainWeb"
    page_title << " > #{title}" if page_title
    page_title << " > #{Hmcustomers.config.company_name}"
    content_for(:title, page_title.html_safe)
  end

  def left_nav_tab(title, path, controller = nil)
    if controller_name == (controller || title.gsub(' ', '_').downcase)
      "<li class=\"selected\">#{title}</li>"
    else
      "<li onclick=\"loadNavTab('#{path}')\">#{title}</li>"
    end.html_safe
  end

  def customers_for_select
    if cookies[:customers_for_select].blank?
      save_customers_in_cookie
    else
      cookies[:customers_for_select].to_s.split('&')
    end
  end

  def commodity_filter_menu
    unless @commodity_filter
      filter = "{ text: 'Commodity: All', menu: new Ext.menu.Menu({id: 'commodity', items: ["
      filter << "{ text: 'All', checked: true, group: 'commodity', checkHandler: Ext.grid.applyTopMenuFilter },"
      filter << Commodity.where('DisplayOnWeb = 1').order('CommName ASC').map do |comm|
        "{text: \"#{comm.comm_name}\", checked: false, group: 'commodity', checkHandler: Ext.grid.applyTopMenuFilter }"
      end.join(',')
      filter << "]})}"
      @commodity_filter = filter.html_safe
    end
    @commodity_filter
  end

  def error_messages_for(object)
    object = instance_variable_get("@#{object}")
    return if object.errors.empty?

    result = "<div id=\"errorExplanation\"><h2>The following errors prohibited this form from being saved:</h2><ul>"
    object.errors.full_messages.each { |msg| result << "<li>#{msg}</li>" }
    result << "</ul></div>"
    result.html_safe
  end
end
