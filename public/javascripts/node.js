jQuery(function($) {
  $.toId = function(object) {
    return object.attr('id').split('_').slice(-1);
  }

  $('a.delete-parameter').livequery('click', 
    function() {
      $(this).parents("tr").remove(); 
    }
  );

  $('a.add-node-group').livequery('click', 
    function() {
      var self = $(this)
      self
        .removeClass('add-node-group')
        .addClass('remove-node-group')
        .parent()
          .remove()
          .appendTo('#associated-groups ul'); 
      var hidden_field = $('<input type="hidden" name="node[node_group_ids][]">');
      hidden_field.val($.toId(self.parent()));
      $('#node-groups').prepend(hidden_field);
      return false;
    }
  );

  $('a.remove-node-group').livequery('click', 
    function() {
      var self = $(this);
      self
        .removeClass('remove-node-group')
        .addClass('add-node-group')
        .parent()
          .appendTo('#available-groups ul'); 
      var id = $.toId(self.parent());
      $("input[name=node\\[node_group_ids\\]\\[\\]][value="+id+"]").remove();
      return false;
    }
  );

  $('a.add-node-class').livequery('click', 
    function() {
      var self = $(this)
      self
        .removeClass('add-node-class')
        .addClass('remove-node-class')
        .parent()
          .remove()
          .appendTo('#associated-classes ul'); 
      var hidden_field = $('<input type="hidden" name="node[node_class_ids][]">');
      hidden_field.val($.toId(self.parent()));
      $('#node-classes').prepend(hidden_field);
      return false;
    }
  );

  $('a.remove-node-class').livequery('click', 
    function() {
      var self = $(this);
      self
        .removeClass('remove-node-class')
        .addClass('add-node-class')
        .parent()
          .appendTo('#available-classes ul'); 
      var id = $.toId(self.parent());
      $("input[name=node\\[node_class_ids\\]\\[\\]][value="+id+"]").remove();
      return false;
    }
  );
});
