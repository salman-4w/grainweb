function link(value, metadata, record, rowIndex, colIndex, store) {
	if( value == null ) return;

	var gridId = metadata.id;
	var result = '';

  var htmlLink = function(href, title) {
    var result = '<a href="' + href + '"';
    // open PDF or other reports in the new window
    if( href.indexOf('print') != -1 ) {
      result += ' target="_blank"';
    }
    result += '>' + title + '</a>';
    return result;
  };

  var normalizeTitle = function(title) {
    if( title.indexOf('_') != -1 ) {
			return title.split('_').map(function(el) { return Ext.util.Format.capitalize(el); }).join(' ');
		} else {
			return Ext.util.Format.capitalize(title);
		}
  };

	if( gridId.indexOf('link_to') == 0 ) {
		var title = normalizeTitle(gridId.replace('link_to_', ''));
		result = htmlLink(value, title);
	} else if( gridId.indexOf('links_to_') == 0 ) {
		var titles = gridId.replace('links_to_', '').split('_and_').map( function(el) {
			return normalizeTitle(el);
		});
		var links = value.split(' ');
		result = titles.map( function(title, index) {
			return htmlLink(links[index], title);
		}).join(' | ');
	} else {
    var title = Ext.util.Format.capitalize(value.replace(/^.*\/(.*)$/, "$1"));
    result = htmlLink(value, title);
  }

	return result;
}

/**
 * Parse a value into a formatted date using the 'MM/DD/YYYY' format pattern.
 */
function date(value) {
  if( !value ) return "";

	if( !Ext.isDate(value) ) {
	  value = Date.parseDate(value, "Y-m-d");
  }

	return value.dateFormat("m/d/Y");
}

/**
 * Parse a value into a formatted time using the 'MM/DD/YYYY HH:SS' format pattern.
 */
function time(value) {
	if( !value ) return "";

	if( !Ext.isDate(value) ) {
	  value = Date.parseDate(value, "c");
  }

	return value.dateFormat("m/d/Y h:m");
}

/**
 * Format a number with commas
 */
function quantity(value) {
  value = (Math.round((value-0)*100))/100;
  value = (value == Math.floor(value)) ? (value + '.00') : ((value*10 == Math.floor(value*10)) ? (value + '0') : value);
  value = String(value);

  var ps = value.split('.');
  var whole = ps[0];
  var sub = ps[1] ? ('.' + ps[1]) : '.00';

  var r = /(\d+)(\d{3})/;
  while( r.test(whole) ) {
    whole = whole.replace(r, '$1' + ',' + '$2');
  }

  return whole + sub;
}

/**
 * Render a total summary from json data
 */
function remoteFullTotal(value, params, data, gridSummary) {
  if ((data = gridSummary.grid.store.reader.jsonData)) {
    return quantity(data.summaries[params.id]);
  }
}

function remoteFullDollars(value, params, data, gridSummary) {
  if ((data = gridSummary.grid.store.reader.jsonData)) {
    return "$" + quantity(data.summaries[params.id]);
  }
}

function totalWord(value, params, data, gridSummary) {
  value = "Total:";
  return value;
}
