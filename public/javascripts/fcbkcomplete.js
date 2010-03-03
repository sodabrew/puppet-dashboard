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
 * elem - input element id or object
 * list - preadded elements
 * complete - autocomplete div id or object
 * ajax - object with two parametrs a) url to fetch json object b) use cache
 * height - maximum number of element shown before scroll will apear
 * filter - object with two parametrs a)case sensitive b) show/hide filtered items
 * newel - show typed text like a element
 */

jQuery.facebooklist = function(elem, list, complete, ajax, height, filter, newel){

    var addHiddenInput = function(value){
        var input = document.createElement('input');
        $(input).attr({
            'type': 'hidden',
            'name': (elem.attr('id') + '[]'),
            'id': (elem.attr('id') + '[]'),
            'value': value
        });
        return input;
    }
    
    var getChar = function(e){
        if (window.event) {
            keynum = e.keyCode;
        }
        else 
            if (e.which) {
                keynum = e.which;
            }
        if (keynum == 8) 
            return '';
        
        return String.fromCharCode(keynum);
    }
    
    var addItem = function(item, preadded){
        var title = item.text();
        var value = (item.attr('rel') && item.attr('rel') != -1 ? item.attr('rel') : title);
        var li = document.createElement('li');
        var txt = document.createTextNode(title);
        var aclose = document.createElement('a');
        var input = addHiddenInput(value);
        $(li).attr({
            'class': 'bit-box'
        });
        $(li).prepend(txt);
        $(aclose).attr({
            'class': 'closebutton',
            'href': '#'
        });
        li.appendChild(aclose);
        li.appendChild(input);
        holder.appendChild(li);
        $(aclose).click(function(){
            $(this).parent('li').fadeOut('fast', function(){
                $(this).remove();
            });
            return false;
        });
        if (!preadded) {
            holder.removeChild(document.getElementById('annoninput'));
            addInput();
        }
        feed.hide();
    }
    
    var defaultFilter = function(input){
        if (filter.userfilter) {
            var flag;
            feed.children('li:not([fckb])').removeClass('hidden');
            $.each(feed.children('li:not([fckb])'), function(i, val){
                var item = $(val);
                if (filter.casesensetive) {
                    flag = item.text().indexOf(input);
                    item.html(item.text().replace(input, '<em>' + input + '</em>'));
                }
                else {
                    flag = item.text().toLowerCase().indexOf(input.toLowerCase());
                    item.html(item.text().replace(input, '<em>' + input + '</em>'));
                }
                if (flag == -1) {
                    item.addClass('hidden');
                }
                else {
                    counter++;
                }
            });
        }
        else {
            counter += feed.children('li:not([fckb])').length;
        }
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
        $.each(data, function(i, val){
            if (val.caption) {
                var li = document.createElement('li');
                $(li).attr({
                    'rel': val.value,
                    'fckb': '2'
                });
                if (feedFilter($(li), val.caption, input)) {
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
            $(li).attr({
                'rel': value,
                'fckb': '1'
            });
            $(li).html(value);
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
            $(this).addClass("auto-focus");
            nowFocusOn = $(this);
        });
		feed.children('li').mouseout( function(){
            $(this).removeClass("auto-focus");
            nowFocusOn = null;
        });
	}
    
    var bindEvents = function(){
        var maininput = $('.maininput');
       	bindFeedEvent();
        feed.children('li').unbind('click');
        feed.children('li').click(function(){
            addItem($(this));
            complete.hide();
        });
        maininput.unbind('keydown');
        maininput.keydown(function(event){
            if (event.keyCode == 13 && nowFocusOn != null) {
                addItem($(nowFocusOn));
                complete.hide();
                event.preventDefault();
            }
            if (event.keyCode == 40) {
				removeFeedEvent();
                if (typeof(nowFocusOn) == 'undefined' || nowFocusOn.length == 0) {
                    nowFocusOn = $(feed.children('li:visible:first'));
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
            if (event.keyCode == 38) {
				removeFeedEvent();
                if (typeof(nowFocusOn) == 'undefined' || nowFocusOn.length == 0) {
                    nowFocusOn = $(feed.children('li:visible:last'));
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
        $(li).attr({
            'class': 'bit-input',
            'id': 'annoninput'
        });
        $(input).attr({
            'type': 'text',
            'class': 'maininput'
        });
        li.appendChild(input);
        holder.appendChild(li);
        $(input).focus(function(){
            complete.fadeIn('fast');
        });
        $(holder).click(function(){
            $(input).focus();
			if (feed.length && $(input).val().length) {
				feed.show();
			}
			else {
				feed.children('li[fckb=2]').remove();
				feed.children('li').addClass('hidden');
				feed.css('height','0px');
				$('.default').show();
			}
        });
        $(input).keyup(function(event){
            if (event.keyCode != 40 && event.keyCode != 38) {
                counter = 0;
                var etext = $(input).val();
                addTextItemFeed(etext);
                if (ajax.url) {
                    if (ajax.cache && cache.length > 0) {
                        addItemFeed(cache, etext);
                        bindEvents();
                    }
                    else {
                        $.getJSON(ajax.url + '?tag=' + etext, null, function(data){
                            addItemFeed(data, etext);
                            cache = data;
                            bindEvents();
                        });
                    }
                }
                else {
                    bindEvents();
                }
                $('.default').hide();
                feed.show();
            }
        });
    }
    
    if (typeof(elem) != 'object') {
		elem = $(elem);
	}
    if (typeof(list) != 'object') {
		list = $(list);
	}
    if (typeof(complete) != 'object') {
		complete = $(complete);
	}
    var feed = $('#feed');
    var cache = {};
    var counter = 0;
	var nowFocusOn;
    var holder = document.createElement('ul');
    elem.css('display', 'none');
    $(holder).attr('class', 'holder');
    
    if (list && list.children('li').length) {
        $.each(list.children('li'), function(i, val){
            addItem($(list.children('li')[i]), 1);
        });
    }
	
    addInput();
    elem.before(holder);
	
	$(document).click(function (event) {
		if ($(event.target).attr('class') != 'holder' && $(event.target).attr('class') != 'maininput') {
			$('.default').hide();
			$(feed).hide();
		}
	});
}