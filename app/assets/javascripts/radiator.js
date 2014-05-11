jQuery(function($) {
  $(window).bind('resize', function() {
    resizeMe();
  }).trigger('resize');

  function resizeMe() {
    var preferredHeight = 1100;
    var displayHeight = $(window).height();
    var percentageHeight = displayHeight / preferredHeight;

    var preferredWidth = 1100;
    var displayWidth = $(window).width();
    var percentageWidth = displayWidth / preferredWidth;

    var newFontSize;
    if (percentageHeight < percentageWidth) {
      newFontSize = Math.floor("815" * percentageHeight) - 30;
    } else {
      newFontSize = Math.floor("815" * percentageWidth) - 30;
    }
    $("body").css("font-size", newFontSize + "%")
  }

  var percentage = function(count, total) {
    if (total < 1) return 0;
    return Math.round(100 * count / total);
  }

  // The default refresh is 60 seconds. The client can specify a different
  // refresh value as low as 15 seconds. ?refresh=0 disables refresh.
  var default_refresh = 60;
  var minimum_refresh = 15;
  var refresh_param = RegExp('[?&]refresh=(\\d+)').exec(window.location.search);
  refresh_param = refresh_param ? refresh_param[1] : default_refresh;
  refresh_param = refresh_param > 0 && refresh_param < minimum_refresh ? minimum_refresh : refresh_param;

  if (refresh_param > 0) {
    var starting_count = refresh_param;
    var refresh_count = starting_count;
    $('span#status').html('&#x2713;');

    var refresh_timer = setInterval(function() {
      refresh_count--;
      if (refresh_count == 1) {
        $('span#status').html('&hellip;');
      } else if (refresh_count == 0) {
        $.getJSON(window.location)
          .done(function(data) {
            for(var key in data) {
              var row = $('tr.' + key);
              if (row.length < 1) continue;
              var percent = (key == 'all') ? 0 : percentage(data[key], data['all']);
              row.find('.count span').text(data[key]);
              row.find('p.percent').width(percent + '%');
            }
            $('span#status').html('&#x2713;');
          })
          .error(function() {
            $('span#status').html('&#x2717;');
          })
          .always(function() {
            refresh_count = starting_count;
          });
      }
    }, 1000);
  }
});
