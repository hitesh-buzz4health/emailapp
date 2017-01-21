class MailsController < ApplicationController

skip_before_action :verify_authenticity_token


  def index

  end 

  def post



    sending_email(params)


     redirect_to "/mails"

   
  end 




def sending_email(params)

  google_session = GoogleDrive::Session.from_config("config.json")
  goodle_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370")
  ws = goodle_spreadsheet.worksheets
  start_sheet_no = 0
  end_sheet_no = ((ws.length)-1)
  start_sheet_no.upto(end_sheet_no) do |sheet_num|

                  worksheet  = ws[sheet_num]
                  session = Capybara::Session.new(:selenium) 
                  session.visit "https://www.gmail.com/"
                        if params[:google_email].present?  &&  params[:google_password].prsent?
                            session.find("input[name='Email']").set(params[:google_email])
                            session.find("input[name='signIn']").click()
                            session.find("input[name='Passwd']").set(params[:google_password])
                            session.find("input[name='signIn']").click()
                            puts "GMES: logged in for" + params[:google_email].to_s

                        else 
                            session.find("input[name='Email']").set(worksheet[2,1])
                            session.find("input[name='signIn']").click()
                            session.find("input[name='Passwd']").set(worksheet[2,2])
                            session.find("input[name='signIn']").click()
                            puts "GMES: logged in for" + worksheet[2,1].to_s

                        end 

                  sleep 40
                  total_no_of_mails_sent = 0 
                  2.upto(worksheet.num_rows) do |number|

                       begin
                       
                          if worksheet[number , 11].eql? "sent"

                          puts "GMES:mail to this user has already been sent " + number.to_s 
                          next 

                         end 

                         if worksheet[number , 5].length == 0 || worksheet[number , 6].length == 0 
                          puts "GMES:empty cells encountered  for line number " + number.to_s 
                          next 
                         end   

                         session.visit "https://mail.google.com/mail/u/0/#inbox?compose=new"
                         sleep 15
                        
                         session.find("textarea[name='to']").set(worksheet[number,6])
                         
                         # subject = worksheet[number,3].gsub! '*|FNAME|*' , worksheet[number , 5].to_s
                         subject ="Video of the Day: Brain Strokes, Major lifestyle disorder by Dr. A N Jha"
                         
                         session.find("input[name='subjectbox']").set(subject)
                         template = worksheet[2,4].clone
                         template.gsub! '*|FNAME|*' , worksheet[number ,5]
                         template.gsub! '*|Email|*' ,  worksheet[number ,6]
                         template.gsub! '*|Title|*' ,  worksheet[2,7]
                         template.gsub! '*|Description|*' ,  worksheet[2 ,8]
                         template.gsub! '*|ActionUrl|*' ,  worksheet[2 ,9]
                         template.gsub! '*|ImageUrl|*' ,  worksheet[2 ,10]


                         jsTORun = "document.getElementsByClassName(\"Am Al editable LW-avf\")[0].innerHTML= \"" +template+"\" ";
                         session.evaluate_script(jsTORun);
                        
                            
                          
                          session.find("input[name='subjectbox']").native.send_keys( :control  , :enter )
                          
                          worksheet[number,11] = "sent"
                          worksheet.save  
                          
                          
                          total_no_of_mails_sent = total_no_of_mails_sent + 1
                          puts "GMES: no of current mail being send in this session " +total_no_of_mails_sent.to_s

                          if total_no_of_mails_sent == 500

                             puts "GMES: 500 mails have been sent ."
                             break 

                          end 

                          sleep 20 

                       
                        rescue  Exception => e
                          puts "GMES: caught exception #{e}! ohnoes!"

                          worksheet[number,11] =  e.to_s
                          worksheet.save  
                        end 

                  end 
                        
                     puts "GMES: total no of mails sent in this session " +total_no_of_mails_sent.to_s

                     session.driver.quit;


        end 

    end 

end 
