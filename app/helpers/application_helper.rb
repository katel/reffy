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
	
	def six_month_client_action_chart(client)
		require 'google_chart'
		enquiries = Enquiry.tagged_with(client, :as => :client)
		GoogleChart::LineChart.new('550x200', "", false) do |lc|
		  enquiries.tag_counts_on(:actions).each do |a|
	      	lc.data a, six_months_of_action_for_client(a, client), random_color
      	  end
	      lc.show_legend = true
	      #lc.axis :y, :range => [0, 300], :color => '202020', :font_size => 16, :alignment => :center #can't get this to work, deactivate for now
	      lc.axis :x, :range => [0, 6], :labels => last_six_month_names, :color => '202020', :font_size => 16, :alignment => :center
	      lc.grid :x_step => 20, :y_step => 10
	      return lc.to_url
	    end
	end
	
	def six_months_of_action_for_client(action, client)
		a = Array.new
		(0..5).each do |n|
			number = Enquiry.months_ago(n).tagged_with(client, :as => :client).tagged_with(action, :as => :action).sum(:duration_in_minutes)
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
	
	#this is the highlight function for enquiries, making sure actions, subjects and clients are highlighted
	def highlight(enquiry)
		b = enquiry.body.dup
		b.gsub!(enquiry.subject_reg) {|s| "<a href='#{reporting_enquiries_path(:subject => s.gsub("\#", ''))}' class='important subject'>" + s + '</a>'}
		#need to use act instead of action to avoid messing up rails
		b.gsub!(enquiry.action_reg) {|s| "<a href='#{reporting_enquiries_path(:act => s.gsub("*", ""))}' class='important action'>" + s + '</a>'}
		b.gsub!(enquiry.client_reg) {|s| "<a href='#{reporting_enquiries_path(:client => s.gsub("@", ""))}' class='important client'>" + s + '</a>'}
		b
	end
	
	def reporting_path(action, subject, client)
		reporting_enquiries_path(:act => action, :subject => subject, :client => client)
	end
	
	#need to generate a random color for the graphs, this could be better like specific colors for specific actions across the board, but this will do for now
	def random_color
		"%06x" % (rand * 0xffffff)
	end
	
end
