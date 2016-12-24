require "google_drive"
require 'capybara'
require 'headless'

class GroupsController < ApplicationController


def index


end


def post
if params[:password].eql? "nopassword" 
  postMessageToGroups(params[:email],params[:password],params[:message])
end
redirect_to "/groups"

end

def postMessageToGroups(email,password,message)

    #1. Get the data from google sheet

    #2. Post one by one


    #1. No cell element should ne null
    #2. Message should not be null
    #3. 

  session = GoogleDrive::Session.from_config("config.json")
  ws = session.spreadsheet_by_key("1-nVLOe1nU7P2XHVJ-sI9LB_AUp_YxhseIFaZtq46J2o").worksheets
  output_spreadsheet = session.spreadsheet_by_key("1wV5NKZmPUiCI-COHoKdwDnLy_pwvzIY57Eq2IXdmQ9M").worksheets[0]
  total_posts_in_this_session = 0
  puts "FBGR: Starting Fb autoposting for " + ws.length.to_s + " tabs(users).... " 
    begin
      0.upto(ws.length) do |sheet_num|
        total_posts_by_user = 0
         
        if ws[sheet_num][4,1].length == 0 || ws[sheet_num][4,2].length == 0
            puts "FBGR: Empty User found. Please enter user details at row 4 and col 1,2 "
            next
        end
        puts "FBGR: Starting a new session for " + ws[sheet_num][4,1]

        headless = Headless.new
        headless.start
        session = Capybara::Session.new(:selenium) 
        session.visit "https://m.facebook.com"
        session.find("input[name='email'").set(ws[sheet_num][4,1])
        session.find("input[name='pass'").set(ws[sheet_num][4,2])
        session.click_button("Log In")
        sleep 5
        puts "FBGR: Logged in for " + ws[sheet_num][4,1]
        2.upto(15) do |i|
          
          groupid = ws[sheet_num][i,4]  
          if groupid.length == 0
              puts "FBGR: Empty Group found in sheet " + sheet_num.to_s + " at row " + i.to_s 
              next
          end

          begin
            session.visit "https://m.facebook.com/groups/" + groupid
            sleep 12
            session.find("textarea").set(message)
            sleep 10
            session.click_on("Post")
            postSharingResult(output_spreadsheet,message ,ws[sheet_num][4,1],Time.new , groupid)
            sleep 30
            total_posts_by_user = total_posts_by_user + 1
            total_posts_in_this_session  = total_posts_in_this_session  + 1
            puts "FBGR: Posting successful, Total: " + total_posts_in_this_session.to_s + " By " +  ws[sheet_num][4,1] + ": " + total_posts_by_user.to_s
          rescue Exception => e
            puts "FBGR: caught exception while Posting comment #{e}! ohnoes!"
          end  


        end

        session.driver.quit;
        sleep 60

      end

  rescue Exception => e
    puts "FBGR: caught exception in the beginning #{e}! ohnoes!"
  end


end




    def postSharingResult(output_spreadsheet , message  , name , time  ,groupid )


              present_row_no = output_spreadsheet.num_rows + 1 

              output_spreadsheet[present_row_no, 1] = name
              output_spreadsheet[present_row_no ,2] = groupid
              output_spreadsheet[present_row_no ,3] = time.inspect
              output_spreadsheet[present_row_no ,4] = message
              output_spreadsheet.save     
              puts "FBGR: Posting result on the excel"
         
       
     end 


end
