require "google_drive"
require 'capybara'
require 'headless'
require  'bitly'

class GroupsController < ApplicationController


  def index

    # puts "press enter key "
    # names = gets 
    # render :text => names 

  end


  def post

  if params[:password].eql? "nopassword" 

    sharing_message  = params[:message].to_s + "  " + shortening_url(params[:bitly] ,  params[:link]).to_s 
    postMessageToGroups(sharing_message , params[:type_pos] )
  end
 

  redirect_to "/groups"

  end

def postMessageToGroups(message ,  sharing_type )

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
        # headless.start
        session = Capybara::Session.new(:selenium) 
        session.visit "https://m.facebook.com"
        session.find("input[name='email'").set("sonalchinioti@gmail.com")
        session.find("input[name='pass'").set("bhagatsingh@123")
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

                if sharing_type.eql? "comment"

                       
                   comment(session,groupid,"Sonal Vij Chinioti",message)

               else 

                    posting(session , message ,output_spreadsheet , ws ,  groupid )

                end 


         

            total_posts_by_user = total_posts_by_user + 1
            total_posts_in_this_session  = total_posts_in_this_session  + 1
           
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


     def posting (session , message ,output_spreadsheet , ws ,  groupid )
           sleep 12
            session.find("textarea").set(message)
            sleep 10
            session.click_on("Post")
            postSharingResult(output_spreadsheet,message ,ws[sheet_num][4,1],Time.new , groupid)
            sleep 30
          
            puts "FBGR: Posting successful, Total: " + total_posts_in_this_session.to_s + " By " +  ws[sheet_num][4,1] + ": " + total_posts_by_user.to_s
     end 

     def comment(session,groupid,owner ,message)
        
        users = [owner]
        hit = 0
        count = 0
        no_articles = 0
        while hit < 1 && count < 5
          puts "hit=" + hit.to_s
          puts "count=" + count.to_s
          
          session.find_all("div[role='article']").each do |article|

              begin
                puts article.text
                puts "FBGR:getting other articles" + (no_articles += 1).to_s
                if  users.any? { |word| article.text.include?(word) }

                    hit = hit + 1
                    puts "FBGR: Found a post by Buzz member" + session.find(:xpath, article.path + "/div[1]/div[1]/h3/strong/a").text
                        begin
                          session.find(:xpath, article.path + "/div[2]/div[2]/a[1]").click
                        rescue Exception => e
                          puts "FBGR: caught exception #{e}! ohnoes!"
                        end
                     session.find("input[id='composerInput']").set(message)
                     session.click_button("Comment")
                     puts "Posted a comment.. Exiting"
                     sleep 20 
                     return

                end
                puts "FBGR:articles not of particular user."
              rescue Exception => e
                puts "FBGR: caught exception #{e}! ohnoes!"
              end
              sleep 10
          end
          puts "about to click See more posts"

          session.click_link("See More Posts")
          sleep 5
          count = count + 1
        end 
         # # if name found in article
         # # session.find(:xpath,"/html/body/div/div/div[2]/div/div[1]/div[4]/div[1]/div[1]/a[0]")
         #                        /html/body/div/div/div[2]/div/div[1]/div[4]/div[1]/div[1]
         # # click comment and do the thing
            

    end

  

      def shortening_url(make_bilty ,link)

        if make_bilty.present?

            Bitly.use_api_version_3
            bitly = Bitly.new("o_4r1db5nfht", "R_ca96617555c44fd38ff0b1b0e975e3d7")
            bitly_link = bitly.shorten(link)


          return bitly_link.short_url

        end 

        return link 

      end 




end


