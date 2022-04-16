function loadNavTab(path) {
	window.location.href = path;
}

function showErrorMessage(message) {
	Ext.MessageBox.show({
		title: 'Error',
		msg: message,
		buttons: Ext.MessageBox.OK,
		icon: Ext.MessageBox.ERROR
	});
}

function resizeGrid(grid, windowId) {
	var size = windows[windowId].getSize();
	var newWidth = size.width - 20;
	var newHeight = size.height - 100;
	grid.setSize(newWidth, newHeight);
}

function resetUI() {
  var sessionProvider = new Ext.state.UserSessionProvider();
  sessionProvider.resetAll();
  /* this may be easier using Ext somehow, please refactor if so */
  var parent = document.getElementById('messages'),
      child  = document.createElement('span');
  child.setAttribute('class', 'notice');
  child.innerText = 'Default screen settings restored.';
  parent.appendChild(child);
}
