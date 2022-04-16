Ext.grid.PrintGrid = function(grid){
  var params = Ext.apply({title: grid.title}, grid.getStore().lastOptions.params, grid.getStore().baseParams);
  var url = Ext.urlAppend(grid.getStore().proxy.url + '.pdf', Ext.urlEncode(params));
  window.open(url);
};

Ext.grid.applyTopMenuFilter = function(item, checked) {
  if( !checked ) return;
  var menu = item.parentMenu;
  var gridObject = null;
  Ext.iterate(GRIDS, function(grid) {
    if(grid.hasMenu(menu)) {
      gridObject = grid;
      return false;
    }
  }, this);
  gridObject.applyMenuFilter(item, checked);
};
