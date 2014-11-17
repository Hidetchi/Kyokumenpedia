$(document).on 'page:fetch', ->
  $("img#logo").css("animation", "load 1s linear 0s infinite")
  $("img#logo").css("-webkit-animation", "load 1s linear 0s infinite")
$(document).on 'page:change', ->
  $("img#logo").css("animation", "none")
  $("img#logo").css("-webkit-animation", "none")
