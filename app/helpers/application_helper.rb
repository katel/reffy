module ApplicationHelper
	
	def hours_for(subject)
  	minutes = Enquiry.tagged_with(subject).since(1.month.ago).sum(:duration_in_minutes)
  	return minutes_to_hours(minutes)
  	end
  	
  	def minutes_to_hours(minutes)
  		hours = minutes / 60
  		minutes = minutes %= 60
  		if minutes > 0
  		output = "<span class='time'>#{hours}<span class='h'>H</span>#{minutes}<span class='m'>M</span></span>"
  		elsif hours == 0
  			output = "-"
  		else
  		output = "<span class='time'>#{hours}<span class='h'>H</span></span>"
  		end
  		return output.html_safe
  	end
	
	def six_month_patron_type_chart(patron)
		require 'google_chart'
		enquiries = Enquiry.tagged_with(patron, :as => :patron)
		GoogleChart::LineChart.new('550x200', "", false) do |lc|
		  enquiries.tag_counts_on(:types).each do |a|
	      	lc.data a, six_months_of_type_for_patron(a, patron), random_color
      	  end
	      lc.show_legend = true
	      #lc.axis :y, :range => [0, 300], :color => '202020', :font_size => 16, :alignment => :center #can't get this to work, deactivate for now
	      lc.axis :x, :range => [0, 6], :labels => last_six_month_names, :color => '202020', :font_size => 16, :alignment => :center
	      lc.grid :x_step => 20, :y_step => 10
	      return lc.to_url
	    end
	end
	
	def six_months_of_type_for_patron(type, patron)
		a = Array.new
		(0..5).each do |n|
			number = Enquiry.months_ago(n).tagged_with(patron, :as => :patron).tagged_with(type, :as => :type).sum(:duration_in_minutes)
			number = number / 60 #convert it to hours
			a << number
		end
		return a.reverse
	end
	
	def last_six_month_names
		a = Array.new
		(0..5).each do |n|
			a << n.month.ago.strftime("%b")
		end
		return a.reverse
	end
	
	#this is the highlight function for enquiries, making sure types, subjects and patrons are highlighted
	def highlight(enquiry)
		b = enquiry.body.dup
		b.gsub!(enquiry.subject_reg) {|s| "<a href='#{reporting_enquiries_path(:subject => s.gsub("\#", ''))}' class='important subject'>" + s + '</a>'}
		#need to use act instead of type to avoid messing up rails
		b.gsub!(enquiry.type_reg) {|s| "<a href='#{reporting_enquiries_path(:act => s.gsub("*", ""))}' class='important type'>" + s + '</a>'}
		b.gsub!(enquiry.patron_reg) {|s| "<a href='#{reporting_enquiries_path(:patron => s.gsub("@", ""))}' class='important patron'>" + s + '</a>'}
		b
	end
	
	def reporting_path(type, subject, patron)
		reporting_enquiries_path(:act => type, :subject => subject, :patron => patron)
	end
	
	#need to generate a random color for the graphs, this could be better like specific colors for specific types across the board, but this will do for now
	def random_color
		"%06x" % (rand * 0xffffff)
	end
	
end
