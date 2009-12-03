jQuery(function($) {
  $.toId = function(object) {
    return object.attr('id').split('_').slice(-1);
  }

  $('tr a.delete').livequery('click', 
    function(event) {
      $(this).parents("tr").remove().parents('tbody').trigger('restripe');
      event.preventDefaults();
    }
  );

  $('#node-groups a.delete').livequery('click', 
    function(event) {
      $('input.node-group-search').trigger('cancel.autocomplete');
      event.preventDefaults();
    }
  );

  $('#node-classes a.delete').livequery('click', 
    function() {
      $(this)
        .removeClass('delete').addClass('add')
        .parents('tr').remove()
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
