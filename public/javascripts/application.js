jQuery(document).ready(function(J) {
  J('.status span[title]').tipsy({gravity: 's'});

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
    J("<div id='"+id+"' style='height:150px; width: auto'></div>").insertAfter(J(this));

    var label_data = J(this).find("tr.labels th").mapHtml();
    var runtime_data = J(this).find("tr.runtimes td").mapHtmlFloat();

    new Grafico.LineGraph($(id),
      {
        runtimes: runtime_data
      },
      {
        colors: { runtimes: "#009" },
        font_size: 9,
        grid: false,
        label_color: '#666',
        labels: label_data,
        label_rotation: -30,
        markers: "value",
        meanline: true,
        padding_top: 10,
        left_padding: 50,
        // show_horizontal_labels: false,
        show_ticks: false,
        start_at_zero: false,
        stroke_width: 3,
        vertical_label_unit: "s",
      }
    );

    J(this).hide();
  });



  J("table.data.status").each(function(i){
    var id = "table_status"+i;
    J("<div id='"+id+"' style='height: 150px; width: auto;'></div>").insertAfter(J(this));

    var label_data = J(this).find("tr.labels th").mapHtml();
    var changed_data = J(this).find("tr.changed td").mapHtmlInt();
    var unchanged_data = J(this).find("tr.unchanged td").mapHtmlInt();
    var failed_data = J(this).find("tr.failed td").mapHtmlInt();

    var changed_data_label = J.map(changed_data, function(item, index){return item+" changed"});
    var unchanged_data_label = J.map(unchanged_data, function(item, index){return item+" unchanged"});
    var failed_data_label = J.map(failed_data, function(item, index){return item+" failed"});

    new Grafico.StackedBarGraph($(id),
      {
        unchanged: unchanged_data,
        changed: changed_data,
        failed: failed_data
      },
      {
        colors: { changed: "orange", unchanged: "#0C3", failed: "#901" },
        datalabels: { changed: changed_data_label, unchanged: unchanged_data_label, failed: failed_data_label },
        font_size: 9,
        grid: false,
        label_color: '#666',
        label_rotation: -30,
        labels: label_data,
        padding_top: 10,
        left_padding: 50,
        show_ticks: false,
      }
    );

    J(this).hide();
  });
  init_expandable_list();
});

function init_expandable_list() {
  jQuery( '.expand-all' ).live( 'click', function() {
    jQuery('.expandable-link.collapsed-link').each(toggle_expandable_link);
    return false;
  });
  jQuery( '.collapse-all' ).live( 'click', function() {
    jQuery('.expandable-link').not('.collapsed-link').each(toggle_expandable_link);
    return false;
  });
  jQuery( '.expandable-link' ).live( 'click', function() {
    toggle_expandable_link.call(this);
    return false;
  });
}

function toggle_expandable_link() {
  jQuery(this).toggleClass('collapsed-link');
  if (jQuery(this).hasClass('collapsed-link')) {
    jQuery(this.id.replace('expand', '#expandable'))
      .hide('blind');
    if (jQuery('.expandable-link').not('.collapsed-link').size() == 0) {
      var old_text = jQuery('.collapse-all').text();
      jQuery('.collapse-all')
        .removeClass( 'collapse-all' )
        .addClass( 'expand-all' )
        .text( old_text.replace( 'collapse', 'expand' ));
    }
  } else {
    jQuery(this.id.replace('expand', '#expandable'))
      .show('blind', {}, 1000);
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
