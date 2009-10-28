$(document).ready(function() {
  $('.hidden').hide()
  $('a.show-hide').click(function() {
    $(this).parents('.actions').siblings('.hidden').toggle(); return false;
  });
});
