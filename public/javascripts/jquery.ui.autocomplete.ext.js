/*
 * jQuery Autocomplete Extensions
 * Version 1.1 (07/10/2009)
 * Written by Yehuda Katz (wycats@gmail.com) and Rein Henrichs (reinh@reinh.com)
 * Forked and maintained by Nikos Dimitrakopoulos (os@nikosd.com)
 * Additional contributions from Emmanuel Gomez, Austin King
 * @requires: jQuery v1.2 or later
 * 
 * Copyright 2007-2009 Yehuda Katz, Rein Henrichs
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 */

(function($) {
  $.ui = $.ui || {};
  $.ui.autocomplete = $.ui.autocomplete || {};
  $.ui.autocomplete.ext = $.ui.autocomplete.ext || {};
  
  /*
   * @description Overrides the default 'getList' option with remote call replacement.
   *
   * @param {Object} opt Should contain a .ajax property with the url of the remote service to call.
   * @returns A function which calls the remote service, fetches the result and triggers an "updateList" event on the input element.
   */
  $.ui.autocomplete.ext.ajax = function(opt) {
    var ajax = opt.ajax;
    return { getList: function(input) { 
			if (input.val().match(/^\s*$/)) return false;
      $.getJSON(ajax, { val: input.val() }, function(json) { input.trigger("updateList", [json]); });
    } };
  };

  /*
   * @description Overrides the default 'template' option.
   *
   * @param {Object} opt Should contain a .templateText string with the template to parse and return.
   * @returns A function that executes the given template with the obj passed to it.
   */
  $.ui.autocomplete.ext.templateText = function(opt) {
    var template = $.makeTemplate(opt.templateText, "<%", "%>");
    return { template: function(obj) { return template(obj); } };
  };
  
})(jQuery);
