jQuery(function($) {
  $('a.delete_parameter').livequery(
    function() {
      $(this).click(function() {
        $(this).parent().remove(); 
      });
    }
  );
});
