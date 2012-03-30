$(function() {
  $(window).bind('resize', function()
  {
    resizeMe();
  }).trigger('resize');
})

function resizeMe() {
  var preferredHeight = 383;
  var displayHeight = $(window).height();
  var percentage = displayHeight / preferredHeight;
  var newFontSize = Math.floor("300" * percentage) - 10;
  $("body").css("font-size", newFontSize + "%")
}
