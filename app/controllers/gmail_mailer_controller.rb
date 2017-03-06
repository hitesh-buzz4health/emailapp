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

	              # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
	 
			      google_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370")
			      puts "GMES : Session of google sheet is created."
			      ws = google_spreadsheet.worksheets
			      start_sheet_no = 0
			      end_sheet_no = 0
			      gmail = nil 
			      total_no_of_mails_for_the_day = 0
			      start_sheet_no.upto(end_sheet_no) do |sheet_num|

			              worksheet  = ws[3]
			              email_sheets = ws[(ws.length)-1] 
			 			  total_no_of_mails_for_this_user = 0	
			 			  current_user = nil
			 			  user_name = nil 
			            
			    
			              2.upto(worksheet.num_rows) do | number |

			                    begin       
			 
			          	             if worksheet[number , 11].eql? "sent"
			                            puts  "GMES:mail to this user has already been sent " + number.to_s 
			                            next 

			                          end 

			                          if worksheet[number , 5].length == 0 || worksheet[number , 6].length == 0 
			                            puts  "GMES:empty cells encountered  for line number " + number.to_s 
			                            next 
			                          end 

							           subject = params[:subject_email].clone
							           if subject.include? "*|FNAME|*"

							            subject.gsub! '*|FNAME|*' , worksheet[number , 5].to_s                              
							            
							           end 

			                             if  current_user.nil?  || total_no_of_mails_for_this_user ==  1500

			                                if !current_user.nil?
			                                	puts "Gmes: saving current user data"
				                                current_user_row =   get_user email_sheets , current_user
				                                email_sheets[current_user_row,5] = "used"
				                                email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
				                                email_sheets.save
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

			                           template.gsub! '*|FNAME|*' , worksheet[number ,5]

			                           template.gsub! '*|Email|*' ,  worksheet[number ,6]
			                           template.gsub! '*|Title|*' ,   params[:main_title] 
			                           template.gsub! '*|Description|*' ,  params[:main_description]  
			                           template.gsub! '*|ActionUrl|*' ,   params[:Action_url]   
			                           template.gsub! '*|ImageUrl|*' , params[:Image_url]   
			                           # removing new line if any exists.
			                           template.delete!("\n")
			                           puts "Gmes : mail is being sent to " +worksheet[number,6].to_s
			              
										email = gmail.compose do
										  to  worksheet[number,6].to_s
										  from  user_name.to_s
										  subject  subject.to_s
						                  
						                  #for adding html template 
						                  html_part do

											    content_type 'text/html; charset=UTF-8'
											    body  template.to_s
										   end

			                                     
						                 end
						                 #delivering email
						                 email.deliver!
						                 total_no_of_mails_for_this_user = total_no_of_mails_for_this_user  + 1
						                 total_no_of_mails_for_the_day = total_no_of_mails_for_the_day + 1 
						                 puts "Gmes : no of mails sent for this user is " +total_no_of_mails_for_this_user.to_s
						                 puts "Gmes : no of total  mails for this session " +total_no_of_mails_for_the_day.to_s
						                 worksheet[number,11] = "sent"
			                             worksheet.save  

			                        rescue  Exception => e
			                              worksheet[number,11] =  e.to_s
			                              worksheet.save  
			                              puts  "GMES: caught exception #{e}! ohnoes!"
			                        end 
			                         

			              end 

			      end 




	end 


	def change_user email_sheets 
	      
		2.upto(email_sheets.num_rows) do | user_no |

			if !email_sheets[user_no , 5].eql? "used"
		      user_info = Hash.new
		      user_info[:name] = email_sheets[user_no , 1].to_s + "From Buzz4health" 
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


end
