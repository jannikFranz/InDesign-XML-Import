//##########################################################################################
//######### Aufeinanderfolgende Seitenzahlen zu Seitenspanne mit Halbgeviertstrich #########
//##########################################################################################

// groupSequentiellNum.jsx 
 
//DESCRIPTION: 1, 2, 4, 5, 6 -> 1-2, 4-6  
 
var s = app.selection[0].parentStory; 
app.findGrepPreferences = app.changeGrepPreferences = NothingEnum.nothing; 
 
app.findGrepPreferences.findWhat = '\\d+, ([\\d+, ])+'; 
var r = s.findGrep(); 
for ( aLine = r.length-1; aLine >= 0; aLine-- ) 
	r[aLine].contents= checkOneLine ( r[aLine].contents ); 
 
function checkOneLine ( aString ) 
{ 
	var a = aString.split( ', '); 
	for ( var i = 0; i < aString.length-1; i++ ) 
	{ 
		var k = i +1; 
		while ( k < aString.length && a[k] == Number( a[k-1] ) + 1) 
		{ 
			k++; 
		} 
		if ( Number(a[k-1]) >  Number( a[i] ) ) 
		{ 
			a[i] = a[i] + '–' + a[k-1]; 
			a.splice( i+1, k-1-i ); 
		} 
	} 
	return  a.join( ', '); 
}

//###############################################################################
//######### Aufeinanderfolgende Seitenzahlen mit f. und ff. formatieren #########
//###############################################################################

// groupSequentiellNumFF.jsx 
 
//DESCRIPTION: 1, 2, 4, 5, 6 -> 1f., 4ff. 
 
var s = app.selection[0].parentStory; 
app.findGrepPreferences = app.changeGrepPreferences = NothingEnum.nothing; 
 
app.findGrepPreferences.findWhat = '\\d+, ([\\d+, ])+'; 
var r = s.findGrep(); 
 
var myMax = r.length; 
 
for ( aLine = r.length-1; aLine >= 0; aLine-- ) 
	r[aLine].contents= checkOneLine ( r[aLine].contents ); 
 
 
function checkOneLine ( aString ) 
{ 
	var a = aString.split( ', '); 
	for ( var i = 0; i < aString.length-1; i++ ) 
	{ 
		var k = i; 
		var k = i +1; 
		while ( k < aString.length && a[k] == Number( a[k-1] ) + 1) 
		{ 
			k++; 
		} 
		if ( Number(a[k-1]) >=  Number( a[i] )+2 ) 
		{ 
			a[i] = a[i] + '\u2009ff.'; 
			a.splice( i+1, k-1-i ); 
		} 
		else if ( Number(a[k-1]) ==  Number( a[i] )+1 ) 
		{ 
			a[i] = a[i] + '\u2009f.'; 
			a.splice( i+1, 1 ); 
		} 
	} 
	return  a.join( ', '); 
}

//################################################################
//######### Halbgeviertstrich und f. bzw. ff. kombiniert #########
//################################################################

// groupSequentiellNumFF+to.jsx 
  
//DESCRIPTION: 1, 2, 4, 5, 6, 8, 9, 10, 11 -> 1f., 4ff., 8-11  
 
if (app.documents.length == 0) exit(); 
if (app.selection.length == 0 || !app.selection[0].hasOwnProperty('parentStory')) 
	error_exit('Bitte platzieren Sie die Einfügemarke in einem Textabschnitt oder wählen Sie einen Textrahmen.'); 
 
var s = app.selection[0].parentStory;  
app.findGrepPreferences = NothingEnum.nothing;   
app.findGrepPreferences.findWhat = '\\d+, ([\\d+, ])+';  
var r = s.findGrep();  
app.findGrepPreferences = NothingEnum.nothing;  
   
for ( var aLine = r.length-1; aLine >= 0; aLine-- )  
	r[aLine].contents= checkOneLine ( r[aLine].contents );  
  
  
function checkOneLine ( aString )  
{  
	var a = aString.split( ', ');  
	for ( var i = 0; i < aString.length-1; i++ )  
	{  
		var k = i +1;  
		while ( k < aString.length && a[k] == Number( a[k-1] ) + 1)  
		{  
			k++;  
		}  
		// 1-3 
		if ( Number(a[k-1]) >  Number( a[i] )+2 )  
		{  
			a[i] = a[i] + '\u2013' +  a[k-1];  
			a.splice( i+1, k-1-i );  
		}  
		// 1ff. 
		else if ( Number(a[k-1]) ==  Number( a[i] )+2 )  
		{  
			a[i] = a[i] + '\u2009ff.';  
			a.splice( i+1, k-1-i );  
		}  
		// 1f. 
		else if ( Number(a[k-1]) ==  Number( a[i] )+1 )  
		{  
			a[i] = a[i] + '\u2009f.';  
			a.splice( i+1, 1 );  
		}  
	}  
	return  a.join( ', ');  
}  
 
function error_exit(message)  
{  
	if (arguments.length > 0)   
		alert('Achtung!\n' + message);  
	exit(); 
}