jQuery(function($) {
  var refresh_timer;

  $('input#autorefresh').change(function() {
    if (this.checked) {
      var refresh_count = 15; // Refresh after 15 seconds
      $('span#autorefresh_countdown').text(refresh_count);
      $.cookie('autorefresh', 'on');

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
      $.removeCookie('autorefresh');
    }
  });

  if ($.cookie('autorefresh')) {
    $('input#autorefresh').prop('checked', true);
    $('input#autorefresh').change(); // prop does not fire events
  }
});
