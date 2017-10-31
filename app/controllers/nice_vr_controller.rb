class  NiceVrController < ApplicationController



def creating_nice_user


   user = NiceUser.where(:email => params[:email].downcase).first

 
 	if user.nil?
     
       nice_user = NiceUser.new
       nice_user.name   = params[:name]
       nice_user.email   = params[:email].downcase
       nice_user.phone   = params[:phone]
       nice_user.fb_token   = params[:token]
       nice_user.platform = params[:platform]  

       if !params[:friends_list].nil?

       nice_user.friends_list   <<  params[:friends_list] 

       end 
       nice_user.url = params[:url]  
       nice_user.uid = params[:uid]  
       nice_user.avatar  = params[:avatar] 
       nice_user.version_code = params[:version_code]  
       nice_user.sdk_version = params[:sdk_version]  
       nice_user.device_id  = params[:device_id]
       nice_user.save!	 



             respond_to do |format|

              format.json{
               render :json =>{
                              :success => true,
                              :info => "New user has been created.",
                              :user => nice_user.as_json } }
              end 

	else 
          

				 respond_to do |format|

				              format.json{
				               render :json =>{
				                              :success => true,
				                              :info => "the user already exists",
				                              :user => nice_user.as_json } }
				 end 
	end 

end 


end 








