$(document).ready(function() {
  $('button.drop, a.drop').click( function(e) {
    var self = $(this);
    var all_drops = self.parents('div').find('.dropdown');
    var drop = self.next('.dropdown');

    if (drop.is(':hidden')) {
      all_drops.hide();
      drop.show();
      drop.bind('click', function(e){e.stopPropagation()});
      $(document).one('click.hideDropdown', function() {drop.hide()});
    } else {
      all_drops.hide();
    };

    return false;
  })

  $('table.main th input#check_all').click( function() {
    self = $(this);
    self.parents('table').find('td input:checkbox').attr('checked', self.is(':checked'));
  });

  $.fn.sparklineStatus = function(opt) {
    opt = $.extend({}, {
      spotRadius: 0,
      fillColor: false,
      lineColor: "#666666",
      width: '39px'
    }, opt)

    $(this).sparkline('html', opt);
    return $(this);
  };

  $('span.sparkline').not('.percent').sparklineStatus();
  $('span.sparkline.percent').sparklineStatus({
    type: 'bar',
    barWidth: 1,
    barSpacing: 1,
    barColor: '#999',
    chartRangeMin: 0,
    chartRangeMax: 100,
    fillColor: '#DFD'
  });

  $('a#global-status-link').click( function() {
      $(this).parents('li').addClass('active');
      $('#global-status-target:hidden')
        .show(10, function(){
          $.sparkline_display_visible()
        });

      $('#global-status-link, #global-status-target').bind('click.hideStatus', function(e){e.stopPropagation()});
      $(document).one('click.hideStatus', function() {
        $('#global-status-target').hide();
        $('a#global-status-link').parents('li').removeClass('active');
      });
      return false;
  })


  $('table.flot-data.benchmark').graphTable(
      {height: '150px', width: '100%'},
      {legend: {show: false },
       lines:  {show: true },
       points: {show: true },
       grid:   {color: "#999"},
       xaxis:  {mode: "time",
                timeformat: "%m/%d/%y<br />%h:%M%p"},
       yaxis:  {tickFormatter: function(val, axis){
        return val.toString() + 's'
      }}});

  $('table.flot-data.percent').graphTable(
      {height: '150px', width: '100%'},
      {legend: {show: false },
       bars:   {show: true,
                barWidth: 10 * 60 * 1000},
       grid:   {color: "#999"},
       xaxis:  {mode: "time",
                timeformat: "%m/%d/%y<br />%h:%M%p"},
       yaxis:  {min: 0, max: 100,
                tickFormatter: function(val, axis){
        return val.toString() + '%'
      }}});

  $('#node_group_names').facebooklist('#existing_node_groups', {url:'/node_groups.json',cache:0}, 10, {userfilter:1,casesensetive:0}, 0);
  $('#node_class_names').facebooklist('#existing_node_classes', {url:'/node_classes.json',cache:0}, 10, {userfilter:1,casesensetive:0}, 0);
  
  $('a.in-place').click(function() {
    $(this).parents('.header').hide().next('.in-place').show().find('input[type=text]').focus();
    return false;
  });
  
});
