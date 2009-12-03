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

  $('input.node-group-search')
    .autocomplete({
      ajax: '/node_groups/search.json',
      match: function(typed) { return true; },
      insertText: function(node_group) { return node_group.node_group.name; }
    })
    .bind('activate.autocomplete', function(e, node_group) {
      var ng = node_group.node_group;
      var tr = "<tr class='node_group'><td class='key'><a href='/node_groups/"+ng.id+"'>"+ng.name+"</a></td><td>"+ng.description+"<input type='hidden' name='node[node_groups[]' value='"+ng.id+"'/></td><td class='actions'><a class='icon delete' href='#'><span>(add)</span></a></td></tr>";
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
      var ng = node_class.node_class;
      var tr = "<tr class='node_class'><td class='key'><a href='/node_classes/"+ng.id+"'>"+ng.name+"</a></td><td>"+ng.description+"<input type='hidden' name='node[node_classes[]' value='"+ng.id+"'/></td><td class='actions'><a class='icon delete' href='#'><span>(add)</span></a></td></tr>";
      $(e.target)
        .attr('value', '')
        .parents('table').find('tbody').append(tr);
    });
});
