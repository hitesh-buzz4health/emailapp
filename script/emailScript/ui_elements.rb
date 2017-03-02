#!/usr/bin/ruby

# ZetCode Ruby Qt tutorial
#
# This program uses Qt::Label widget to 
# show lyrics of a song.
#
# author: Jan Bodnar
# website: www.zetcode.com
# last modified: September 2012

require 'Qt'
require 'openssl'
require 'D:\scripts\emailScript\final_gmail_script.rb'
require 'capybara'
require 'google_drive'
require 'workers'
# require 'headless'





class QtApp < Qt::Widget



        slots 'on_clicked()'
        slots 'on_cancelled()'
        # slots 'on_toggled(bool)'

         
    
    def initialize
        super
        
        setWindowTitle "Email Sending"
       
        init_ui
       
        

        show
    end
    
    def init_ui
        label = Qt::Label.new "Email Sending", self
        label.setFont Qt::Font.new "Purisa", 20

        name_label =Qt::Label.new "Enter  Email", self
        name_label.setFont Qt::Font.new "Purisa", 10

        @email_field = Qt::LineEdit.new  self
      
        password_label = Qt::Label.new "Enter your password"
        password_label.setFont Qt::Font.new "Purisa", 10

        @password_field = Qt::LineEdit.new  self

        # headless_checkbox= Qt::CheckBox.new "turn it headless", self
        # headless_checkbox.setCheckable true

        # connect headless_checkbox, SIGNAL("toggled(bool)"), SLOT("on_toggled(bool)")

   
        @no_of_mails_sent =  Qt::Label.new "No of Mails sent"
        @no_of_mails_sent.setFont Qt::Font.new "Purisa", 10

        @no_of_errors_occured =  Qt::Label.new "No of errors occured"
        @no_of_errors_occured.setFont Qt::Font.new "Purisa", 10

               

        submit_button = Qt::PushButton.new 'submit', self
        submit_button.setCheckable true
        connect submit_button , SIGNAL('clicked()'), SLOT("on_clicked()")

        exit_button = Qt::PushButton.new 'Exit', self
        exit_button.setCheckable true 
        connect exit_button  , SIGNAL('clicked()') , SLOT("on_cancelled()")


        vbox = Qt::VBoxLayout.new
        vbox.addWidget  label
        vbox.addWidget  name_label
        vbox.addWidget  @email_field
        vbox.addWidget  password_label
        vbox.addWidget  @password_field
        # vbox.addWidget  headless_checkbox
        vbox.addWidget  @no_of_mails_sent
        vbox.addWidget  @no_of_errors_occured
        vbox.addWidget  submit_button
        vbox.addWidget  exit_button

        setLayout vbox
    end  

    def on_clicked
        params = Hash.new 

        params[:email] =   @email_field.text
        params[:password] =  @password_field.text

        
        puts params

        @worker = Workers::Worker.new
        @worker.perform do
        puts "GMES:Starting  workers thread"
        posting  params 
                

        end 



    end  

    def on_cancelled
       if !@worker.nil?
           puts "Gmes: killing worker thread"
           @worker.dispose(0.1)
       end 
       puts "GMES: exiting the script"
       exit 

    end 






    def posting params 
               
     credentials = Google::Auth::UserRefreshCredentials.new(
                 client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
                 client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
                 scope: [
                   "https://www.googleapis.com/auth/drive",
                   "https://spreadsheets.google.com/feeds/",
                 ],
                 refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
       google_session = GoogleDrive::Session.from_credentials(credentials)

      puts "GMES: creating instance of google sheets"
      goodle_spreadsheet = google_session.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1ghnZv1CQPBIfGPaFvdNuGpsT_fP0CGUf0V_84_6Cc1I/edit#gid=55910370")

      ws = goodle_spreadsheet.worksheets
      start_sheet_no = 0
      end_sheet_no = ((ws.length)-1)
      start_sheet_no.upto(end_sheet_no) do |sheet_num|

              worksheet  = ws[sheet_num]

                session = Capybara::Session.new(:selenium)
                puts "Gmes:creating session for the current user."
                # puts  "Gmes: value of headless" +@is_headless.to_s

                 
                session.visit "https://www.gmail.com/"
                      
                session.find("input[name='Email']").set(params[:email])
                session.find("input[name='signIn']").click()
                session.find("input[name='Passwd']").set(params[:password])
                session.find("input[name='signIn']").click()

                puts  "GMES: logged in for" +params[:email].to_s

                    sleep 15
                    total_no_of_mails_sent = 0 
                    total_no_of_errors_occured = 0
                    2.upto(worksheet.num_rows) do |number|

                         begin
                         
                           if worksheet[number , 11].eql? "sent"
                            puts  "GMES:mail to this user has already been sent " + number.to_s 
                            next 

                            end 

                           if worksheet[number , 5].length == 0 || worksheet[number , 6].length == 0 
                            puts  "GMES:empty cells encountered  for line number " + number.to_s 
                            next 
                           end   

                           session.visit "https://mail.google.com/mail/u/0/#inbox?compose=new"
                           sleep 5
                          
                           session.find("textarea[name='to']").set(worksheet[number,6])


                           
                           subject = worksheet[2 , 3].clone
                           if subject.include? "*|FNAME|*"

                            subject.gsub! '*|FNAME|*' , worksheet[number , 5].to_s                              
                            
                           end 
                          
                           puts subject 
                           session.find("input[name='subjectbox']").set(subject)
                           puts  "GMES: getting value of the template"
                           
                           template = worksheet[2,4].clone
                           puts  "GMES: value of the template loaded"

                           template.gsub! '*|FNAME|*' , worksheet[number ,5]

                           template.gsub! '*|Email|*' ,  worksheet[number ,6]
                           template.gsub! '*|Title|*' ,  worksheet[2,7]
                           template.gsub! '*|Description|*' ,  worksheet[2 ,8]
                           template.gsub! '*|ActionUrl|*' ,  worksheet[2 ,9]
                           template.gsub! '*|ImageUrl|*' ,  worksheet[2 ,10]

                           # removing new line if any exists.
                           template.delete!("\n")

                           puts  "GMES: Modification in template is done."
                             


                           jsTORun = "document.getElementsByClassName(\"Am Al editable LW-avf\")[0].innerHTML= \"" +template+ "\"";

                           puts  "GMES: template variable is formed #{jsTORun}"
                           session.evaluate_script(jsTORun);

                           puts  "GMES: Template is added to the mail "

                            
                            session.find("input[name='subjectbox']").native.send_keys( :control  , :enter )
                            worksheet[number,11] = "sent"
                            worksheet.save  
                            
                            
                            total_no_of_mails_sent = total_no_of_mails_sent + 1
                            progress_chnaged @no_of_mails_sent , "no of Mails sent -" + total_no_of_mails_sent.to_s
                                                    
                            puts  "GMES: no of current mail being send in this session " +total_no_of_mails_sent.to_s

                            if total_no_of_mails_sent == 5000

                               puts  "GMES: 5000 mails have been sent ."
                               next 
                            end 

                            sleep 5

                         
                          rescue  Exception => e
         
                              total_no_of_errors_occured = total_no_of_errors_occured + 1 
                              progress_chnaged  @no_of_errors_occured , "Total no of errors :-" +total_no_of_errors_occured.to_s
                              worksheet[number,11] =  e.to_s
                              worksheet.save  
                              puts  "GMES: caught exception #{e}! ohnoes!"
                              session.visit "https://mail.google.com"

                          end 

                    end 
                          

                       puts  "GMES: total no of mails sent in this session " +total_no_of_mails_sent.to_s

                       session.driver.quit;



      end 

    end 


       def progress_chnaged label , text 
           
          Qt.execute_in_main_thread(false) do # don't block the main thread
            # GUI code which executes in parallel with the main thread
            label.setText text 

          end   

      end 
end

app = Qt::Application.new ARGV
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

QtApp.new
app.exec