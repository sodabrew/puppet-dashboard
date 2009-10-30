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
  
  $('table a[rel=inspect]').click(function load_inspector() {
    $('.secondary-content').load($(this).attr('href')); 
    $(this).parents('tr').siblings().removeClass('active');
    $(this).parents('tr').addClass('active');
    return false;
  });

  $('#inspector .secondary-content .actions a.edit').live('click', function(event){
    $('.secondary-content').load($(this).attr('href')); 
    return false;
  });

  $('.filter-list').filterList();
});
