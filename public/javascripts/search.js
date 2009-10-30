(function($) {
  $.fn.filterList = function(opt) {
    return this.each(function() {
      var self = $(this);
      self.keyup(function(e) {
        var text = self.attr('value');
        var rows = self.parents('.table-tools').next('table').find('tbody tr')
        var matches =  rows.find('td.name a:contains("'+text+'")').parents('tr');
        rows.hide();
        matches.show();
      })
    });
  };
})(jQuery);