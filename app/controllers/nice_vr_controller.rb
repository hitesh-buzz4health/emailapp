class  NiceVrController < ApplicationController



def creating_nice_user


   user = NiceUser.find(:email => params[:email]).first
 
 	if user.nil?
     
       nice_user = NiceUser.new
       nice_user.name   = params[:name]
       nice_user.email   = params[:email]
       nice_user.phone   = params[:phone]
       nice_user.token   = params[:token]
       nice_user.platform = params[:platform]  
       nice_user.friends_list   << params 
       nice_user.token   = params[:token]
       nice_user.url = params[:url]  
       nice_user.uid = params[:uid]  
       nice_user.avatar  = params[:avatar] 
       nice_user.version_code = params[:version_code]  
       nice_user.sdk_version = params[:sdk_version]  
       nice_user.device_id  = params[:device_id]
       nice_user.save!	 


	else 


	end 

end 


end 








