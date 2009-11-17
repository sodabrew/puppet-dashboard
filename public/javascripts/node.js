jQuery(function($) {
  $.toId = function(object) {
    return object.attr('id').split('_').slice(-1);
  }

  $('a.delete-parameter').livequery('click', 
    function() {
      $(this).parents("tr").remove(); 
      return false;
    }
  );

  $('#node-groups a.delete').livequery('click', 
    function() {
      $(this)
        .removeClass('delete').addClass('add')
        .parents('tr').remove().prependTo('#available-node-groups table tbody')
        $('tbody').trigger('restripe')
      return false;
    }
  );

  $('#available-node-groups a.add').livequery('click', 
    function() {
      $(this)
        .removeClass('add').addClass('delete')
        .parents('tr').remove().appendTo('#node-groups table tbody')
        $('tbody').trigger('restripe')
      return false;
    }
  );

  $('table.inspector tbody').live('restripe',
    function() {
      $(this).find('tr').css('background', 'white').end().find('tr:nth-child(even)').css('background', '#e8ecf1')
    }
  );
});
