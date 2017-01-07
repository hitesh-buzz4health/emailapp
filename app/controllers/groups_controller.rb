require 'date'

class GroupsController < ApplicationController


    def index

      # puts "press enter key "
      # names = gets 
      # render :text => names 

    end


    def post

      if params[:password].eql? "nopassword" 
          
        postMessageToGroups( params )
      end
     

      redirect_to "/groups"

    end

    def postMessageToGroups( params )
     

       session = GoogleDrive::Session.from_config("config.json")

       if params[:type_application].eql? "Buzz4health"

          spreadsheet = session.spreadsheet_by_key("1-nVLOe1nU7P2XHVJ-sI9LB_AUp_YxhseIFaZtq46J2o") 
          ws = spreadsheet.worksheets
          output_spreadsheet = session.spreadsheet_by_key("1wV5NKZmPUiCI-COHoKdwDnLy_pwvzIY57Eq2IXdmQ9M").worksheets[0]

       else 

          spreadsheet = session.spreadsheet_by_key("1fAgWJ7UV9mSAmcZcMtF4pkcC_POUe-9afM_JOXL85XY") 
          ws = spreadsheet.worksheets
          output_spreadsheet = session.spreadsheet_by_key("14OvsKoviBz0dc7uDiMufG2H9Wgl64tKKLDGX_kiyr0c").worksheets[0]

       end 

      @start_sheet_no =  0
      @total_no_of_sheets = ((ws.length)-1)
      total_posts_in_this_session = 0
      message = get_message(params , spreadsheet)
      get_sheet_no(ws , params[:facebook_email])
      puts "FBGR: Starting Fb autoposting for " + ws.length.to_s + " tabs(users).... " 
        begin
          @start_sheet_no.upto(@total_no_of_sheets) do |sheet_num|

             total_posts_by_user = 0
               
                if ws[sheet_num][4,1].length == 0 || ws[sheet_num][4,2].length == 0 
                    puts "FBGR: Empty User found. Please enter user details at row 4 and col 1,2 "
                    next
                end

               if  ws[sheet_num].title.eql? "messages" 

                  puts "FBGR: Message worksheet found "
                  next
                end 

              puts "FBGR: Starting a new session for " + ws[sheet_num][4,1]

              if params[:facebook_email].present?

                user_email = params[:facebook_email]
                user_password = params[:facebook_password]


              else
                  
                  user_email = ws[sheet_num][4,1]
                  user_password = ws[sheet_num][4,2]

              end 

              puts "FBGR: Starting a new session for " + "starting session"

              headless = Headless.new
              # headless.start
              session = Capybara::Session.new(:selenium) 
              session.visit "https://m.facebook.com"
              session.find("input[name='email'").set(user_email)
              session.find("input[name='pass'").set(user_password)
              session.click_button("Log In")
              process_sheet(ws[sheet_num] , output_spreadsheet , Date.today)
              puts "FBGR: Logged in for " + ws[sheet_num][4,1]

            2.upto(ws[sheet_num].num_rows) do |i|
              
                           
                    if ws[sheet_num][i ,5].eql? "cannot post"
                         
                         puts "FBGR: posting on this group for the day has already been done  " + ws[sheet_num][i,4].to_s
                         next

                    else 

                       groupid = ws[sheet_num][i,4]  

                          
                    end 


                    if groupid.length == 0
                        puts "FBGR: Empty Group found in sheet " + sheet_num.to_s + " at row " + i.to_s 
                        next
                    end

                  begin

                    session.visit "https://m.facebook.com/groups/" + groupid

                        if  params[:type_pos].eql? "comment"

                               
                           comment(session,groupid,ws[sheet_num][50,1],message)

                       else 

                            posting(session , message ,output_spreadsheet , ws ,  groupid  ,sheet_num )

                        end 
                    


                    total_posts_by_user = total_posts_by_user + 1
                    total_posts_in_this_session  = total_posts_in_this_session  + 1
                    
                    
                    puts "FBGR: Posting successful, Total: " + total_posts_in_this_session.to_s + " By " +  ws[sheet_num][4,1] + ": " + total_posts_by_user.to_s
                    
                    if !params[:facebook_email].present?  && total_posts_by_user == 15

                        puts "FBGR: Posting done , Total: By "  +  ws[sheet_num][4,1] + ": " + total_posts_by_user.to_s

                        break

                    elsif  total_posts_by_user == 30

                        puts "FBGR: Posting done from facebook, Total:  By " +  ws[sheet_num][4,1] + ": " + total_posts_by_user.to_s

                        break

                    end 


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
              output_spreadsheet[present_row_no ,3] = time.strftime("%Y-%m-%d")
              output_spreadsheet[present_row_no ,4] = message
              output_spreadsheet.save     
              puts "FBGR: Posting result on the excel"
         
       

     end 


     def posting (session , message ,output_spreadsheet , ws ,  groupid  , sheet_num)
            sleep 5
            session.find("textarea").set(message)
            sleep 15
            session.click_on("Post")
            postSharingResult(output_spreadsheet,message ,ws[sheet_num][4,1],Time.new , groupid)
            sleep 30
          
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


      def  get_sheet_no(ws , user_email)

        if user_email.present?

             0.upto((ws.length) -1 ) do |sheet_num|
                  
                if user_email.eql? ws[sheet_num][4,1]

                      @start_sheet_no = sheet_num
                      @total_no_of_sheets = sheet_num
                      return 
                end

             end 

          # else

          #      @start_sheet_no = 1
          #      @total_no_of_sheets = ws.length
    
        end 

      end 




     def get_message ( params  , spreadsheet )

        
          if !params[:message].eql? ""
                 sharing_message  = params[:message].to_s + "  " + shortening_url(params[:bitly] ,  params[:link]).to_s 

                 return sharing_message

          else 
              message_worksheet = spreadsheet.worksheet_by_title("messages")
              message_no  = 1 + Random.rand(message_worksheet.num_rows) 
              message  = message_worksheet[message_no , 1]          
              sharing_message  = message.to_s + "  " + shortening_url(params[:bitly] ,  params[:link]).to_s 

              return sharing_message
             

          end

     end 


   

    def process_sheet(worksheet, output_spreadsheet   ,date_range  )

           excel_array= Array.new 
           
           clear_column(worksheet)
          
                2.upto(output_spreadsheet.num_rows) do | number |
                             
                        

                             if   (output_spreadsheet[number , 3].split[0]).nil?
                                
                               puts "FBGR: Empty cell encountered at line number : "  +number.to_s 
                               next
                             end

                             sheet_no_day = Date.parse(output_spreadsheet[number , 3].split[0])

                          if date_range.eql? sheet_no_day

                                 excel_array  <<  output_spreadsheet[number , 2]     
                          
                          end 

                end
                 
                excel_array.each do | item |

                        
                     2.upto(worksheet.num_rows) do | number |
                     
                      
                        if  worksheet[number , 4].eql?  item
                              worksheet[number , 5 ] = "cannot post"
                              break
                                     
                         end 


                      end 
           
                end

           worksheet.save

     end 


    def clear_column(worksheet)

        2.upto(worksheet.num_rows) do |number|
     
             worksheet[number , 5 ] = " "

        end 

        worksheet.save

    end 

  
end


