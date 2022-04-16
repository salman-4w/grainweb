Ext.state.States = {};

Ext.state.UserSessionProvider = function(config) {
	Ext.state.UserSessionProvider.superclass.constructor.call(this);
  Ext.apply(this, config);

  this.state = Ext.state.States;
};

Ext.extend(Ext.state.UserSessionProvider, Ext.state.Provider, {
  resetAll: function() {
    for( var name in Ext.state.States ) {
      Ext.state.UserSessionProvider.superclass.clear.call(this, name);
    }
    Ext.state.States = {};

		// reset state in database
		Ext.Ajax.request({
			url: '/uistate',
			method: 'DELETE'
		});


		return true;
	},

	// private
	set: function(name, value) {
    if(typeof value == "undefined" || value === null){
			this.clear(name);
			return;
		}
		this.__updateState(name, value);
    Ext.state.States[name] = value;
		Ext.state.UserSessionProvider.superclass.set.call(this, name, value);
	},

	// private
	clear: function(name) {
		this.__updateState(name);
    Ext.state.States[name] = null;
		Ext.state.UserSessionProvider.superclass.clear.call(this, name);
	},

  /**
	 * Update UI state in database
	 */
	__updateState: function(name, value) {
		value = value ? Ext.util.JSON.encode(value) : '';
		Ext.Ajax.request({
			url: '/uistate',
			method: 'PUT',
			params: {
				name: name,
				value: value
			}
		});
	}
});
