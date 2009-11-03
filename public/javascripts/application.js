$(document).ready(function() {
  $('.collapsible').hide()
  $('a.active.collapsible-trigger').live('click', function(event) {
    var href = $(this).attr("href");
    $(href).removeClass("active");
    $(this).removeClass("active");
    $(this).find('span.response').html("Show");
    return false;
  });

  $('a.collapsible-trigger:not(.active)').live('click', function(event) {
    var href = $(this).attr("href");
    $(href).addClass("active");
    $(this).addClass("active");
    $(this).find('span.response').html("Hide");
    return false;
  });

  $('table.inspector').bind('reindex', function(event) {
     $(this).zebraStripe();
  });
  
  $('table.inspector').trigger('reindex')

  $('.filter-list').filterList();  
});
