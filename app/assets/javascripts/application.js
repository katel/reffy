// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-1.4.2.min
//= require jquery_ujs

//= require rails
//= require_tree .

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
$(function() {
	//these functions are taken nearly verbatim from the jquery-ui demos
		function split(val) {
			return val.split(/\s+/);
		}
		function extractLast(term) {
			return split(term).pop();
		}
		//this is the autocomplete for the enquiry field
		$("#autocomplete_enquiries").autocomplete({
			source: function(request, response) {
				$.getJSON("/enquiries/autocomplete", {
					term: extractLast(request.term)
				}, response);
			},

			minLength: 1,

			focus: function() {
				// prevent value inserted on focus
				return false;
			},

			select: function(event, ui) {
				var terms = split( this.value );
				// remove the current input
				terms.pop();
				// add the selected item
				terms.push( ui.item.value );
				// add placeholder to get the space at the end
				terms.push("");
				this.value = terms.join(" ");
				return false;
			}
		});

		//this is the datepicker for the advanced enquiry menu
		$("#enquiries_date").datepicker({
			dateFormat: "DD, MM d, yy"
		});

		//this is the toggle for the advanced menu
		$("#show_advanced_menu").click(function() {
			$("#advanced_menu").toggle("blind", 500);
		});

		//only hide the menu if javascript is enabled
		$("#advanced_menu").hide();

		//this loads more enquiries via js
		Page.makeMoreLink();
	});


var Page = {
	makeMoreLink: function() {
		$("a.more_button").click(function() {
			$.get(this.href, null, null, "script");
			$(this).parent().html("<div class='enquiries_loader'>Loading</div>");
			return false;
		});
	}
}