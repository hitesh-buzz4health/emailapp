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

       nice_user.friends_list   =  params[:friends_list] 

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
                              :speaker_note => "rEwhKziHpuM",
                              :user => nice_user.as_json } }
              end 

	else 
          

				 respond_to do |format|

				              format.json{
				               render :json =>{
				                              :success => true,
				                              :info => "the user already exists",
                                      :speaker_note => "rEwhKziHpuM",

				                              :user => user.as_json } }
				 end 
	end 
 
end









def reaching_out

user  = NiceUser.find(params[:id])
send_results(user.name , user.email, params[:message])

        respond_to do |format|

                      format.json{
                       render :json =>{
                                      :success => true,
                                      :info => "reach out is success"
                                       } }
         end 

end 


def send_results(name , mail_id , message )
        gmail = Gmail.connect("drdeepikakapoor@buzz4health.com","whitebutter")
  email = gmail.compose do
          to  ['sheerin@buzz4health.com' ,'hitesh.ganjoo@buzz4health.com' , 'sonal@buzz4health.com'  ]
          from  "Reach out Nice Vr  "
            subject  "Reach Out Nice Vr"
            body    "Stats for the mail Campaign send on #{Time.now} 
                     \n 0. name of the user: #{name}
                     \n 1. Mail id of the user : #{mail_id} .
                     \n 2. Message of the user :#{message}. "
                                                               
        end
        email.deliver!
  end 
    


end 








