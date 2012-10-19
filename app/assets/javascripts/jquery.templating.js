/**
 * Copyright Yehuda Katz
 * with assistance by Jay Freeman
 * 
 * You may distribute this code under the same license as jQuery (BSD or GPL
 **/

/*

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>Templating</title>
    <script src="../../jquery/dist/jquery.min.js"></script>
    <script src="jquery.templating.js"></script>
    <script>
      jQuery(function ($) {
          $("a.updateTemplate").click(function() {
            $(this.rel).loadTemplate(this.href);
            return false;
          });
          $("._template").templatize();
      });
    </script>
  </head>
  <body>
    <div class="_template" id="myTemplate">
      <![CDATA[
        <{{tag}} href={{href}}>{{first}} {{last}}</{{tag}}>
        <p>Bar</p>
        <div>First Name: {{first}}</div>
        <div>Last Name: {{last}}</div>
      ]]>
    </div>
    <a href="foo" rel="#myTemplate" class="updateTemplate">Click</a>
  </body>
</html>
  
*/

(function ($) {
  $.makeTemplate = function (template, begin, end) {
    var rebegin = begin.replace(/([\]{}[\\])/g, '\\$1');
    var reend = end.replace(/([\]{}[\\])/g, '\\$1');

    var code = "try { with (_context) {" +
      "var _result = '';" +
        template
          .replace(/[\t\r\n]/g, ' ')
          .replace(/^(.*)$/, end + '$1' + begin)
          .replace(new RegExp(reend + "(.*?)" + rebegin, "g"), function (text) {
            return text
              .replace(new RegExp("^" + reend + "(.*)" + rebegin + "$"), "$1")
              .replace(/\\/g, "\\\\")
              .replace(/'/g, "\\'")
              .replace(/^(.*)$/, end + "_result += '$1';" + begin);
          })
          .replace(new RegExp(rebegin + "=(.*?)" + reend, "g"), "_result += ($1);")
          .replace(new RegExp(rebegin + "(.*?)" + reend, "g"), ' $1 ')
          .replace(new RegExp("^" + reend + "(.*)" + rebegin + "$"), '$1') +
      "return _result;" +
    "} } catch(e) { return '' } ";

    return new Function("_context", code);
  };
})(jQuery);