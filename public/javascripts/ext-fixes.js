// ExtJS use text/html as default 'Accept' header, so fix it
Ext.Ajax.defaultHeaders = {
  'Accept': 'text/javascript, text/html, application/xml, text/xml, */*'
};

// ExtJS require server response as JSON, fix it, we need raw JavaScript
Ext.override(Ext.form.Action.Submit, {
	handleResponse : function(response){
    if(this.form.errorReader){
      var rs = this.form.errorReader.read(response);
      var errors = [];
      if(rs.records){
        for(var i = 0, len = rs.records.length; i < len; i++) {
          var r = rs.records[i];
          errors[i] = r.data;
        }
      }
      if(errors.length < 1){
        errors = null;
      }
      return {
        success : rs.success,
        errors : errors
      };
    }
		return eval(response.responseText);
  }
});

Ext.override(Ext.grid.GridPanel, {
	/**
	 * Modified version of grid applyState function to handle sort state
	 */
	applyState: function(state) {
		var cm = this.colModel;
		var cs = state.columns;

		if(cs) {
			for(var i = 0, len = cs.length; i < len; i++) {
				var s = cs[i];
				var c = cm.getColumnById(s.id);
				if(c) {
					c.hidden = s.hidden;
					c.width = s.width;
					var oldIndex = cm.getIndexById(s.id);
					if(oldIndex != i) {
						cm.moveColumn(oldIndex, i);
					}
				}
			}
		}

		if(state.sort) {
			this.store[this.store.remoteSort ? 'setDefaultSort' : 'sort'](state.sort.field, state.sort.direction);
		}

		if(state.globalFilter) {
			Ext.apply(this.store.baseParams, state.globalFilter);
			this._syncMenuCheckedStates(state.globalFilter);
			this._syncMenuTitles();
		}
	},

	/**
	 * Modified version of grid getState function to handle sort state and do not reset it
	 * when the other properties are changed
	 */
	getState : function(){
    var o = {columns: []};
    for(var i = 0, c; c = this.colModel.config[i]; i++){
      o.columns[i] = {
        id: c.id,
        width: c.width
      };
      if(c.hidden){
        o.columns[i].hidden = true;
      }
    }
    var ss = this.store.getSortState();
    if(ss){
      o.sort = ss;
    }

    var menuFilter = this._menusToParams();
    if(menuFilter) {
      o.globalFilter = menuFilter;
    }

		// check for existent state and override it
		if( Ext.state.Manager && (currentState = Ext.state.Manager.get(this.stateId || this.id)) ) {
			for( var key in o ) {
				currentState[key] = o[key];
			}
			o = currentState;
		}

    return o;
  },

  _getCheckedMenusData: function() {
    var data = [];
    Ext.each(this._getTopToolbarItems(), function(toolbarItem) {
      if( (menu = toolbarItem.menu) ) {
        var menuId = menu.id;
        var checkedItems = menu.find("checked", true);
        if( checkedItems.length > 0 ) {
          var selectedText = checkedItems[0].text;
          data.push({id: menuId, text: selectedText, button: toolbarItem});
        }
      }
    }, this);
    return data;
  },

  // findParentBy doesn't work for menu when searching parent grid,
  // so check for presence of the menu from grid object
  hasMenu: function(menuObj) {
    var menus = [];
    Ext.each(this._getTopToolbarItems(), function(toolbarItem) {
      if( (menu = toolbarItem.menu) ) {
        menus.push(menu);
      }
    }, this);
    return menus.indexOf(menuObj) == -1 ? false : true;
  },

  _menusToParams: function() {
    var params = {};
    Ext.each(this._getCheckedMenusData(), function(item) {
      params["global_filter[" + item.id + "]"] = item.text.toLowerCase();
    });
    return params;
  },

  _syncMenuTitles: function() {
    Ext.each(this._getCheckedMenusData(), function(item) {
      var text = Ext.util.Format.capitalize(item.id) + ': ' + item.text;
      if( this.rendered ) {
        item.button.setText(text);
      } else {
        item.button.text = text;
      }
    }, this);
  },

  _syncMenuCheckedStates: function(menuFilterState) {
    Ext.each(this._getTopToolbarItems(), function(toolbarItem) {
      if( (menu = toolbarItem.menu) ) {
        var value = menuFilterState['global_filter[' + menu.id + ']'];
        Ext.each(menu.items.items, function(item) {
          if( item.text.toLowerCase() == value ) {
            item.checked = true;
			    } else {
				    item.checked = false;
			    }
        });
      }
    });
  },

  // when the grid not finally initialized topToolbar is a just an array of items,
  // after initialization this a object that contains "items" container,
  // which can't be iterated via Ext.each, so we need to get "items" array from this container
  _getTopToolbarItems: function() {
    var toolbar = this.topToolbar;
    return (this.rendered ? toolbar.items.items : toolbar);
  },

  applyMenuFilter: function(item, checked) {
    if( !checked ) return;

	  var gridStateId = this.stateId || this.id;

	  var state = Ext.state.Manager.get(gridStateId, this.getState());
    Ext.state.Manager.set(gridStateId, state);

    this.applyState(state);
    this.filters.reload();
  }
});

// Grid bottom caption should be aligned by right side
Ext.override(Ext.layout.ToolbarLayout, {
  onLayout : function(ct, target){
    if(!this.leftTr){
      target.addClass('x-toolbar-layout-ct');
      target.insertHtml('beforeEnd',
                        '<table cellspacing="0" class="x-toolbar-ct"><tbody><tr><td class="x-toolbar-left" align="left"><table cellspacing="0"><tbody><tr class="x-toolbar-left-row"></tr></tbody></table></td><td class="x-toolbar-right" align="right"><table cellspacing="0" class="x-toolbar-right-ct" align="right"><tbody><tr><td><table cellspacing="0"><tbody><tr class="x-toolbar-right-row"></tr></tbody></table></td><td><table cellspacing="0"><tbody><tr class="x-toolbar-extras-row"></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table>');
      this.leftTr = target.child('tr.x-toolbar-left-row', true);
      this.rightTr = target.child('tr.x-toolbar-right-row', true);
      this.extrasTr = target.child('tr.x-toolbar-extras-row', true);
    }
    var side = this.leftTr;
    var pos = 0;

    var items = ct.items.items;
    for(var i = 0, len = items.length, c; i < len; i++, pos++) {
      c = items[i];
      if(c.isFill){
        side = this.rightTr;
        pos = -1;
      }else if(!c.rendered){
        c.render(this.insertCell(c, side, pos));
      }else{
        if(!c.xtbHidden && !this.isValidParent(c, side.childNodes[pos])){
          var td = this.insertCell(c, side, pos);
          td.appendChild(c.getDomPositionEl().dom);
          c.container = Ext.get(td);
        }
      }
    }
    //strip extra empty cells
    this.cleanup(this.leftTr);
    this.cleanup(this.rightTr);
    this.cleanup(this.extrasTr);
    this.fitToSize(target);
  }
});
