(function($) {  
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
        table.find('tbody').trigger('restripe');
      })
    });
  };

  $.fn.autocompleteInspector = function(url) {
    var self = this
    self.keyup(function(e) {
      var text = $(this).attr('value');
      var div = self.parents('.table-tools').next('.results');
      var html = $.get(url, { q: text }, function(html, status) {
        div.html(html);
      }, "html");
    });
    return self;
  }
})(jQuery);
