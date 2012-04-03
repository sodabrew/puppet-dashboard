$(function() {
  $(window).bind('resize', function()
  {
    resizeMe();
  }).trigger('resize');
})

function resizeMe() {
  var preferredHeight = 944;
  var displayHeight = $(window).height();
  var percentageHeight = displayHeight / preferredHeight;

  var preferredWidth = 944;
  var displayWidth = $(window).width();
  var percentageWidth = displayWidth / preferredWidth;

  var newFontSize;
  if (percentageHeight < percentageWidth) {
    newFontSize = Math.floor("720" * percentageHeight) - 20;
  } else {
    newFontSize = Math.floor("720" * percentageWidth) - 30;
  }
  $("body").css("font-size", newFontSize + "%")
}
