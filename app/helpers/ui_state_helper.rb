module UiStateHelper
  def stateful_ui(user, *ids)
    keys = [ids].flatten.map { |id| "state_for_#{id}" }

    js_states = user.ui_state_object.map do |pair|
      "Ext.state.States[\"#{pair.first}\"] = #{pair.last.to_json};" if keys.include?(pair.first)
    end.join

    script = <<-SCRIPT
     <script type="text/javascript">
       Ext.onReady(function(){
         #{js_states}
       });
     </script>
SCRIPT

    # render JS inline for AJAX requests
    request.xhr? ? script.html_safe : content_for(:head, script.html_safe)
  end
end
