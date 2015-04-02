(function(){var e;e=function(){function e(t,s){this.form_field=t,this.options=null!=s?s:{},e.browser_is_supported()&&(this.is_multiple=this.form_field.multiple,this.set_default_text(),this.set_default_values(),this.setup(),this.set_up_html(),this.register_observers())}return e.prototype.set_default_values=function(){return this.click_test_action=function(e){return function(t){return e.test_active_click(t)}}(this),this.activate_action=function(e){return function(t){return e.activate_field(t)}}(this),this.active_field=!1,this.mouse_on_container=!1,this.results_showing=!1,this.result_highlighted=null,this.allow_single_deselect=null!=this.options.allow_single_deselect&&null!=this.form_field.options[0]&&""===this.form_field.options[0].text?this.options.allow_single_deselect:!1,this.disable_search_threshold=this.options.disable_search_threshold||0,this.disable_search=this.options.disable_search||!1,this.enable_split_word_search=null!=this.options.enable_split_word_search?this.options.enable_split_word_search:!0,this.group_search=null!=this.options.group_search?this.options.group_search:!0,this.search_contains=this.options.search_contains||!1,this.single_backstroke_delete=null!=this.options.single_backstroke_delete?this.options.single_backstroke_delete:!0,this.max_selected_options=this.options.max_selected_options||1/0,this.inherit_select_classes=this.options.inherit_select_classes||!1,this.display_selected_options=null!=this.options.display_selected_options?this.options.display_selected_options:!0,this.display_disabled_options=null!=this.options.display_disabled_options?this.options.display_disabled_options:!0},e.prototype.set_default_text=function(){return this.default_text=this.form_field.getAttribute("data-placeholder")?this.form_field.getAttribute("data-placeholder"):this.is_multiple?this.options.placeholder_text_multiple||this.options.placeholder_text||e.default_multiple_text:this.options.placeholder_text_single||this.options.placeholder_text||e.default_single_text,this.results_none_found=this.form_field.getAttribute("data-no_results_text")||this.options.no_results_text||e.default_no_result_text},e.prototype.mouse_enter=function(){return this.mouse_on_container=!0},e.prototype.mouse_leave=function(){return this.mouse_on_container=!1},e.prototype.input_focus=function(){if(this.is_multiple){if(!this.active_field)return setTimeout(function(e){return function(){return e.container_mousedown()}}(this),50)}else if(!this.active_field)return this.activate_field()},e.prototype.input_blur=function(){return this.mouse_on_container?void 0:(this.active_field=!1,setTimeout(function(e){return function(){return e.blur_test()}}(this),100))},e.prototype.results_option_build=function(e){var t,s,i,r,o;for(t="",o=this.results_data,i=0,r=o.length;r>i;i++)s=o[i],t+=s.group?this.result_add_group(s):this.result_add_option(s),(null!=e?e.first:void 0)&&(s.selected&&this.is_multiple?this.choice_build(s):s.selected&&!this.is_multiple&&this.single_set_selected_text(s.text));return t},e.prototype.result_add_option=function(e){var t,s;return e.search_match&&this.include_option_in_results(e)?(t=[],e.disabled||e.selected&&this.is_multiple||t.push("active-result"),!e.disabled||e.selected&&this.is_multiple||t.push("disabled-result"),e.selected&&t.push("result-selected"),null!=e.group_array_index&&t.push("group-option"),""!==e.classes&&t.push(e.classes),s=document.createElement("li"),s.className=t.join(" "),s.style.cssText=e.style,s.setAttribute("data-option-array-index",e.array_index),s.innerHTML=e.search_text,this.outerHTML(s)):""},e.prototype.result_add_group=function(e){var t;return(e.search_match||e.group_match)&&e.active_options>0?(t=document.createElement("li"),t.className="group-result",t.innerHTML=e.search_text,this.outerHTML(t)):""},e.prototype.results_update_field=function(){return this.set_default_text(),this.is_multiple||this.results_reset_cleanup(),this.result_clear_highlight(),this.results_build(),this.results_showing?this.winnow_results():void 0},e.prototype.reset_single_select_options=function(){var e,t,s,i,r;for(i=this.results_data,r=[],t=0,s=i.length;s>t;t++)e=i[t],r.push(e.selected?e.selected=!1:void 0);return r},e.prototype.results_toggle=function(){return this.results_showing?this.results_hide():this.results_show()},e.prototype.results_search=function(){return this.results_showing?this.winnow_results():this.results_show()},e.prototype.winnow_results=function(){var e,t,s,i,r,o,n,l,h,c,a,u,_;for(this.no_results_clear(),r=0,n=this.get_search_text(),e=n.replace(/[-[\]{}()*+?.,\\^$|#\s]/g,"\\$&"),i=this.search_contains?"":"^",s=new RegExp(i+e,"i"),c=new RegExp(e,"i"),_=this.results_data,a=0,u=_.length;u>a;a++)t=_[a],t.search_match=!1,o=null,this.include_option_in_results(t)&&(t.group&&(t.group_match=!1,t.active_options=0),null!=t.group_array_index&&this.results_data[t.group_array_index]&&(o=this.results_data[t.group_array_index],0===o.active_options&&o.search_match&&(r+=1),o.active_options+=1),(!t.group||this.group_search)&&(t.search_text=t.group?t.label:t.html,t.search_match=this.search_string_match(t.search_text,s),t.search_match&&!t.group&&(r+=1),t.search_match?(n.length&&(l=t.search_text.search(c),h=t.search_text.substr(0,l+n.length)+"</em>"+t.search_text.substr(l+n.length),t.search_text=h.substr(0,l)+"<em>"+h.substr(l)),null!=o&&(o.group_match=!0)):null!=t.group_array_index&&this.results_data[t.group_array_index].search_match&&(t.search_match=!0)));return this.result_clear_highlight(),1>r&&n.length?(this.update_results_content(""),this.no_results(n)):(this.update_results_content(this.results_option_build()),this.winnow_results_set_highlight())},e.prototype.search_string_match=function(e,t){var s,i,r,o;if(t.test(e))return!0;if(this.enable_split_word_search&&(e.indexOf(" ")>=0||0===e.indexOf("["))&&(i=e.replace(/\[|\]/g,"").split(" "),i.length))for(r=0,o=i.length;o>r;r++)if(s=i[r],t.test(s))return!0},e.prototype.choices_count=function(){var e,t,s,i;if(null!=this.selected_option_count)return this.selected_option_count;for(this.selected_option_count=0,i=this.form_field.options,t=0,s=i.length;s>t;t++)e=i[t],e.selected&&(this.selected_option_count+=1);return this.selected_option_count},e.prototype.choices_click=function(e){return e.preventDefault(),this.results_showing||this.is_disabled?void 0:this.results_show()},e.prototype.keyup_checker=function(e){var t,s;switch(t=null!=(s=e.which)?s:e.keyCode,this.search_field_scale(),t){case 8:if(this.is_multiple&&this.backstroke_length<1&&this.choices_count()>0)return this.keydown_backstroke();if(!this.pending_backstroke)return this.result_clear_highlight(),this.results_search();break;case 13:if(e.preventDefault(),this.results_showing)return this.result_select(e);break;case 27:return this.results_showing&&this.results_hide(),!0;case 9:case 38:case 40:case 16:case 91:case 17:break;default:return this.results_search()}},e.prototype.clipboard_event_checker=function(){return setTimeout(function(e){return function(){return e.results_search()}}(this),50)},e.prototype.container_width=function(){return null!=this.options.width?this.options.width:""+this.form_field.offsetWidth+"px"},e.prototype.include_option_in_results=function(e){return this.is_multiple&&!this.display_selected_options&&e.selected?!1:!this.display_disabled_options&&e.disabled?!1:e.empty?!1:!0},e.prototype.search_results_touchstart=function(e){return this.touch_started=!0,this.search_results_mouseover(e)},e.prototype.search_results_touchmove=function(e){return this.touch_started=!1,this.search_results_mouseout(e)},e.prototype.search_results_touchend=function(e){return this.touch_started?this.search_results_mouseup(e):void 0},e.prototype.outerHTML=function(e){var t;return e.outerHTML?e.outerHTML:(t=document.createElement("div"),t.appendChild(e),t.innerHTML)},e.browser_is_supported=function(){return"Microsoft Internet Explorer"===window.navigator.appName?document.documentMode>=8:/iP(od|hone)/i.test(window.navigator.userAgent)?!1:/Android/i.test(window.navigator.userAgent)&&/Mobile/i.test(window.navigator.userAgent)?!1:!0},e.default_multiple_text="Select Some Options",e.default_single_text="Select an Option",e.default_no_result_text="No results match",e}(),window.AbstractChosen=e}).call(this),function(){var e;e=function(){function e(){this.options_index=0,this.parsed=[]}return e.prototype.add_node=function(e){return"OPTGROUP"===e.nodeName.toUpperCase()?this.add_group(e):this.add_option(e)},e.prototype.add_group=function(e){var t,s,i,r,o,n;for(t=this.parsed.length,this.parsed.push({array_index:t,group:!0,label:this.escapeExpression(e.label),children:0,disabled:e.disabled}),o=e.childNodes,n=[],i=0,r=o.length;r>i;i++)s=o[i],n.push(this.add_option(s,t,e.disabled));return n},e.prototype.add_option=function(e,t,s){return"OPTION"===e.nodeName.toUpperCase()?(""!==e.text?(null!=t&&(this.parsed[t].children+=1),this.parsed.push({array_index:this.parsed.length,options_index:this.options_index,value:e.value,text:e.text,html:e.innerHTML,selected:e.selected,disabled:s===!0?s:e.disabled,group_array_index:t,classes:e.className,style:e.style.cssText})):this.parsed.push({array_index:this.parsed.length,options_index:this.options_index,empty:!0}),this.options_index+=1):void 0},e.prototype.escapeExpression=function(e){var t,s;return null==e||e===!1?"":/[\&\<\>\"\'\`]/.test(e)?(t={"<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#x27;","`":"&#x60;"},s=/&(?!\w+;)|[\<\>\"\'\`]/g,e.replace(s,function(e){return t[e]||"&amp;"})):e},e}(),e.select_to_array=function(t){var s,i,r,o,n;for(i=new e,n=t.childNodes,r=0,o=n.length;o>r;r++)s=n[r],i.add_node(s);return i.parsed},window.SelectParser=e}.call(this),function(){var e={}.hasOwnProperty,t=function(t,s){function i(){this.constructor=t}for(var r in s)e.call(s,r)&&(t[r]=s[r]);return i.prototype=s.prototype,t.prototype=new i,t.__super__=s.prototype,t};this.Chosen=function(e){function s(){return s.__super__.constructor.apply(this,arguments)}return t(s,e),s.prototype.setup=function(){return this.current_selectedIndex=this.form_field.selectedIndex,this.is_rtl=this.form_field.hasClassName("chosen-rtl")},s.prototype.set_default_values=function(){return s.__super__.set_default_values.call(this),this.single_temp=new Template('<a class="chosen-single chosen-default" tabindex="-1"><span>#{default}</span><div><b></b></div></a><div class="chosen-drop"><div class="chosen-search"><input type="text" autocomplete="off" /></div><ul class="chosen-results"></ul></div>'),this.multi_temp=new Template('<ul class="chosen-choices"><li class="search-field"><input type="text" value="#{default}" class="default" autocomplete="off" style="width:25px;" /></li></ul><div class="chosen-drop"><ul class="chosen-results"></ul></div>'),this.no_results_temp=new Template('<li class="no-results">'+this.results_none_found+' "<span>#{terms}</span>"</li>')},s.prototype.set_up_html=function(){var e,t;return e=["chosen-container"],e.push("chosen-container-"+(this.is_multiple?"multi":"single")),this.inherit_select_classes&&this.form_field.className&&e.push(this.form_field.className),this.is_rtl&&e.push("chosen-rtl"),t={"class":e.join(" "),style:"width: "+this.container_width()+";",title:this.form_field.title},this.form_field.id.length&&(t.id=this.form_field.id.replace(/[^\w]/g,"_")+"_chosen"),this.container=new Element("div",t).update(this.is_multiple?this.multi_temp.evaluate({"default":this.default_text}):this.single_temp.evaluate({"default":this.default_text})),this.form_field.hide().insert({after:this.container}),this.dropdown=this.container.down("div.chosen-drop"),this.search_field=this.container.down("input"),this.search_results=this.container.down("ul.chosen-results"),this.search_field_scale(),this.search_no_results=this.container.down("li.no-results"),this.is_multiple?(this.search_choices=this.container.down("ul.chosen-choices"),this.search_container=this.container.down("li.search-field")):(this.search_container=this.container.down("div.chosen-search"),this.selected_item=this.container.down(".chosen-single")),this.results_build(),this.set_tab_index(),this.set_label_behavior(),this.form_field.fire("chosen:ready",{chosen:this})},s.prototype.register_observers=function(){return this.container.observe("mousedown",function(e){return function(t){return e.container_mousedown(t)}}(this)),this.container.observe("mouseup",function(e){return function(t){return e.container_mouseup(t)}}(this)),this.container.observe("mouseenter",function(e){return function(t){return e.mouse_enter(t)}}(this)),this.container.observe("mouseleave",function(e){return function(t){return e.mouse_leave(t)}}(this)),this.search_results.observe("mouseup",function(e){return function(t){return e.search_results_mouseup(t)}}(this)),this.search_results.observe("mouseover",function(e){return function(t){return e.search_results_mouseover(t)}}(this)),this.search_results.observe("mouseout",function(e){return function(t){return e.search_results_mouseout(t)}}(this)),this.search_results.observe("mousewheel",function(e){return function(t){return e.search_results_mousewheel(t)}}(this)),this.search_results.observe("DOMMouseScroll",function(e){return function(t){return e.search_results_mousewheel(t)}}(this)),this.search_results.observe("touchstart",function(e){return function(t){return e.search_results_touchstart(t)}}(this)),this.search_results.observe("touchmove",function(e){return function(t){return e.search_results_touchmove(t)}}(this)),this.search_results.observe("touchend",function(e){return function(t){return e.search_results_touchend(t)}}(this)),this.form_field.observe("chosen:updated",function(e){return function(t){return e.results_update_field(t)}}(this)),this.form_field.observe("chosen:activate",function(e){return function(t){return e.activate_field(t)}}(this)),this.form_field.observe("chosen:open",function(e){return function(t){return e.container_mousedown(t)}}(this)),this.form_field.observe("chosen:close",function(e){return function(t){return e.input_blur(t)}}(this)),this.search_field.observe("blur",function(e){return function(t){return e.input_blur(t)}}(this)),this.search_field.observe("keyup",function(e){return function(t){return e.keyup_checker(t)}}(this)),this.search_field.observe("keydown",function(e){return function(t){return e.keydown_checker(t)}}(this)),this.search_field.observe("focus",function(e){return function(t){return e.input_focus(t)}}(this)),this.search_field.observe("cut",function(e){return function(t){return e.clipboard_event_checker(t)}}(this)),this.search_field.observe("paste",function(e){return function(t){return e.clipboard_event_checker(t)}}(this)),this.is_multiple?this.search_choices.observe("click",function(e){return function(t){return e.choices_click(t)}}(this)):this.container.observe("click",function(){return function(e){return e.preventDefault()}}(this))},s.prototype.destroy=function(){return this.container.ownerDocument.stopObserving("click",this.click_test_action),this.form_field.stopObserving(),this.container.stopObserving(),this.search_results.stopObserving(),this.search_field.stopObserving(),null!=this.form_field_label&&this.form_field_label.stopObserving(),this.is_multiple?(this.search_choices.stopObserving(),this.container.select(".search-choice-close").each(function(e){return e.stopObserving()})):this.selected_item.stopObserving(),this.search_field.tabIndex&&(this.form_field.tabIndex=this.search_field.tabIndex),this.container.remove(),this.form_field.show()},s.prototype.search_field_disabled=function(){return this.is_disabled=this.form_field.disabled,this.is_disabled?(this.container.addClassName("chosen-disabled"),this.search_field.disabled=!0,this.is_multiple||this.selected_item.stopObserving("focus",this.activate_action),this.close_field()):(this.container.removeClassName("chosen-disabled"),this.search_field.disabled=!1,this.is_multiple?void 0:this.selected_item.observe("focus",this.activate_action))},s.prototype.container_mousedown=function(e){return this.is_disabled||(e&&"mousedown"===e.type&&!this.results_showing&&e.stop(),null!=e&&e.target.hasClassName("search-choice-close"))?void 0:(this.active_field?this.is_multiple||!e||e.target!==this.selected_item&&!e.target.up("a.chosen-single")||this.results_toggle():(this.is_multiple&&this.search_field.clear(),this.container.ownerDocument.observe("click",this.click_test_action),this.results_show()),this.activate_field())},s.prototype.container_mouseup=function(e){return"ABBR"!==e.target.nodeName||this.is_disabled?void 0:this.results_reset(e)},s.prototype.search_results_mousewheel=function(e){var t;return t=-e.wheelDelta||e.detail,null!=t?(e.preventDefault(),"DOMMouseScroll"===e.type&&(t=40*t),this.search_results.scrollTop=t+this.search_results.scrollTop):void 0},s.prototype.blur_test=function(){return!this.active_field&&this.container.hasClassName("chosen-container-active")?this.close_field():void 0},s.prototype.close_field=function(){return this.container.ownerDocument.stopObserving("click",this.click_test_action),this.active_field=!1,this.results_hide(),this.container.removeClassName("chosen-container-active"),this.clear_backstroke(),this.show_search_field_default(),this.search_field_scale()},s.prototype.activate_field=function(){return this.container.addClassName("chosen-container-active"),this.active_field=!0,this.search_field.value=this.search_field.value,this.search_field.focus()},s.prototype.test_active_click=function(e){return e.target.up(".chosen-container")===this.container?this.active_field=!0:this.close_field()},s.prototype.results_build=function(){return this.parsing=!0,this.selected_option_count=null,this.results_data=SelectParser.select_to_array(this.form_field),this.is_multiple?this.search_choices.select("li.search-choice").invoke("remove"):this.is_multiple||(this.single_set_selected_text(),this.disable_search||this.form_field.options.length<=this.disable_search_threshold?(this.search_field.readOnly=!0,this.container.addClassName("chosen-container-single-nosearch")):(this.search_field.readOnly=!1,this.container.removeClassName("chosen-container-single-nosearch"))),this.update_results_content(this.results_option_build({first:!0})),this.search_field_disabled(),this.show_search_field_default(),this.search_field_scale(),this.parsing=!1},s.prototype.result_do_highlight=function(e){var t,s,i,r,o;return this.result_clear_highlight(),this.result_highlight=e,this.result_highlight.addClassName("highlighted"),i=parseInt(this.search_results.getStyle("maxHeight"),10),o=this.search_results.scrollTop,r=i+o,s=this.result_highlight.positionedOffset().top,t=s+this.result_highlight.getHeight(),t>=r?this.search_results.scrollTop=t-i>0?t-i:0:o>s?this.search_results.scrollTop=s:void 0},s.prototype.result_clear_highlight=function(){return this.result_highlight&&this.result_highlight.removeClassName("highlighted"),this.result_highlight=null},s.prototype.results_show=function(){return this.is_multiple&&this.max_selected_options<=this.choices_count()?(this.form_field.fire("chosen:maxselected",{chosen:this}),!1):(this.container.addClassName("chosen-with-drop"),this.results_showing=!0,this.search_field.focus(),this.search_field.value=this.search_field.value,this.winnow_results(),this.form_field.fire("chosen:showing_dropdown",{chosen:this}))},s.prototype.update_results_content=function(e){return this.search_results.update(e)},s.prototype.results_hide=function(){return this.results_showing&&(this.result_clear_highlight(),this.container.removeClassName("chosen-with-drop"),this.form_field.fire("chosen:hiding_dropdown",{chosen:this})),this.results_showing=!1},s.prototype.set_tab_index=function(){var e;return this.form_field.tabIndex?(e=this.form_field.tabIndex,this.form_field.tabIndex=-1,this.search_field.tabIndex=e):void 0},s.prototype.set_label_behavior=function(){return this.form_field_label=this.form_field.up("label"),null==this.form_field_label&&(this.form_field_label=$$("label[for='"+this.form_field.id+"']").first()),null!=this.form_field_label?this.form_field_label.observe("click",function(e){return function(t){return e.is_multiple?e.container_mousedown(t):e.activate_field()}}(this)):void 0},s.prototype.show_search_field_default=function(){return this.is_multiple&&this.choices_count()<1&&!this.active_field?(this.search_field.value=this.default_text,this.search_field.addClassName("default")):(this.search_field.value="",this.search_field.removeClassName("default"))},s.prototype.search_results_mouseup=function(e){var t;return t=e.target.hasClassName("active-result")?e.target:e.target.up(".active-result"),t?(this.result_highlight=t,this.result_select(e),this.search_field.focus()):void 0},s.prototype.search_results_mouseover=function(e){var t;return t=e.target.hasClassName("active-result")?e.target:e.target.up(".active-result"),t?this.result_do_highlight(t):void 0},s.prototype.search_results_mouseout=function(e){return e.target.hasClassName("active-result")||e.target.up(".active-result")?this.result_clear_highlight():void 0},s.prototype.choice_build=function(e){var t,s;return t=new Element("li",{"class":"search-choice"}).update("<span>"+e.html+"</span>"),e.disabled?t.addClassName("search-choice-disabled"):(s=new Element("a",{href:"#","class":"search-choice-close",rel:e.array_index}),s.observe("click",function(e){return function(t){return e.choice_destroy_link_click(t)}}(this)),t.insert(s)),this.search_container.insert({before:t})},s.prototype.choice_destroy_link_click=function(e){return e.preventDefault(),e.stopPropagation(),this.is_disabled?void 0:this.choice_destroy(e.target)},s.prototype.choice_destroy=function(e){return this.result_deselect(e.readAttribute("rel"))?(this.show_search_field_default(),this.is_multiple&&this.choices_count()>0&&this.search_field.value.length<1&&this.results_hide(),e.up("li").remove(),this.search_field_scale()):void 0},s.prototype.results_reset=function(){return this.reset_single_select_options(),this.form_field.options[0].selected=!0,this.single_set_selected_text(),this.show_search_field_default(),this.results_reset_cleanup(),"function"==typeof Event.simulate&&this.form_field.simulate("change"),this.active_field?this.results_hide():void 0},s.prototype.results_reset_cleanup=function(){var e;return this.current_selectedIndex=this.form_field.selectedIndex,e=this.selected_item.down("abbr"),e?e.remove():void 0},s.prototype.result_select=function(e){var t,s;return this.result_highlight?(t=this.result_highlight,this.result_clear_highlight(),this.is_multiple&&this.max_selected_options<=this.choices_count()?(this.form_field.fire("chosen:maxselected",{chosen:this}),!1):(this.is_multiple?t.removeClassName("active-result"):this.reset_single_select_options(),t.addClassName("result-selected"),s=this.results_data[t.getAttribute("data-option-array-index")],s.selected=!0,this.form_field.options[s.options_index].selected=!0,this.selected_option_count=null,this.is_multiple?this.choice_build(s):this.single_set_selected_text(s.text),(e.metaKey||e.ctrlKey)&&this.is_multiple||this.results_hide(),this.search_field.value="","function"!=typeof Event.simulate||!this.is_multiple&&this.form_field.selectedIndex===this.current_selectedIndex||this.form_field.simulate("change"),this.current_selectedIndex=this.form_field.selectedIndex,this.search_field_scale())):void 0},s.prototype.single_set_selected_text=function(e){return null==e&&(e=this.default_text),e===this.default_text?this.selected_item.addClassName("chosen-default"):(this.single_deselect_control_build(),this.selected_item.removeClassName("chosen-default")),this.selected_item.down("span").update(e)},s.prototype.result_deselect=function(e){var t;return t=this.results_data[e],this.form_field.options[t.options_index].disabled?!1:(t.selected=!1,this.form_field.options[t.options_index].selected=!1,this.selected_option_count=null,this.result_clear_highlight(),this.results_showing&&this.winnow_results(),"function"==typeof Event.simulate&&this.form_field.simulate("change"),this.search_field_scale(),!0)},s.prototype.single_deselect_control_build=function(){return this.allow_single_deselect?(this.selected_item.down("abbr")||this.selected_item.down("span").insert({after:'<abbr class="search-choice-close"></abbr>'}),this.selected_item.addClassName("chosen-single-with-deselect")):void 0},s.prototype.get_search_text=function(){return this.search_field.value===this.default_text?"":this.search_field.value.strip().escapeHTML()},s.prototype.winnow_results_set_highlight=function(){var e;return this.is_multiple||(e=this.search_results.down(".result-selected.active-result")),null==e&&(e=this.search_results.down(".active-result")),null!=e?this.result_do_highlight(e):void 0},s.prototype.no_results=function(e){return this.search_results.insert(this.no_results_temp.evaluate({terms:e})),this.form_field.fire("chosen:no_results",{chosen:this})},s.prototype.no_results_clear=function(){var e,t;for(e=null,t=[];e=this.search_results.down(".no-results");)t.push(e.remove());return t},s.prototype.keydown_arrow=function(){var e;return this.results_showing&&this.result_highlight?(e=this.result_highlight.next(".active-result"))?this.result_do_highlight(e):void 0:this.results_show()},s.prototype.keyup_arrow=function(){var e,t,s;return this.results_showing||this.is_multiple?this.result_highlight?(s=this.result_highlight.previousSiblings(),e=this.search_results.select("li.active-result"),t=s.intersect(e),t.length?this.result_do_highlight(t.first()):(this.choices_count()>0&&this.results_hide(),this.result_clear_highlight())):void 0:this.results_show()},s.prototype.keydown_backstroke=function(){var e;return this.pending_backstroke?(this.choice_destroy(this.pending_backstroke.down("a")),this.clear_backstroke()):(e=this.search_container.siblings().last(),e&&e.hasClassName("search-choice")&&!e.hasClassName("search-choice-disabled")?(this.pending_backstroke=e,this.pending_backstroke&&this.pending_backstroke.addClassName("search-choice-focus"),this.single_backstroke_delete?this.keydown_backstroke():this.pending_backstroke.addClassName("search-choice-focus")):void 0)},s.prototype.clear_backstroke=function(){return this.pending_backstroke&&this.pending_backstroke.removeClassName("search-choice-focus"),this.pending_backstroke=null},s.prototype.keydown_checker=function(e){var t,s;switch(t=null!=(s=e.which)?s:e.keyCode,this.search_field_scale(),8!==t&&this.pending_backstroke&&this.clear_backstroke(),t){case 8:this.backstroke_length=this.search_field.value.length;break;case 9:this.results_showing&&!this.is_multiple&&this.result_select(e),this.mouse_on_container=!1;break;case 13:e.preventDefault();break;case 38:e.preventDefault(),this.keyup_arrow();break;case 40:e.preventDefault(),this.keydown_arrow()}},s.prototype.search_field_scale=function(){var e,t,s,i,r,o,n,l,h;if(this.is_multiple){for(s=0,n=0,r="position:absolute; left: -1000px; top: -1000px; display:none;",o=["font-size","font-style","font-weight","font-family","line-height","text-transform","letter-spacing"],l=0,h=o.length;h>l;l++)i=o[l],r+=i+":"+this.search_field.getStyle(i)+";";return e=new Element("div",{style:r}).update(this.search_field.value.escapeHTML()),document.body.appendChild(e),n=Element.measure(e,"width")+25,e.remove(),t=this.container.getWidth(),n>t-10&&(n=t-10),this.search_field.setStyle({width:n+"px"})}},s}(AbstractChosen)}.call(this);