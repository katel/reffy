class Reporting::EnquiriesController < ApplicationController
	
###############################################
# Enquiryy
# Please submit bug reports/suggestions via the github repo http://github.com/mazondo/Enquiryy
# 
# Copyright (c) 2010 Ryan Quinn
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################ 

  # GET /enquiries
  # GET /enquiries.xml
  def index
  	@reporting = true
    @enquiries = Enquiry
    if params[:from]
    	@enquiries = @enquiries.where("created_at > ?", params[:from])
	end
	if params[:to]
		@enquiries2 = @enquiries.where("created_at < ?", params[:to])
	end
    if params[:act]
    	@enquiries = @enquiries.tagged_with(params[:act], :as => :action)
	end
	if params[:client]
		@enquiries = @enquiries.tagged_with(params[:client], :as => :client)
	end
	if params[:subject]
		@enquiries = @enquiries.tagged_with(params[:subject], :as => :subject)
	end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @enquiries }
    end
  end

  # GET /enquiries/1
  # GET /enquiries/1.xml
  def show
    @enquiry = Enquiry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enquiry }
    end
  end

  # GET /enquiries/new
  # GET /enquiries/new.xml
  def new
    @enquiry = Enquiry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @enquiry }
    end
  end

  # GET /enquiries/1/edit
  def edit
    @enquiry = Enquiry.find(params[:id])
  end

  # POST /enquiries
  # POST /enquiries.xml
  def create
    @enquiry = Enquiry.new(params[:enquiry])

    respond_to do |format|
      if @enquiry.parse_and_save
        format.html { redirect_to(enquiries_path, :notice => 'Enquiry was successfully created.') }
        format.xml  { render :xml => @enquiry, :status => :created, :location => @enquiry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /enquiries/1
  # PUT /enquiries/1.xml
  def update
    @enquiry = Enquiry.find(params[:id])
    @enquiry.attributes = params[:enquiry]

    respond_to do |format|
      if @enquiry.parse_and_save
        format.html { redirect_to(enquiries_path, :notice => 'Enquiry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /enquiries/1
  # DELETE /enquiries/1.xml
  def destroy
    @enquiry = Enquiry.find(params[:id])
    @enquiry.destroy

    respond_to do |format|
      format.html { redirect_to(enquiries_url) }
      format.xml  { head :ok }
    end
  end
  
  #this is the json function for the autocomplete
  def autocomplete
  	@tags = nil
  	unless params[:term].blank?
  		case params[:term].first
		when "\#"
			term = params[:term].gsub("\#", "")
			@tags = Enquiry.subject_counts.where("tags.name like ?", "%#{term}%").collect! {|p| "\#" + p.name}
		when "@"
			term = params[:term].gsub("@", "")
			@tags = Enquiry.client_counts.where("tags.name like ?", "%#{term}%").collect! {|c| "@" + c.name}
		when "*"
			term = params[:term].gsub("*", "")
			@tags = Enquiry.action_counts.where("tags.name like ?", "%#{term}%").collect! {|a| "*" + a.name}
		else
			term = params[:term]
	  	@tags = Enquiry.subject_counts.where("tags.name like ?", "%#{term}%").collect! {|p| "\#" + p.name}
	  	@tags << Enquiry.action_counts.where("tags.name like ?", "%#{term}%").collect! {|a| "*" + a.name}
	  	@tags << Enquiry.client_counts.where("tags.name like ?", "%#{term}%").collect! {|c| "@" + c.name}
  		end
  		@tags.flatten!
  	end
  	respond_to do |format|
  		format.js { render :json => @tags}
  	end
  end
end
