jQuery(function($) {
  var refresh_timer;

  $('input#autorefresh').change(function() {
    // Prevent autorefresh on form pages
    // TODO: Even better, prevent autorefresh when any form element has focus
    if (/(new)|(edit)$/.test(window.location.pathname)) {
      $('span#autorefresh_countdown').html('&hellip;');
      $('li#navigation-autorefresh input').prop('disabled', true);
    } else if (this.checked) {
      var refresh_count = 15; // Refresh after 15 seconds
      $('span#autorefresh_countdown').text(refresh_count);
      $.cookie('autorefresh', 'on', {'path': '/'});

      refresh_timer = setInterval(function() {
        refresh_count--;
        if (refresh_count == 1) {
          $('span#autorefresh_countdown').html('&hellip;');
        } else if (refresh_count == 0) {
          window.location.reload();
        } else {
          $('span#autorefresh_countdown').text(refresh_count);
        }
      }, 1000);
    } else {
      clearInterval(refresh_timer);
      $('span#autorefresh_countdown').text('');
      $.removeCookie('autorefresh', {'path': '/'});
    }
  });

  if ($.cookie('autorefresh') == 'on') {
    $('input#autorefresh').prop('checked', true);
    $('input#autorefresh').change(); // prop does not fire events
  }
});
