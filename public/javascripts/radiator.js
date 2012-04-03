$(function() {
  $(window).bind('resize', function()
  {
    resizeMe();
  }).trigger('resize');
})

function resizeMe() {
  var preferredHeight = 944;
  var displayHeight = $(window).height();
  var percentage = displayHeight / preferredHeight;
  var newFontSize = Math.floor("800" * percentage) - 20;
  $("body").css("font-size", newFontSize + "%")
}
