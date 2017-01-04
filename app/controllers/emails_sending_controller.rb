
class news_fetching_controller < ApplicationController

def index

end 

def post

session = Capybara::Session.new(:selenium) 

  begin

   session.visit "https://www.gmail.com/"
   session.find("input[name='Email']").set("sonal@buzz4health.com")
   session.find("input[name='signIn']").click()
   session.find("input[name='Passwd']").set("password")
   begin
    puts "FBGR: clicking password"

   session.find("input[name='signIn']").click()
   sleep 10

   puts "FBGR: after password clicked  "
   

   rescue  Exception => e

   puts "FBGR: caught exception #{e}! ohnoes!"

   end 

   session.visit "https://mail.google.com/mail/u/0/#inbox?compose=new"
   sleep 10
   session.find("textarea[name='to']").set("to my friend")
   session.find("input[name='subjectbox']").set("this is a test mail")

   jsTORun = "document.getElementsByClassName(\"Am Al editable LW-avf\")[0].innerHTML= \"this is wsome <a href='google.com'>this is my link to take away</a>\" ";
   session.evaluate_script(jsTORun);

   gets

  rescue  Exception => e
             puts "FBGR: caught exception #{e}! ohnoes!"

   end 


end 

end 