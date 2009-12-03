jQuery(function($) {
  $.toId = function(object) {
    return object.attr('id').split('_').slice(-1);
  }

  $('caption a.add').live('click', function(event) {
    $(this).parents('table').trigger('update');
  });

  $('tr a.delete').live('click', function(event) {
    var self = $(this)
    var table = self.parents("table")

    self.parents("tr").remove()
    table.trigger('update');
    event.preventDefault();
  });

  $('#node-groups a.delete, #node-classes a.delete').live('click', function(event) {
    $('input.node-group-search, input.node-class-search').trigger('cancel.autocomplete');
    event.preventDefault();
  });

  $('table').live('update', function(event) {
    var thead = $(this).find('thead');
    var tbody = $(this).find('tbody');
    var empty = tbody.find('tr').length < 1
    console.log('TRIGGERED empty: '+empty.toString());
    if ( empty  ) { thead.hide() };
    if ( !empty ) { thead.show() };
    tbody.find('tr').css('background', 'white').end().find('tr:nth-child(even)').css('background', '#e8ecf1');
    event.preventDefault();
  });

  $('table').bind('activate.autocomplete', function() { $(this).trigger('update') });

  $('input.node-group-search')
    .autocomplete({
      ajax: '/node_groups/search.json',
      match: function(typed) { return true; },
      insertText: function(node_group) { return node_group.node_group.name; }
    })
    .bind('activate.autocomplete', function(e, node_group) {
      var item = node_group.node_group;
      var tr = "<tr class='node_group'><td class='key'><a href='/node_groups/"+item.id+"'>"+item.name+"</a></td><td>"+item.description+"<input type='hidden' name='node[node_groups[]' value='"+item.id+"'/></td><td class='actions'><a class='icon delete' href='#'><span>(add)</span></a></td></tr>";
      $(e.target)
        .attr('value', '')
        .parents('table').find('tbody').append(tr);
    });

  $('input.node-class-search')
    .autocomplete({
      ajax: '/node_classes/search.json',
      match: function(typed) { return true; },
      insertText: function(node_class) { return node_class.node_class.name; }
    })
    .bind('activate.autocomplete', function(e, node_class) {
      var item = node_class.node_class
      var tr = "<tr class='node_class'><td class='key'><a href='/node_classes/"+item.id+"'>"+item.name+"</a></td><td>"+item.description+"<input type='hidden' name='node[node_classes[]' value='"+item.id+"'/></td><td class='actions'><a class='icon delete' href='#'><span>(add)</span></a></td></tr>";

      $(e.target)
        .attr('value', '')
        .parents('table').find('tbody').append(tr);
    });
});
