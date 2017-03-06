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
require 'D:\scripts\facebooksharing\groups_controller.rb'
require 'openssl'
require 'workers'



class QtApp < Qt::Widget



        slots 'on_clicked()'
        slots 'on_cancelled()'



    def initialize
        super
        
        setWindowTitle "Facebook Sharing"
       
        init_ui
       
        

        show
    end
    
    def init_ui
        label = Qt::Label.new "Facebook Sharing ", self
        label.setFont Qt::Font.new "Purisa", 20

        name_label =Qt::Label.new "Enter Facebook Email", self
        name_label.setFont Qt::Font.new "Purisa", 10

        @email_field = Qt::LineEdit.new  self
      
        password_label = Qt::Label.new "Enter your password"
        password_label.setFont Qt::Font.new "Purisa", 10

        @password_field = Qt::LineEdit.new  self
  
        message_label = Qt::Label.new "Enter  Message to be shared", self
        message_label.setFont Qt::Font.new "Purisa", 10
        @message_field = Qt::LineEdit.new  self

        link_label = Qt::Label.new "Enter Link to be shared", self
        link_label.setFont Qt::Font.new "Purisa", 10
        @link_field = Qt::LineEdit.new  self


        @no_of_posts_shared =  Qt::Label.new "No of Mails sent"
        @no_of_posts_shared.setFont Qt::Font.new "Purisa", 10

        @drop_down_menu= Qt::ComboBox.new self
        @drop_down_menu.addItem "Buzz4health"
        @drop_down_menu.addItem "Medtape"


        submit_button = Qt::PushButton.new 'submit', self
        submit_button.setCheckable true
        connect submit_button , SIGNAL('clicked()'), SLOT("on_clicked()")

        exit_button = Qt::PushButton.new 'Exit', self
        exit_button.setCheckable true 
        connect exit_button  , SIGNAL('clicked()') , SLOT("on_cancelled()")


        vbox = Qt::VBoxLayout.new
        vbox.addWidget label
        vbox.addWidget name_label
        vbox.addWidget @email_field
        vbox.addWidget password_label
        vbox.addWidget @password_field
        vbox.addWidget message_label
        vbox.addWidget @message_field
        vbox.addWidget link_label
        vbox.addWidget @link_field
        vbox.addWidget @no_of_posts_shared 
        vbox.addWidget @drop_down_menu
        vbox.addWidget submit_button
        vbox.addWidget exit_button

        setLayout vbox
    end  

    def on_clicked
        params = Hash.new 

        params[:facebook_email] =   @email_field.text
        params[:facebook_password] =  @password_field.text
        params[:message] =  @message_field.text
        params[:link] =   @link_field.text
        params[:type_application] =   @drop_down_menu.currentText
        params[:bitly] = false 
        puts params

        @worker = Workers::Worker.new
        @worker.perform do
          puts "FBGR:entering the worker thread "
          FacebookSharing.new params , @no_of_posts_shared 
        end 


    end  


    def on_cancelled
         if !@worker.nil?
           puts "FBGR: killing worker thread"
           @worker.dispose(0.1)
       end 
       puts "FBGR: exiting the script"
       exit 

    end

end

app = Qt::Application.new ARGV
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

QtApp.new
app.exec