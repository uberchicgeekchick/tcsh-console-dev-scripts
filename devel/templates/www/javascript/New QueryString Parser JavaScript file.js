function QueryString(key)
{
	var value = null;
	for (var i=0;i<QueryString.keys.length;i++)
	{
		if (QueryString.keys[i]==key)
		{
			value = QueryString.values[i];
			break;
		}
	}
	return value;
}
QueryString.keys = new Array();
QueryString.values = new Array();

function QueryString_Parse()
{
	var query = window.location.search.substring(1);
	var pairs = query.split("&");
	
	for (var i=0;i<pairs.length;i++)
	{
		var pos = pairs[i].indexOf('=');
		if (pos >= 0)
		{
			var argname = pairs[i].substring(0,pos);
			var value = pairs[i].substring(pos+1);
			QueryString.keys[QueryString.keys.length] = argname;
			QueryString.values[QueryString.values.length] = value;		
		}
	}

}

QueryString_Parse();

// write flash obj with query string
function writeFlash() {
	// appearance vars, these can be customized to your liking
	var width = '800'
	var height = '1300'
	var src = 'http://creative-origin.myspace.com/design/_js/darkhorse/flash/darkhorse_comicbook_frame.swf'
	// queries -- type in the variables you want to send to flash here
	var queries = '?issuenum='+QueryString('issuenum')+'&storynum='+QueryString('storynum')+''

	// assemble flash object
	var l1 = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="'+width+'" height="'+height+'">'
	var l2 = '<param name="movie" value="'+src+queries+'" />'
	var l3 = '<param name="quality" value="high" />'
	var l4 = '<embed src="'+src+queries+'" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="'+width+'" height="'+height+'"></embed>;'
	var l5 = '</object>'

	// write all lines
	document.write(l1+l2+l3+l4+l5)
}
