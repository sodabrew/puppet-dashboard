/* jQuery Autocomplete
 * Version 1.1 (07/10/2009)
 * Written by Yehuda Katz (wycats@gmail.com) and Rein Henrichs (reinh@reinh.com)
 * Forked and maintained by Nikos Dimitrakopoulos (os@nikosd.com)
 * Additional contributions from Emmanuel Gomez, Austin King
 * @requires jQuery v1.2, jQuery dimensions plugin
 *
 * Copyright 2007-2009 Yehuda Katz, Rein Henrichs
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * @description Form autocomplete plugin using preloaded or Ajax JSON data source
 *
 * @example $('input#user-name').autocomplete({list: ["quentin", "adam", "admin"]})
 * @desc Simple autocomplete with basic JSON data source
 *
 * @example $('input#user-name').autocomplete({ajax: "/usernames.js"})
 * @desc Simple autocomplete with Ajax loaded JSON data source
 *
 */
(function($) {

  $.ui = $.ui || {};
  $.ui.autocomplete = $.ui.autocomplete || {};
  var active;

  var KEY = {
    ESC: 27,
    RETURN: 13,
    TAB: 9,
    BS: 8,
    DEL: 46,
    UP: 38,
    DOWN: 40
  };

  $.fn.autocomplete = function(opt) {

    /* Default options */
    opt = $.extend({}, {
      timeout: 500,
      threshold: 100,
      getList: function(input) { input.trigger("updateList", [opt.list]); },
      updateList: function(list, val) {
        list = $(list)
          .filter(function() { return opt.match.call(this, val); })
          .map(function() {
            var node = $(opt.template(this))[0];
            $.data(node, "originalObject", this);
            return node;
          });

        if(!list.length || list.length > opt.threshold) { return false; }

        var container = list.wrapAll(opt.wrapper).parents(":last").children();
        // IE seems to wrap the wrapper in a random div wrapper so
        // drill down to the node in opt.wrapper.
        var wrapper_tagName = $(opt.wrapper)[0].tagName;
        for (;container[0].tagName !== wrapper_tagName; container = container.children(':first')) {}
        return container;
      },
      dismissList: function(container) {
        container.remove();
      },
      template: function(str) { return "<li>" + opt.insertText(str) + "</li>"; },
      insertText: function(str) { return str; },
      match: function(typed) { return this.match(new RegExp(typed)); },
      wrapper: "<ul class='jq-ui-autocomplete'></ul>"
    }, opt);

    /* 
     * Additional options from autocomplete.ext (for example 'ajax', and 'templateText') 
     * if these options where passed in the opt object and the $.ui.autocomplete.ext is present.
    */
    if($.ui.autocomplete.ext) {
      for(var ext in $.ui.autocomplete.ext) {
        if(opt[ext]) {
          opt = $.extend(opt, $.ui.autocomplete.ext[ext](opt));
          delete opt[ext];
        }
    } }

    function preventTabInAutocompleteMode(e) {
      var k = e.which || e.keycode;
      if ($.data(document.body, "autocompleteMode") && k == KEY.TAB) {
        e.preventDefault();
      }
    }
    
    function startTypingTimeout(e, element) {
      $.data(element, "typingTimeout", window.setTimeout(function() {
        $(e.target || e.srcElement).trigger("autocomplete");
      }, opt.timeout));
    }

    return this.each(function() {
      $(this)
        .keydown(function(e) {
          preventTabInAutocompleteMode(e);
        })
        .keyup(function(e) {
          var k = e.which || e.keycode;
          if (!$.data(document.body, "autocompleteMode") &&
              (k == KEY.UP || k == KEY.DOWN) &&
              !$.data(this, "typingTimeout")) {
            startTypingTimeout(e, this);
          } else {
            preventTabInAutocompleteMode(e);
          }
        })
        .keypress(function(e) {
          var typingTimeout = $.data(this, "typingTimeout");
          var k = e.keyCode || e.which; // keyCode == 0 in Gecko/FF on keypress
          if(typingTimeout) window.clearInterval(typingTimeout);

          if($.data(document.body, "suppressKey")) {
            return $.data(document.body, "suppressKey", false);
          } else if($.data(document.body, "autocompleteMode") && k < 32 && k != KEY.BS && k != KEY.DEL) {
            return false;
          } else if (k == KEY.BS || k == KEY.DEL || k > 32) { // more than ESC and RETURN and the like
            startTypingTimeout(e, this);
          }
        })
        .bind("autocomplete", function() {
          var self = $(this);

          self.one("updateList", function(e, list) {
            var listContainer = opt.updateList(list, self.val());
            if (listContainer === false) return false;
            list = listContainer.find("li");

            $("body").trigger("off.autocomplete");
            if(!list.length || list.length > opt.threshold) return false;

            var offset = self.offset();
            opt.container = listContainer
              .css({top: offset.top + self.outerHeight(), left: offset.left, width: self.width()})
              .appendTo("body");

            $("body").autocompleteMode(listContainer, self, list.length, opt);
          });

          opt.getList(self);
        });
    });
  };

  $.fn.autocompleteMode = function(container, input, size, opt) {
    var original = input.val();
    var selected = -1;
    var self = this;

    $.data(document.body, "autocompleteMode", true);

    $("body").one("cancel.autocomplete", function() {
      input.trigger("cancel.autocomplete");
      $("body").trigger("off.autocomplete");
      input.val(original);
    });

    $("body").one("activate.autocomplete", function() {
      // Try hitting return to activate autocomplete and then hitting it again on blank input
      // to close it.  w/o checking the active object first this input.trigger() will barf.
      active && input.trigger("activate.autocomplete", [$.data(active[0], "originalObject")]);
      $("body").trigger("off.autocomplete");
    });

    $("body").one("off.autocomplete", function(e, reset) {
      opt.dismissList(container);
      $.data(document.body, "autocompleteMode", false);
      input.unbind("keydown.autocomplete");
      $("body").add(window).unbind("click.autocomplete").unbind("cancel.autocomplete").unbind("activate.autocomplete");
    });

    // If a click bubbles all the way up to the window, close the autocomplete
    $(window).bind("click.autocomplete", function() { $("body").trigger("cancel.autocomplete"); });

    var select = function() {
      active = $("> *", container).removeClass("active").slice(selected, selected + 1).addClass("active");
      input.trigger("itemSelected.autocomplete", [$.data(active[0], "originalObject")]);
      input.val(opt.insertText($.data(active[0], "originalObject")));
    };

    container
      .mouseover(function(e) {
        // If you hover over the container, but not its children, return
        if(e.target == container[0]) return;
        
        // Set the selected item to the item hovered over and make it active
        selected = $("> *", container).index($(e.target).is('li') ? $(e.target)[0] : $(e.target).parents('li')[0]);
        select();
      })
      .bind("click.autocomplete", function(e) {
        $("body").trigger("activate.autocomplete");
        $.data(document.body, "suppressKey", false);
      });

    input
      .bind("keydown.autocomplete", function(e) {
        var k = e.which || e.keyCode; // in IE e.which is undefined

        switch(k) {
          case KEY.ESC:
            $("body").trigger("cancel.autocomplete");
            break;
          case KEY.TAB:
            if (selected == -1){
              selected = selected >= size - 1 ? 0 : selected + 1;
              select();
            } // fall through to KEY.ENTER case
          case KEY.RETURN:
            $("body").trigger("activate.autocomplete");
            break;
          case KEY.DOWN:
            selected = selected >= size - 1 ? 0 : selected + 1;
            select();
            break;
          case KEY.UP:
            selected = selected <= 0 ? size - 1 : selected - 1;
            select();
            break;
          default:
            return true;
        }

        $.data(document.body, "suppressKey", true);
      });
  };

})(jQuery);
