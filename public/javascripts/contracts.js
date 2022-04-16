function printContractReport(contractId, type, options) {
  if (Ext.isEmpty(type)) {
    return;
  }

  var reportPath = "/contracts/" + contractId + "/" + type + ".pdf";

  if (type == "ticket_applications" || type == "ticket_dollars") {
    printReport = function(btn, text) {
      if (btn == "ok") {
        window.open(reportPath + "?pricing_id=" + escape(text));
      }
    };

    var options = options || [];
    options.unshift({text: 'All', value: ''});

    Ext.MessageBox.show({
      title: 'Pricing',
      msg: 'Report will be opened in new window, please enable pop-ups for this site.<br/><br/>Please select Pricing:',
      width: 300,
      buttons: Ext.MessageBox.OKCANCEL,
      options: options,
      fn: printReport,
      animEl: 'tbutton'
    });
  } else {
    window.open(reportPath);
  }
}

function printContractAmendmentReport(contractId) {
  var reportPath = "/contracts/" + contractId + "/amendment.pdf";

  var selectedRecord = grid_for_contract_amendments_grid.getSelectionModel().getSelected();

  if (selectedRecord) {
    reportPath += "?amendment_id=" + selectedRecord.json.id;
  }

  window.open(reportPath);
}

function openPricingCard(contractId) {
	var tabs = new Ext.TabPanel({
		activeTab: 0,
		resizeTabs: true,
		autoScroll: true,
		defaults: {
			autoScroll: true
		},
		items: {
			title: 'Pricings',
			autoLoad: {
				url: locationBasePath() + '/' + contractId + '/pricings/list',
				scripts: true
			}
		}
	});

	var win = new Ext.Window({
		closable: true,
		collapsible: false,
		width: 800,
		height: 520,
		border: false,
		plain: true,
		layout: "fit",
		items: tabs,
		stateful: true,
		stateId: "contract-popin"
	});

	win.on("bodyresize", onResizeContractCardWindow);
	win.show();
	return win;
}

function openContractCard(contractId) {
  var tabs = new Ext.TabPanel({
		activeTab: 0,
		resizeTabs: true,
		autoScroll: true,
		defaults: {
			autoScroll: true
		},
		items: [
			{ title: "Terms",
				autoLoad: { url: locationBasePath() + "/" + contractId, scripts: true }
			},
			{ title: 'Pricings',
				autoLoad: {
					url: locationBasePath() + "/" + contractId + "/pricings/list",
					scripts: true
				}
			},
			{ title: "Bookings",
				autoLoad: {
					url: locationBasePath() + "/" + contractId + "/bookings/list",
					scripts: true
				}
			},
			{ title: "Tickets",
				autoLoad: {
					url: locationBasePath() + "/" + contractId + "/tickets/list",
					scripts: true
				}
			}//,
      // { title: 'Amendments',
      //  autoLoad: {
      //    url: locationBasePath() + '/' + contractId + '/amendments/list',
      //    scripts: true
      //  }
      // }
		]
	});

  var winHeight;

  if (Ext.isGecko) {
    winHeight = Ext.isMac ? 605 : 600;
  } else if (Ext.isSafari || (Ext.isMac && Ext.isChrome)) {
    winHeight = 610;
  } else {
    winHeight = 620;
  }

	var win = new Ext.Window({
		closable: true,
		collapsible: false,
		width: 800,
		height: winHeight,
    resizable: false,
		border: false,
		plain: true,
		layout: "fit",
		items: tabs,
		stateful: true,
		stateId: "contract-popin"
	});

	win.on("bodyresize", onResizeContractCardWindow);
	win.show();
	return win;
}

function onResizeContractCardWindow(panel, width, height) {
	var newWidth = width - 20;
	var newHeight = height - 100;
	if( typeof(grid_for_contract_pricing_grid) != 'undefined' ) {
		grid_for_contract_pricing_grid.setSize(newWidth, newHeight);
	}
	if( typeof(grid_for_contract_bookings_grid) != 'undefined' ) {
		grid_for_contract_bookings_grid.setSize(newWidth, newHeight);
	}
	if( typeof(grid_for_contract_tickets_grid) != 'undefined' ) {
		grid_for_contract_tickets_grid.setSize(newWidth, newHeight);
	}
	if( typeof(grid_for_contract_amendments_grid) != 'undefined' ) {
		grid_for_contract_amendments_grid.setSize(newWidth, newHeight);
	}
}

// popup should be the same for the 'deferred_contracts' and 'contracts' grids
function locationBasePath() {
  return window.location.pathname.replace("deferred_", "");
}

var windows = [];

Ext.onReady(function(){
  var grid = null;
  if (typeof(grid_for_contracts_grid) == "undefined") {
    grid = grid_for_deferred_contracts_grid;
  } else {
    grid = grid_for_contracts_grid;
  }

  grid.on("cellclick", function(grid, rowIndex, columnIndex, event) {
		var rowData = grid.getStore().getAt(rowIndex).json;
    var contractId = rowData.id;

		if (windows[contractId] && windows[contractId].isVisible()) {
			windows[contractId].close();
			windows[contractId] = null;
		} else {
			var win = null;
			// open pricings window when click in 'price type' cell
      // FIXME: do we need this conditions? (Check the Contract#price_type_for_view)
			if(grid.getColumnModel().getDataIndex(columnIndex) == 'price_type_for_view') {
				win = openPricingCard(contractId);
			} else {
				win = openContractCard(contractId);
			}

			windows[contractId] = win;
		}
  });
});
