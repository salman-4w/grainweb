function showPrintPrompt(printUrl) {
  printLading = function(btn, text) {
		if( btn == 'yes' ) {
	    window.location.href = printUrl;
		}
	};

  Ext.MessageBox.show({
		title: 'Lading',
		msg: 'Do you want to print submitted Lading now?',
		width: 300,
		buttons: Ext.MessageBox.YESNO,
		fn: printLading,
		animEl: 'tbutton',
    icon: Ext.MessageBox.QUESTION
	});
}

function checkSelectedRows(selModel, rowIndex, rowData) {
  var btn = Ext.getCmp('print_btn');
  if( selModel.getCount() > 1 ) {
    btn.enable();
  } else {
    btn.disable();
  }
}

function printSelected() {
  var selectionModel = grid_for_ladings_grid.selModel;

  Ext.each(selectionModel.getSelections(), function(item) {
    window.open(item.get('actions'));
  });

  selectionModel.clearSelections();
}

Ext.onReady(function(){
  pagingBar_for_ladings_grid.add('-');
  pagingBar_for_ladings_grid.addButton({id: 'print_btn', text: 'Print Selected', disabled: true, handler: printSelected});
  pagingBar_for_ladings_grid.doLayout();
  var selectionModel = grid_for_ladings_grid.selModel;
  selectionModel.on('beforerowselect', function(selModel, rowIndex, keepExisting, rowData) {
    if( rowData.get('human_status') == 'Draft' ) {
      // show alert when trying to select draft lading with others
      if( keepExisting ) Ext.MessageBox.alert('Information', "You can't select draft ladings for printing.");
      return false;
    }
  });
  selectionModel.on('rowselect', checkSelectedRows);
  selectionModel.on('rowdeselect', checkSelectedRows);
});
