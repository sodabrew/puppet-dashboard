jQuery(function($) {
  $('a.delete_parameter').livequery(
    function() {
      $(this).click(function() {
        $(this).parent().remove(); 
      });
    }
  );
  
  $('a.associate-link').livequery(
    function() {
      $(this).click(function() {
        jQuery('div#node-classes').load(this.href);
        return false;
      });
    }
  );

  $('a.disassociate-link').livequery(
    function() {
      $(this).click(function() {
        jQuery('div#node-classes').load(this.href);
        return false;
      });
    }
  );
});
