/*
FCBKcomplete 1.09
- Jquery version required: 1.2.x, 1.3.x

Changelog:
- 1.09 IE crash fixed

- 1.08 some minor bug fixed

- 1.07 case sensetive added
applied filter to non ajax items
filter algorithm changed
cache for ajax request added
up/down with auto scrolling
minor code fixes

- 1.06 auto heigth fix
event bind on main element for better user frendly experience
filter for items
up/down keys supported from now

- 1.05	bindEvents function fixed thanks to idgnarn

- 1.04	IE7 <em> tag replace fixed

- 1.03 IE7 & IE6 crash fixed
IE7 css fixed

- 1.02 json parsing fixed
remove element fixed

- 1.01 some bugs fixed

- 1.0	migration from prototype
*/

/* Coded by: emposha <admin@emposha.com> */
/* Copyright: Emposha.com <http://www.emposha.com/> - Distributed under MIT - Keep this message! */
/*
* list - preadded elements
* ajax - object with two parametrs a) url to fetch json object b) use cache
* height - maximum number of element shown before scroll will apear
* filter - object with two parametrs a)case sensitive b) show/hide filtered items
* newel - show typed text like a element
*/

jQuery.fn.facebooklist = function(list, ajax, height, filter, newel){
  if (!this.length) { return }

  var KEY = {
    ESC: 27,
    RETURN: 13,
    TAB: 9,
    BS: 8,
    DEL: 46,
    UP: 38,
    DOWN: 40
  };

  var elem = jQuery(this);
  elem.attr('disabled', 'disabled');
  var feed = document.createElement('ul');
  feed = jQuery(feed).hide().addClass('facebook-auto');

  var addHiddenInput = function(value){
    var input = document.createElement('input');
    jQuery(input).attr({
      'type': 'hidden',
      'name': (elem.attr('name')),
      'value': value
    });
    return input;
  }

  var addItem = function(item, preadded){
    var title = item.text();
    var value = (title);
    var li = document.createElement('li');
    var txt = document.createTextNode(title);
    var aclose = document.createElement('a');
    var input = addHiddenInput(value);
    jQuery(li).attr({
      'class': 'bit-box'
    });
    jQuery(li).prepend(txt);
    jQuery(aclose).attr({
      'class': 'closebutton',
      'href': '#'
    });
    li.appendChild(aclose);
    li.appendChild(input);
    holder.appendChild(li);
    jQuery(aclose).click(function(){
      jQuery(this).parent('li').fadeOut('fast', function(){
        jQuery(this).remove();
      });
      return false;
    });
    if (!preadded) {
      console.log('removing input');
      jQuery(holder).find('li.bit-input').remove();
      addInput();
    }
    feed.hide();
  }

  var defaultFilter = function(input){
    if (counter > height) {
      feed.css({
        'height': (height * 24) + 'px',
        'overflow': 'auto'
      });
    }
    else {
      feed.css('height', 'auto');
    }
  }

  var feedFilter = function(item, caption, input){
    if (filter.userfilter) {
      if (filter.casesensetive) {
        if (caption.indexOf(input) != -1) {
          item.html(caption.replace(input, '<em>' + input + '</em>'));
          return true;
        }
      }
      else {
        if (caption.toLowerCase().indexOf(input) != -1) {
          item.html(caption.replace(input, '<em>' + input + '</em>'));
          return true;
        }
      }
    }
    else {
      item.html(caption.replace(input, '<em>' + input + '</em>'));
      return true;
    }
  }

  var addItemFeed = function(data, input){
    feed.children('li[fckb=2]').remove();
    jQuery.each(data, function(i, val){
      if (val.name) {
        var li = document.createElement('li');
        jQuery(li).attr({
          'fckb': '2'
        });
        if (feedFilter(jQuery(li), val.name, input)) {
          feed.append(li);
          counter++;
        }
      }
    });
    defaultFilter(input);
  }

  var addTextItemFeed = function(value){
    if (newel) {
      feed.children('li[fckb=1]').remove();
      var li = document.createElement('li');
      jQuery(li).attr({
        'rel': value,
        'fckb': '1'
      });
      jQuery(li).html(value);
      feed.prepend(li);
      counter++;
    }
  }

  var removeFeedEvent = function () {
    feed.children('li').unbind('mouseover');	
    feed.children('li').unbind('mouseout');
    feed.mousemove(function () {
      bindFeedEvent();
      feed.unbind('mousemove');
    })	
  }

  var bindFeedEvent = function () {
    feed.children('li').mouseover(function(){
      feed.children('li').removeClass("auto-focus");
      jQuery(this).addClass("auto-focus");
      nowFocusOn = jQuery(this);
    });
    feed.children('li').mouseout( function(){
      jQuery(this).removeClass("auto-focus");
      nowFocusOn = null;
    });
  }

  var bindEvents = function(){
    var maininput = jQuery('.maininput');
    bindFeedEvent();
    feed.children('li').unbind('click');
    feed.children('li').click(function(){
      addItem(jQuery(this));
      feed.hide();
    });
    maininput.unbind('keydown');
    maininput.keydown(function(event){
      var k = event.which || event.keycode;
      
      if (k == 13 && nowFocusOn != null) {
        addItem(jQuery(nowFocusOn));
        feed.hide();
        event.preventDefault();
      }
      if (k == 40) {
        removeFeedEvent();
        if (typeof(nowFocusOn) == 'undefined' || nowFocusOn.length == 0) {
          nowFocusOn = jQuery(feed.children('li:visible:first'));
          feed.get(0).scrollTop = 0;
        }
        else {
          nowFocusOn.removeClass("auto-focus");
          nowFocusOn = nowFocusOn.nextAll('li:visible:first');
          var prev = parseInt(nowFocusOn.prevAll('li:visible').length,10);
          var next = parseInt(nowFocusOn.nextAll('li:visible').length,10);
          if ((prev > Math.round(height /2) || next <= Math.round(height /2)) && typeof(nowFocusOn.get(0)) != 'undefined') {
            feed.get(0).scrollTop = parseInt(nowFocusOn.get(0).scrollHeight,10) * (prev - Math.round(height /2));
          }
        }
        feed.children('li').removeClass("auto-focus");
        nowFocusOn.addClass("auto-focus");
      }
      if (k == 38) {
        removeFeedEvent();
        if (typeof(nowFocusOn) == 'undefined' || nowFocusOn.length == 0) {
          nowFocusOn = jQuery(feed.children('li:visible:last'));
          feed.get(0).scrollTop = parseInt(nowFocusOn.get(0).scrollHeight,10) * (parseInt(feed.children('li:visible').length,10) - Math.round(height /2));
        }
        else {
          nowFocusOn.removeClass("auto-focus");
          nowFocusOn = nowFocusOn.prevAll('li:visible:first');
          var prev = parseInt(nowFocusOn.prevAll('li:visible').length,10);
          var next = parseInt(nowFocusOn.nextAll('li:visible').length,10);
          if ((next > Math.round(height /2) || prev <= Math.round(height /2)) && typeof(nowFocusOn.get(0)) != 'undefined') {
            feed.get(0).scrollTop = parseInt(nowFocusOn.get(0).scrollHeight,10) * (prev - Math.round(height /2));
          }
        }
        feed.children('li').removeClass("auto-focus");
        nowFocusOn.addClass("auto-focus");
      }
    });
  }

  var addInput = function(){
    var li = document.createElement('li');
    var input = document.createElement('input');
    jQuery(li).attr({
      'class': 'bit-input',
    });
    jQuery(input).attr({
      'type': 'text',
      'class': 'maininput'
    });
    li.appendChild(input);
    holder.appendChild(li);
    jQuery(input).focus(function(){
      feed.fadeIn('fast');
    });
    jQuery(holder).click(function(){
      jQuery(input).focus();
      if (feed.length && jQuery(input).val().length) {
        feed.show();
      }
      else {
        feed.children('li[fckb=2]').remove();
        feed.children('li').addClass('hidden');
        feed.css('height','0px');
        jQuery('.default').show();
      }
    });
    jQuery(input).keyup(function(event){
      if (event.keyCode != 40 && event.keyCode != 38) {
        counter = 0;
        var etext = jQuery(input).val();
        addTextItemFeed(etext);
        if (ajax.url) {
          if (ajax.cache && cache.length > 0) {
            addItemFeed(cache, etext);
            bindEvents();
          }
          else {
            jQuery.getJSON(ajax.url + '?tag=' + etext, null, function(data){
              addItemFeed(data, etext);
              cache = data;
              bindEvents();
            });
          }
        }
        else {
          bindEvents();
        }
        jQuery('.default').hide();
        feed.show();
      }
    });
  }

  if (typeof(elem) != 'object') {
    elem = jQuery(elem);
  }
  if (typeof(list) != 'object') {
    list = jQuery(list);
  }
  var cache = {};
  var counter = 0;
  var nowFocusOn;
  var holder = document.createElement('ul');
  elem.css('display', 'none');
  jQuery(holder).attr('class', 'holder');

  if (list && list.children('li').length) {
    jQuery.each(list.children('li'), function(i, val){
      addItem(jQuery(list.children('li')[i]), 1);
    });
    list.hide();
  }

  addInput();
  elem.before(holder);
  jQuery(holder).after(jQuery(feed));

  jQuery(document).click(function (event) {
    if (jQuery(event.target).attr('class') != 'holder' && jQuery(event.target).attr('class') != 'maininput') {
      jQuery('.default').hide();
      jQuery(feed).hide();
      
    }
  });
}
