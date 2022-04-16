var proofOfYieldReportWindow = null;

function printReport() {
  if( !proofOfYieldReportWindow ){
    proofOfYieldReportWindow = new Ext.Window({
      title: 'Proof of Yield',
      layout: 'fit',
			width: 500,
			height: 300,
			resizable: false,
			closeAction: 'hide',
			modal: true,
			items: {
				autoLoad: {
					url: '/reports/proof_of_yield',
					scripts: true
				}
			},

			buttons: [
				{ text:'Print',
					handler: function() {
            var form = Ext.getCmp('proof_of_yield_report_form').getForm();
            if( !form.isValid() ) return;

            var dom = form.getEl().dom;
            dom.target = "_blank";
            dom.action = '/reports/proof_of_yield.pdf';
            dom.submit();
            proofOfYieldReportWindow.hide();
          }
        },
				{ text: 'Close',
					handler: function(){
						proofOfYieldReportWindow.hide();
					}
				}]
    });
  }
  proofOfYieldReportWindow.show();
}
