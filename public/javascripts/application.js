$(document).ready(function() {
  // $('.collapsible').hide()
  // $('a.active.collapsible-trigger').live('click', function(event) {
    // var href = $(this).attr("href");
    // $(href).removeClass("active");
    // $(this).removeClass("active");
    // $(this).find('span.response').html("Show");
    // return false;
  // });

  // $('a.collapsible-trigger:not(.active)').live('click', function(event) {
    // var href = $(this).attr("href");
    // $(href).addClass("active");
    // $(this).addClass("active");
    // $(this).find('span.response').html("Hide");
    // return false;
  // });

  // $('.filter-list').filterList();

  $.fn.sparklineStatus = function() {
    $(this).sparkline('html', {
      spotRadius: 0,
      fillColor: false,
      lineColor: "#666666"
    });
    return $(this);
  };

  $('span.sparkline').sparklineStatus();

  $('a#global-status-link').click( function() {
      $(this).parents('li').addClass('active');
      $('#global-status-target:hidden')
        .load(this.href)
        .blindDown('fast', function(){$('#global-status-target span.sparkline').sparklineStatus()});

      $('#global-status-link, #global-status-target').bind('click.hideStatus', function(e){e.stopPropagation()});
      $(document).one('click.hideStatus', function() {
        $('#global-status-target').html('').blindUp();
        $('a#global-status-link').parents('li').removeClass('active');
      });
      $.sparkline_display_visible()
      return false;
  })
  
});
