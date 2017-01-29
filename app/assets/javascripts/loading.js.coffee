$(document).on 'page:fetch', ->
  topY = ($(window).height()/2 + $(window).scrollTop()) + 'px'
  $("body").spin({top:topY,left:'55%',length:16,radius:16,width:6,shadow:true,color:'#038'});
  $("img#logo").css("animation", "load 1s linear 0s infinite")
  $("img#logo").css("-webkit-animation", "load 1s linear 0s infinite")
$(document).on 'page:change', ->
  $("body").spin(false);
  $("input.toggle").click ->
    topY = ($(window).height()*0.45 + $(window).scrollTop()) + 'px'
    $("body").spin({top:topY,left:'55%',length:16,radius:16,width:6,shadow:true,color:'#038'});
  $("img#logo").css("animation", "none")
  $("img#logo").css("-webkit-animation", "none")
  if window._gaq?
    _gaq.push ['_trackPageview']
  else if window.pageTracker?
    pageTracker._trackPageview()
$(document).on 'page:load', ->
  twttr.widgets.load()
