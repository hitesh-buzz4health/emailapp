
class MailsController < ApplicationController

skip_before_action :verify_authenticity_token


def index

end 

def post


    if !params.nil?

         sending_email(params)
    end 


   redirect_to "/mails"

 
end 




def sending_email(params)

  google_session = GoogleDrive::Session.from_config("config.json")
  goodle_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370")
  worksheet  = goodle_spreadsheet.worksheets[1]
  session = Capybara::Session.new(:selenium) 
  session.visit "https://www.gmail.com/"
  session.find("input[name='Email']").set(params[:google_email])
  session.find("input[name='signIn']").click()
  session.find("input[name='Passwd']").set(params[:google_password])
  session.find("input[name='signIn']").click()
  puts "GMES: logged in for" + params[:google_email].to_s

  sleep 40
  total_no_of_mails_sent = 0 
  2.upto(worksheet.num_rows) do |number|
      begin
         

         session.visit "https://mail.google.com/mail/u/0/#inbox?compose=new"
         sleep 15
        
         session.find("textarea[name='to']").set(worksheet[number,2])
         
         subject = worksheet[number,3].gsub! '*|FNAME|*' , worksheet[number , 1].to_s

         session.find("input[name='subjectbox']").set(subject)
         template = worksheet[number,4]
         template.gsub! '*|FNAME|*' , worksheet[number ,5]
         template.gsub! '*|EMAIL|*' ,  worksheet[number ,6]
         template.gsub! '*|Title|*' ,  worksheet[number ,7]
         template.gsub! '*|Description|*' ,  worksheet[number ,8]
         template.gsub! '*|ActionUrl|*' ,  worksheet[number ,9]
         template.gsub! '*|ImageUrl|*' ,  worksheet[number ,10]



         jsTORun = "document.getElementsByClassName(\"Am Al editable LW-avf\")[0].innerHTML= \"" +template+"\" ";
         session.evaluate_script(jsTORun);
        


         session.find("input[name='subjectbox']").native.send_keys( :control  , :enter )
          total_no_of_mails_sent = total_no_of_mails_sent + 1
          puts "GMES: no of current mail being send in this session " +total_no_of_mails_sent.to_s

          sleep 20 

       
        rescue  Exception => e
          puts "GMES: caught exception #{e}! ohnoes!"
        end 

 end 
        
          puts "GMES: total no of mails sent in this session " +total_no_of_mails_sent.to_s

          session.driver.quit;


end 

end 