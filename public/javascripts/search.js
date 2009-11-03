(function($) {  
  $.fn.zebraStripe = function() {
    $(this)
      .find('tbody tr:visible')
      .removeClass('even')
      .filter(function (index) {return index % 2 == 1})
      .addClass('even');
    return this;
  };

  $.fn.filterList = function(opt) {
    return this.each(function() {
      var self = $(this);
      self.keyup(function(e) {
        var text = self.attr('value');
        var table = self.parents('.table-tools').next('table')
        var rows = table.find('tbody tr')
        var matches = text == "" ? rows : rows.find('td.name a:contains("'+text+'")').parents('tr');
        rows.hide();
        matches.show();
        table.trigger('reindex');
      })
    });
  };
})(jQuery);
