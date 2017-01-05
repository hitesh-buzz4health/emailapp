
class news_fetching_controller < ApplicationController

def index

end 

def post

  google_session = GoogleDrive::Session.from_config("config.json")
  worksheet = google_session.spreadsheet_by_key("1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I").worksheets[1]
  session = Capybara::Session.new(:selenium) 


  2.upto(worksheet.num_rows) do |number|

      # begin

       session.visit "https://www.gmail.com/"
       session.find("input[name='Email']").set("sonal@buzz4health.com")
       session.find("input[name='signIn']").click()
       session.find("input[name='Passwd']").set("8955299099")
       session.find("input[name='signIn']").click()
       sleep 20
       session.visit "https://mail.google.com/mail/u/0/#inbox?compose=new"
       sleep 10
       
       session.find("textarea[name='to']").set(worksheet[number,2])
       # session.find("input[name='cc']").set("sonalchinioti@gmail.com")
       subject = worksheet[number,3].gsub! '*|FNAME|*' , worksheet[number , 1].to_s

       session.find("input[name='subjectbox']").set(subject)
       puts "fbgr"
       template = worksheet[number,4]
       template.gsub! '*|FNAME|*' , worksheet[number ,5]
       template.gsub! '*|EMAIL|*' ,  worksheet[number ,6]
       template.gsub! '*|Title|*' ,  worksheet[number ,7]
       template.gsub! '*|Description|*' ,  worksheet[number ,8]
       template.gsub! '*|ActionUrl|*' ,  worksheet[number ,9]
       template.gsub! '*|ImageUrl|*' ,  worksheet[number ,10]



       jsTORun = "document.getElementsByClassName(\"Am Al editable LW-avf\")[0].innerHTML= \"" +template+"\" ";
       session.evaluate_script(jsTORun);
       #gets 

       #session.find("div[data-tooltip='Send']").click()

       session.find("col[id=':lv']").click

       gets
      # rescue  Exception => e
      # puts "FBGR: caught exception #{e}! ohnoes!"
      # end 

  end 
end 