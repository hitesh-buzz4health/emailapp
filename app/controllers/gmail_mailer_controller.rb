class GmailMailerController < ApplicationController


	def index


	end 

    def post 

       if  params[:password].eql? "nopassword"

	        # creating a worker thread 
		    worker = Workers::Worker.new	
		    worker.perform do

		    send_emails params 
		    end 

		    redirect_to "/mails_using_gmail_api"
       end 

    end 

  def send_emails params
    #creating logger file in ruby
    @logger = Logger.new('./log/google_script.log', 5, 1024000)
    @logger.level = Logger::INFO

    credentials = Google::Auth::UserRefreshCredentials.new(
       client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
       client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
       scope: [
         "https://www.googleapis.com/auth/drive",
         "https://spreadsheets.google.com/feeds/",
       ],
       refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4"); nil
    google_session = GoogleDrive::Session.from_credentials(credentials); nil

    google_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370"); nil
    post_logs "GMES : Session of google sheet is creat"
    ws = google_spreadsheet.worksheets; nil
   
    email_sheets = ws[(ws.length)-1]; nil
    @output_sheet = ws[0]; nil
   
    gmail = nil 
    total_no_of_mails_for_the_day = 0 
    total_no_of_mails_for_this_user = 0
    total_no_of_errors = 0 
    start_time = Time.now 
    current_user = nil
    user_name = nil 
    @num_of_rows = @output_sheet.num_rows + 1
    if  !params[:type_country].nil?  && !params[:type_database].nil? && params[:type_database].eql?("buzz4health")
      users_details = get_model_by_country params[:type_country]
    else
      users_details   = get_model params[:type_database]  
    end 
    if !params[:resume].nil?
      last_user =  @output_sheet[2 ,  8].to_i
      post_logs last_user
      if last_user.is_a? Integer
        users_details = users_details[last_user..-1]
          total_no_of_mails_for_the_day  = last_user
        post_logs users_details.count
      end
    end

    current_page = 0
 
    item_count = users_details.count
    post_logs "User count: " + item_count.to_s
    while item_count > 0
      users_details.skip(current_page * 900).limit(900).each do |user|
        if !user.nil?
          begin
            post_logs "Sending email to user : " + user.name.to_s
            reciever_detials = get_recievers_details params[:type_database]  , user 
            reciever_name = reciever_detials["name"]
            reciever_email = reciever_detials["emails"].to_s                 
            if reciever_email.length == 0
              post_logs "Gmes: Receiver email length is 0" 
              next
            end    
            subject = params[:subject_email].clone             
            if subject.include? "*|FNAME|*"

            subject.gsub! '*|FNAME|*' , reciever_name                          

            end 

            if  current_user.nil?  || total_no_of_mails_for_this_user ==  1500
              if !current_user.nil?
                post_logs "Gmes: saving current user data"
                current_user_row =   get_user email_sheets , current_user
                email_sheets[current_user_row,5] = "used"
                email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
                email_sheets.save; nil
                @output_sheet.save; nil
                total_no_of_mails_for_this_user = 0
                post_logs "Gmes:Logging out the current user."     
                gmail = nil 
                post_logs "Gmes : Putting thread to sleep."
                sleep 3

              end
              #getting a new user 
              user_info = change_user email_sheets 
              gmail = Gmail.connect( user_info[:email],  user_info[:password])
              current_user = user_info[:email]
              user_name  = user_info[:name]
              #capitalizing the first character of the name .
              user_name[0] = user_name[0].capitalize
              
              post_logs "Gmes : current user for this instance." + current_user.to_s
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
            post_logs "Gmes : mail is being sent to " + reciever_name + " " +reciever_email 
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
            total_no_of_mails_for_this_user = total_no_of_mails_for_this_user  + 1
            total_no_of_mails_for_the_day = total_no_of_mails_for_the_day + 1 

            post_output user_name , reciever_name , reciever_email , subject , total_no_of_mails_for_the_day

            post_logs "Gmes : no of mails sent for this user is " +total_no_of_mails_for_this_user.to_s
            post_logs "Gmes : no of total  mails for this session " +total_no_of_mails_for_the_day.to_s    
            post_logs "Gmes : total no of mails for this session "  +users_details.count.to_s
            post_logs "Gmes : total no of errors for this session "  +total_no_of_errors.to_s

          rescue  Exception => e        
            begin
              total_no_of_errors = total_no_of_errors + 1 
              @output_sheet[@num_of_rows , 6] = e
              @output_sheet.save; nil        
            rescue  Exception => e
              post_logs  "GMES: caught exception #{e}! ohnoes!"
            end

            post_logs  "GMES: caught exception #{e}! ohnoes!"
          end
        end
      end
      item_count-=900
      current_page+=1
    end
          #saving sheet in case when emails are less
    post_logs "Gmes : finishing up the script" 
    send_results(total_no_of_mails_for_the_day , users_details.count.to_s , start_time , params[:subject_email] ,  total_no_of_errors.to_s)
    post_logs "Gmes : result has been sent."
    @output_sheet.save; nil
    email_sheets[current_user_row,5] = "used"
    email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
    email_sheets.save; nil
    gmail.logout
  end 
  
	def sending_mails params
    #creating logger file in ruby
    @logger = Logger.new('./log/google_script.log', 5, 1024000)
    @logger.level = Logger::INFO

    credentials = Google::Auth::UserRefreshCredentials.new(
       client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
       client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
       scope: [
         "https://www.googleapis.com/auth/drive",
         "https://spreadsheets.google.com/feeds/",
       ],
       refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4"); nil
    google_session = GoogleDrive::Session.from_credentials(credentials); nil

    google_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370"); nil
    post_logs "GMES : Session of google sheet is creat"
    ws = google_spreadsheet.worksheets; nil
   
    email_sheets = ws[(ws.length)-1]; nil
    @output_sheet = ws[0]; nil
   
    gmail = nil 
    total_no_of_mails_for_the_day = 0 
    total_no_of_mails_for_this_user = 0
    total_no_of_errors = 0 
    start_time = Time.now	
	  current_user = nil
	  user_name = nil 
	  @num_of_rows = @output_sheet.num_rows + 1
    if  params[:type_country].eql?"India"   
      users_details   = get_model params[:type_database]  
    else
      users_details = get_model_by_country params[:type_country]
    end 
    if !params[:resume].nil?
      last_user =  @output_sheet[2 ,  8].to_i
      post_logs last_user
      if last_user.is_a? Integer
        users_details = users_details[last_user..-1]
          total_no_of_mails_for_the_day  = last_user
        post_logs users_details.count
      end
    end

    current_page = 0
 
    item_count = users_details.count
    post_logs "User count: " + item_count
    while item_count > 0
      users_details.skip(current_page * 900).limit(900).each do |user|
        post_logs "Sending email number: " + user.name
        if !user.nil?
          begin            
            reciever_detials = get_recievers_details params[:type_database]  , user 
            reciever_name = reciever_detials["name"]
            reciever_email = reciever_detials["emails"].to_s                 
            if reciever_email.length == 0
              post_logs "Gmes: Receiver email length is 0" 
              next
            end    
            subject = params[:subject_email].clone             
            if subject.include? "*|FNAME|*"

            subject.gsub! '*|FNAME|*' , reciever_name                          

            end 

            if  current_user.nil?  || total_no_of_mails_for_this_user ==  1500
              if !current_user.nil?
                post_logs "Gmes: saving current user data"
                current_user_row =   get_user email_sheets , current_user
                email_sheets[current_user_row,5] = "used"
                email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
                email_sheets.save; nil
                @output_sheet.save; nil
                total_no_of_mails_for_this_user = 0
                post_logs "Gmes:Logging out the current user."     
                gmail = nil 
                post_logs "Gmes : Putting thread to sleep."
                sleep 3

              end
              #getting a new user 
              user_info = change_user email_sheets 
              gmail = Gmail.connect( user_info[:email],  user_info[:password])
              current_user = user_info[:email]
              user_name  = user_info[:name]
              #capitalizing the first character of the name .
              user_name[0] = user_name[0].capitalize
              
              post_logs "Gmes : current user for this instance." + current_user.to_s
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

            post_logs "Gmes : mail is being sent to " + reciever_name + " " +reciever_email 
                     
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
            total_no_of_mails_for_this_user = total_no_of_mails_for_this_user  + 1
            total_no_of_mails_for_the_day = total_no_of_mails_for_the_day + 1 

            post_output user_name , reciever_name , reciever_email , subject , total_no_of_mails_for_the_day

            post_logs "Gmes : no of mails sent for this user is " +total_no_of_mails_for_this_user.to_s
            post_logs "Gmes : no of total  mails for this session " +total_no_of_mails_for_the_day.to_s    
            post_logs "Gmes : total no of mails for this session "  +users_details.count.to_s
            post_logs "Gmes : total no of errors for this session "  +total_no_of_errors.to_s

          rescue  Exception => e        
            begin
              total_no_of_errors = total_no_of_errors + 1 
              @output_sheet[@num_of_rows , 6] = e
              @output_sheet.save; nil        
            rescue  Exception => e
              post_logs  "GMES: caught exception #{e}! ohnoes!"
            end

            post_logs  "GMES: caught exception #{e}! ohnoes!"
          end
        end
      end
      item_count-=900
      current_page+=1
    end
          #saving sheet in case when emails are less
    post_logs "Gmes : finishing up the script" 
    send_results(total_no_of_mails_for_the_day , users_details.count.to_s , start_time , params[:subject_email] ,  total_no_of_errors.to_s)
    post_logs "Gmes : result has been sent."
    @output_sheet.save; nil
    email_sheets[current_user_row,5] = "used"
    email_sheets[current_user_row,6] =  total_no_of_mails_for_this_user
    email_sheets.save; nil
    gmail.logout
	end 

	def send_results(total_no_of_mails_for_the_day , total_no_of_mails_selected  , time , mails_subject  ,  total_no_of_errors)
        gmail = Gmail.connect("drdeepikakapoor@buzz4health.com","whitebutter")
        	email = gmail.compose do
					to  ['sheerin@buzz4health.com' ,'hitesh.ganjoo@buzz4health.com' , 'sonal@buzz4health.com' , 'tushar.gupta@buzz4health.com' , 'lokesh.vaishnavi@buzz4health.com' ]
					from  "Mails Campaign finished "
				    subject  "Mail campaign for the day."
				    body    "Stats for the mail Campaign send on #{Time.now} 
				             \n 0.Subject for this campaign : #{mails_subject}
				             \n 1.Total no of mail sent: #{total_no_of_mails_for_the_day} .
				             \n 2.Total no of mails to be send : #{total_no_of_mails_selected} .
				             \n 3.Total time taken  to send the campaign : #{Time.now - time} secs .
				             \n 4.Total no error's occured: #{total_no_of_errors} .
				             \n Regards : \n email app. "
										     

			                                     
		    end

          #delivering email
        email.deliver!

	end 
    

    def get_model model_type
    	        
                if model_type.eql? "buzz4health"
                  return  Buzz4healthUser.where(:specializations.in => params[:specialization])
                elsif model_type.eql? "justdial" 

			            return  ReferenceJustdial.where(:ReferenceName=>"Just Dial")
                elsif model_type.eql? "iactauser" 
                  return  IactaUser.all
                elsif model_type.eql? "scauser" 
                  return  ScaUser.all  
			    else 
                   return  Reference.all
			    end 

    end 
  
  def get_model_by_country country 
          if country.eql?"US"
              return Buzz4healthUser.where(:country_code.in => ["US", "us", "Us"])
          elsif country.eql?"UK"
              return   Buzz4healthUser.where(:country_code.in => ["UK", "uk", "Uk"])
          elsif country.eql?"CA"
          	 return Buzz4healthUser.where(:country_code.in => ["CA", "ca", "Ca"])
          else 
              return Buzz4healthUser.where(:country_code.in => ["IN", "in", "In"])

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

                     emails = user.Emails
                     if emails.kind_of?(String)
                      emails = emails.split(",").map{|e| e.strip}
                     end
                     recievers_detials ["emails"]  = emails[0]
                     return recievers_detials

                elsif (model_type.eql? "iactauser") || (model_type.eql? "scauser")

                     recievers_detials["name"] = user.name
                     recievers_detials ["emails"]  = user.email
                     return recievers_detials          
			    else 
                    recievers_detials["name"] = user.Name
                    recievers_detials ["emails"]  = user.Emails[0]
                    return recievers_detials
			    end 


    end 


	def change_user email_sheets 
	      
		2.upto(email_sheets.num_rows) do | user_no |

			if email_sheets[user_no , 5].eql? ""

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



	def post_output mailers_name , user_name , user_email , subject  , total_no_of_mails_for_the_day
       
		@output_sheet[@num_of_rows, 1] = mailers_name
		@output_sheet[@num_of_rows ,2] = user_name
		@output_sheet[@num_of_rows , 3] = user_email
		@output_sheet[@num_of_rows , 4] = subject
		@output_sheet[@num_of_rows,5] = Time.now.strftime("%d/%m/%Y %H:%M")
		@output_sheet[2,  8] = total_no_of_mails_for_the_day
		@num_of_rows = @num_of_rows + 1 



	end 


	def post_logs logs

		@logger.info logs  
		puts logs
       
	end 
   


def log
  @log = `tail -n 40 log/google_script.log`
end 
  	


end
