class GmailMailerController < ApplicationController


	def index


	end 

    def post 
    	
    sending_mails    params 
    redirect_to "/mails_using_gmail_api"

    end 
  
	def sending_mails params

	             credentials = Google::Auth::UserRefreshCredentials.new(
	                 client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
	                 client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
	                 scope: [
	                   "https://www.googleapis.com/auth/drive",
	                   "https://spreadsheets.google.com/feeds/",
	                 ],
	                 refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
	             google_session = GoogleDrive::Session.from_credentials(credentials)

	           
			      google_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370")
			      puts "GMES : Session of google sheet is created."
			      ws = google_spreadsheet.worksheets
			      email_sheets = ws[(ws.length)-1] 
                  @output_sheet = ws[0]
			  

			      gmail = nil 
			      total_no_of_mails_for_the_day = 0 
			      total_no_of_mails_for_this_user = 0	
			 	  current_user = nil
			 	  user_name = nil 
			 	  @num_of_rows = @output_sheet.num_rows + 1
			                   
			              users_details   = get_model params[:type_database]  

			              users_details.each do | user |

			                    begin       
			                           
                                      
                                      reciever_detials = get_recievers_details params[:type_database]  , user 
                                      reciever_name = reciever_detials["name"]
                                      reciever_email = reciever_detials["emails"] 
                                     
                                      if reciever_email.length == 0
                                      	puts "Gmes: this is not a proper email to send mails "
                                      	next
                                      end    
							           subject = params[:subject_email].clone
							           if subject.include? "*|FNAME|*"

							            subject.gsub! '*|FNAME|*' , reciever_name                          
							            
							           end 

			                             if  current_user.nil?  || total_no_of_mails_for_this_user ==  1500

			                                if !current_user.nil?
			                                	puts "Gmes: saving current user data"
				                                current_user_row =   get_user email_sheets , current_user
				                                email_sheets[current_user_row,5] = "used"
				                                email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
				                                email_sheets.save
				                                @output_sheet.save
				                                total_no_of_mails_for_this_user = 0
				                                puts "Gmes:Logging out the current user."     
                                                
				                                gmail.logout

			                                end
			                                
			                                #getting a new user 
			                                user_info = change_user email_sheets 
			                                gmail = Gmail.connect( user_info[:email],  user_info[:password])
			                                current_user = user_info[:email]
			                                user_name  = user_info[:name]
			                                #capitalizing the first character of the name .
			                                user_name[0] = user_name[0].capitalize
			                                puts "Gmes : current user for this instance." + current_user.to_s


			                             end 
			                           
			                           template = params[:html_body].clone

			                           template.gsub! '*|FNAME|*' , reciever_name.to_s 

			                           template.gsub! '*|Email|*' ,  reciever_email.to_s
			                           template.gsub! '*|Title|*' ,   params[:main_title] 
			                           template.gsub! '*|Description|*' ,  params[:main_description]  
			                           template.gsub! '*|ActionUrl|*' ,   params[:Action_url]   
			                           template.gsub! '*|ImageUrl|*' , params[:Image_url]   
			                           # removing new line if any exists.
			                           template.delete!("\n")
			                          
			                           puts "Gmes : mail is being sent to " + reciever_name + " " +reciever_email 
			                           
										email = gmail.compose do
										  to reciever_email
										  from  user_name
										  subject  subject.to_s
						                  
						                  #for adding html template 
						                  html_part do

											    content_type 'text/html; charset=UTF-8'
											    body  template.to_s
										   end

			                                     
						                 end
						                 #delivering email
						                 email.deliver!
						                 post_output user_name , reciever_name , reciever_email , subject
						                 total_no_of_mails_for_this_user = total_no_of_mails_for_this_user  + 1
						                 total_no_of_mails_for_the_day = total_no_of_mails_for_the_day + 1 
						                 puts "Gmes : no of mails sent for this user is " +total_no_of_mails_for_this_user.to_s
						                 puts "Gmes : no of total  mails for this session " +total_no_of_mails_for_the_day.to_s
						                
			                        rescue  Exception => e
			                        	
			                        	if !gmail.nil?
			                               gmail.logout
			                            end 
			                              @output_sheet.save
			                              puts  "GMES: caught exception #{e}! ohnoes!"
			                        end 
			                         

			              end 
                   
                #saving sheet in case when emails are less
                @output_sheet.save
                gmail.logout




	end 
    

    def get_model model_type
    	        
                if model_type.eql? "buzz4health"
                  return  Buzz4healthUser.where(:specializations.in => params[:specialization])
                elsif model_type.eql? "justdial" 
			      return  ReferenceJustdial.where(:ReferenceName=>"Just Dial")
			    else 
                   return  Reference.all
			    end 

    end 


    def get_recievers_details model_type , user 
    	          recievers_detials = Hash.new
    	        if model_type.eql? "buzz4health"

                    recievers_detials["name"] = user.name
                    recievers_detials ["emails"]  = user.email
                    return recievers_detials

                elsif model_type.eql? "justdial" 

                     recievers_detials["name"] = user.Name
                     recievers_detials ["emails"]  = user.Emails[0]
                     return recievers_detials
			    else 
                    recievers_detials["name"] = user.Name
                    recievers_detials ["emails"]  = user.Emails[0]
                    return recievers_detials
			    end 


    end 


	def change_user email_sheets 
	      
		2.upto(email_sheets.num_rows) do | user_no |

			if !email_sheets[user_no , 5].eql? "used"
		      user_info = Hash.new
		      user_info[:name] = email_sheets[user_no , 1].to_s + " From Buzz4health" 
		      user_info[:email] = email_sheets[user_no,3]
		      user_info[:password] = email_sheets[user_no , 4]
		      return user_info
		    end 

	   end 

	end

	def get_user email_sheets , current_user

	  2.upto(email_sheets.num_rows) do | user_no|

	  	 if current_user.eql? email_sheets[user_no ,3]
	         return user_no
	  	 end 

	  end 

	end 



	def post_output mailers_name , user_name , user_email , subject  
       
		@output_sheet[@num_of_rows, 1] = mailers_name
		@output_sheet[@num_of_rows ,2] = user_name
		@output_sheet[@num_of_rows , 3] = user_email
		@output_sheet[@num_of_rows , 4] = subject
		@output_sheet[@num_of_rows,5] = Time.now.strftime("%d/%m/%Y %H:%M")
		@num_of_rows = @num_of_rows + 1 



	end 


end
