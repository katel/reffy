class ProfilesController < ApplicationController
  

    
  def show
        @user = User.first(conditions: { name: request.subdomain }) || not_found
        @enquiries = Enquiry.all
        
  end
  
  def not_found
      raise ActionController::RoutingError.new('User Not Found')
    end




 
end
