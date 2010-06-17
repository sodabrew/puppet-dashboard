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

  J('#node_group_names').facebooklist('#existing_node_groups', {url:relative_url_root+'/node_groups.json',cache:0}, 10, {userfilter:0,casesensetive:1}, 0);
  J('#node_class_names').facebooklist('#existing_node_classes', {url:relative_url_root+'/node_classes.json',cache:0}, 10, {userfilter:0,casesensetive:1}, 0);
  
  J('a.in-place').click(function() {
    J(this).parents('.header').hide().next('.in-place').show().find('input[type=text]').focus();
    return false;
  });

  J.fn.mapHtml = function() { return this.map(function(){return J(this).html()}).get(); }
  J.fn.mapHtmlInt = function() { return this.map(function(){return parseInt(J(this).html())}).get(); }
  J.fn.mapHtmlFloat = function() { return this.map(function(){return parseFloat(J(this).html())}).get(); }

  J("table.data.runtime").each(function(i){
    var id, label_data, runtime_data, runtime_data_label
    id = "table_runtime"+i
    J("<div id='"+id+"' style='height:150px'></div>").insertAfter(J(this));

    label_data = J(this).find("tr.labels th").mapHtml();
    runtime_data = J(this).find("tr.runtimes td").mapHtmlFloat();

    new Grafico.LineGraph($(id),
      {
        runtimes: runtime_data
      },
      {
        grid: false,
        markers: "value",
        labels: label_data,
        label_color: '#666',
        colors: { runtimes: "#009" },
        show_ticks: false,
        meanline: true,
        vertical_label_unit: "ms",
        stroke_width: 3,
        font_size: 10,
        start_at_zero: false,
        show_horizontal_labels: false,
      }
    );

    J(this).hide();
  });



  J("table.data.status").each(function(i){
    var id, label_data, succeeded_data, failed_data
    id = "table_status"+i
    J("<div id='"+id+"' style='height:150px'></div>").insertAfter(J(this));

    label_data = J(this).find("tr.labels th").mapHtml();
    succeeded_data = J(this).find("tr.succeeded td").mapHtmlInt();
    failed_data = J(this).find("tr.failed td").mapHtmlInt();

    succeeded_data_label = J.map(succeeded_data, function(item, index){return item+" successful"});
    failed_data_label = J.map(failed_data, function(item, index){return item+" failed"});
    
    new Grafico.StackedBarGraph($(id),
      {
        succeeded: succeeded_data,
        failed: failed_data
      },
      {
        grid: false,
        labels: label_data,
        label_color: '#666',
        colors: { succeeded: "#0C3", failed: "#901" },
        show_ticks: false,
        datalabels: { succeeded: succeeded_data_label, failed: failed_data_label },
        font_size: 9,
        label_rotation: -30,
      }
    );

    J(this).hide();
  });

});
