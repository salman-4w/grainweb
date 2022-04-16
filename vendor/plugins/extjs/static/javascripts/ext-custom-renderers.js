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

	if( gridId.indexOf('link_to') == 0 ) {
		var title = Ext.util.Format.capitalize(gridId.replace('link_to_', ''));
		result = htmlLink(value, title);
	} else if( gridId.indexOf('links_to_') == 0 ) {
		var titles = gridId.replace('links_to_', '').split('_and_').map( function(el) {
			if( el.include('_') ) {
				return el.split('_').map(function(el) { return Ext.util.Format.capitalize(el); }).join(' ');
			} else {
				return Ext.util.Format.capitalize(el);
			}
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
	value = String(value);
  var ps = value.split('.');
  var whole = ps[0];
  var sub = ps[1] ? '.'+ ps[1] : '.00';

  // fix one digit after separator
  if(sub.length == 2) {
    sub += "0";
  }

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
  if( (data = gridSummary.grid.store.reader.jsonData) ) {
    value = quantity(data.summaries[params.id]);
    return value;
  }
};

function totalWord(value, params, data, gridSummary) {
  value = "Total:";
  return value;
}
