var UNRESPONSIVE = '#888';
var FAILED       = '#c21';
var PENDING      = '#e72';
var CHANGED      = '#069';
var UNCHANGED    = '#093';
var ALL          = '#000';

jQuery(document).ready(function(J) {
  J(":input[placeholder]").placeholder();
  J('table.main .status img[title]').tipsy({gravity: 's'});

  J('button.drop, a.drop').click( function(e) {
    var self = J(this);
    var all_drops = self.parents('div').find('.dropdown');
    var drop = self.next('.dropdown');

    if (drop.is(':hidden')) {
      all_drops.hide();
      drop.show();
      drop.bind('click', function(e){e.stopPropagation()});
      J(document).one('click.hideDropdown', function() {drop.hide()});
    } else {
      all_drops.hide();
    };

    return false;
  })

  J('table.main th input#check_all').click( function() {
    self = J(this);
    self.parents('table').find('td input:checkbox').attr('checked', self.is(':checked'));
  });

  J('a.in-place').click(function() {
    J(this).parents('.header').hide().next('.in-place').show().find('input[type=text]').focus();
    return false;
  });

  J.fn.mapHtml = function() { return this.map(function(){return J(this).html()}).get(); }
  J.fn.mapHtmlInt = function() { return this.map(function(){return parseInt(J(this).html())}).get(); }
  J.fn.mapHtmlFloat = function() { return this.map(function(){return parseFloat(J(this).html())}).get(); }

  J("table.data.runtime").each(function(i){
    var id = "table_runtime"+i;
    var selector = "<div id='"+id+"' style='height:150px; width: auto;'></div>";
    if (J(selector).length == 0) {
      J(selector).insertAfter(J(this));
    }

    var label_data = J(this).find("tr.labels th").mapHtml();
    var runtime_data = J(this).find("tr.runtimes td").mapHtmlFloat();
    var format = "%" + (Math.max.apply(null, runtime_data) < 3 ? ".1f" : "d") + " s"; 

    J.jqplot(id, [runtime_data], {
      seriesColors: ["#009"],
      captureRightClick: false,
      seriesDefaults:{
        markerOptions: {
          show: false
        },
        pointLabels: {
          show: false
        }
      },
      highlighter: {
        show: true,
        sizeAdjust: 5,
        tooltipAxes: 'y'
      },
      axes: {
        xaxis: {
          renderer: J.jqplot.CategoryAxisRenderer,
          tickRenderer: J.jqplot.CanvasAxisTickRenderer,
          ticks: label_data,
          tickOptions: {
            angle: -30,
            fontSize: '9px',
            textColor: '#666'
          }
        },
        yaxis: {
          // Don't pad out the bottom of the data range.  By default,
          // axes scaled as if data extended 10% above and below the
          // actual range to prevent data points right on grid boundaries.
          // Don't want to do that here.
          padMin: 0,

          tickOptions: {
            formatString: format
          }
        }
      },
      grid: {
        background: '#fff',
        drawGridlines: false,
        borderWidth: 1,
        shadow: false
      },
      legend: {
        show: false,
      }      
    });

    J(this).hide();
  });



  J("table.data.status").each(function(i){
    var id = "table_status"+i;
    J("<div id='"+id+"' style='height: 150px; width: auto; margin-right: 100px;'></div>").insertAfter(J(this));

    var label_data = J(this).find("tr.labels th").mapHtml();
    var changed_data = J(this).find("tr.changed td").mapHtmlInt();
    var unchanged_data = J(this).find("tr.unchanged td").mapHtmlInt();
    var pending_data = J(this).find("tr.pending td").mapHtmlInt();
    var failed_data = J(this).find("tr.failed td").mapHtmlInt();

    var changed_data_label = J.map(changed_data, function(item, index){return item+" changed"});
    var unchanged_data_label = J.map(unchanged_data, function(item, index){return item+" unchanged"});
    var pending_data_label = J.map(pending_data, function(item, index){return item+" pending"});
    var failed_data_label = J.map(failed_data, function(item, index){return item+" failed"});

    J.jqplot(id, [changed_data, unchanged_data, pending_data, failed_data], {
      stackSeries: true,
      captureRightClick: false,
      seriesDefaults:{
        renderer:J.jqplot.BarRenderer,
        rendererOptions: {
          barMargin: 0,
          shadow: false,
          highlightMouseDown: true
        },
        pointLabels: {
          show: false
        }
      },
      series: [
        {
          label: 'Changed',
          color: CHANGED
        },
        {
          label: 'Unchanged',
          color: UNCHANGED
        },
        {
          label: 'Pending',
          color: PENDING
        },
        {
          label: 'Failed',
          color: FAILED
        }
      ],
      highlighter: {
        show: true,
        showMarker: false,
        sizeAdjust: 5,
        tooltipAxes: 'y',
        tooltipLocation: 'n'
      },
      axes: {
        xaxis: {
          renderer: J.jqplot.CategoryAxisRenderer,
          tickRenderer: J.jqplot.CanvasAxisTickRenderer,
          ticks: label_data,
          tickOptions: {
            angle: -30,
            fontSize: '9px',
            textColor: '#666'
          }
        },
        yaxis: {
          // Don't pad out the data range.  By default,
          // axes scaled as if data extended 10% above and below the
          // actual range to prevent data points right on grid boundaries.
          // Don't want to do that here.
          pad: 0,
          min: 0
        }
      },
      grid: {
        background: '#fff',
        drawGridlines: false,
        borderWidth: 0,
        shadow: false
      },
      legend: {
        show: true,
        location: 'ne',
        placement: 'outside'
      }      
    });

    J(this).hide();
  });
  init_expandable_list();

  J('.reports_show_action #report-tabs').show();
  J('.reports_show_action .panel').addClass('tabbed');
  J('.reports_show_action #report-tabs li').click(function() {
    panelID = this.id.replace(/-tab$/, '');
    J('.reports_show_action #report-tabs li').removeClass('active');
    J('.reports_show_action .panel').hide();
    J(this).addClass('active');
    J('#' + panelID).show();
  });
  J('.reports_show_action #report-tabs li:first').click();

  J('.pages_home_action #home-tabs').show();
  J('.pages_home_action .panel').addClass('tabbed');
  J('.pages_home_action #home-tabs li').click(function() {
    panelID = this.id.replace(/-tab$/, '');
    J('.pages_home_action #home-tabs li').removeClass('active');
    J('.pages_home_action .panel').hide();
    J(this).addClass('active');
    J('#' + panelID).show();
  });
  J('.pages_home_action #home-tabs li:first').click();

  init_sidebar_links();
  init_skiplink_target();
});

function init_expandable_list() {
  jQuery( '.expand-all' ).on( 'click', function() {
    jQuery('.expandable-link.collapsed-link').each(toggle_expandable_link);
    return false;
  });
  jQuery( '.collapse-all' ).on( 'click', function() {
    jQuery('.expandable-link').not('.collapsed-link').each(toggle_expandable_link);
    return false;
  });
  jQuery( '.expandable-link' ).on( 'click', function() {
    toggle_expandable_link.call(this);
    return false;
  });
}

function toggle_expandable_link() {
  expansionTime = 30; // ms
  jQuery(this).toggleClass('collapsed-link');
  jQuery(this.id.replace('expand', '#expandable'))
    .toggle('blind', {}, expansionTime);
  if (jQuery(this).hasClass('collapsed-link')) {
    if (jQuery('.expandable-link').not('.collapsed-link').size() == 0) {
      var old_text = jQuery('.collapse-all').text();
      jQuery('.collapse-all')
        .removeClass( 'collapse-all' )
        .addClass( 'expand-all' )
        .text( old_text.replace( 'collapse', 'expand' ));
    }
  } else {
    if (jQuery('.expandable-link.collapsed-link').size() == 0) {
      var old_text = jQuery('.expand-all').text();
      jQuery('.expand-all')
        .removeClass( 'expand-all' )
        .addClass( 'collapse-all' )
        .text( old_text.replace( 'expand', 'collapse' ));
    }
  }
}

function display_file_popup(url) {
    jQuery.colorbox({href: url, width: '80%', height: '80%', iframe: true});
}

function init_sidebar_links() {
  jQuery( '.node_summary .primary tr' ).each( function() {
    jQuery( this )
      .hover(
        function() {
          jQuery( this ).addClass( 'hover' );
        },
        function() {
          jQuery( this ).removeClass( 'hover' );
        }
      )
      .click( function() {
        var url = jQuery( this ).find( '.count a' ).attr( 'href' );
        document.location.href = url;
        return false;
      });
  });
}

function init_skiplink_target() {
  var is_webkit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
  var is_opera = navigator.userAgent.toLowerCase().indexOf('opera') > -1;
  if(is_webkit || is_opera)
  {
    var target = document.getElementById('skiptarget');
    target.href="#skiptarget";
    target.innerText="Start of main content";
    target.setAttribute("tabindex" , "0");
    document.getElementById('skiplink').setAttribute("onclick" , "document.getElementById('skiptarget').focus();");
  }
}
