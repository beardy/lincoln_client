// public/javascripts/application.js
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

jQuery(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

// This is all for the drop down menu
var timeout    = 500;
var closetimer = 0;
var ddmenuitem = 0;

function jsddm_open()
{  jsddm_canceltimer();
   jsddm_close();
   ddmenuitem = jQuery(this).find('ul').css('visibility', 'visible');}

function jsddm_close()
{  if(ddmenuitem) ddmenuitem.css('visibility', 'hidden');}

function jsddm_timer()
{  closetimer = window.setTimeout(jsddm_close, timeout);}

function jsddm_canceltimer()
{  
  if(closetimer)
  {  
    window.clearTimeout(closetimer);
    closetimer = null;
  }
}
// End drop down menu

// For time range change
// will update the time range and then reload the page.
//  not the best solution.
function update_date(name, date)
{
  jQuery.post('/groups/update_time_range',{'date': date, 'name': name}, function(){location.reload();});  
}

jQuery(document).ready(function()
{
  jQuery('#dropdown > li').bind('mouseover', jsddm_open)
  jQuery('#dropdown > li').bind('mouseout',  jsddm_timer)
});

document.onclick = jsddm_close;