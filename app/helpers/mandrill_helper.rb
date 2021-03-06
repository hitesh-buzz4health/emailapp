require 'mandrill'
module MandrillHelper


def self.send_email_bulk(users, subject, template_name,
                                   title, description, image_url, action_url,sender_domain)

  #mandrill = Mandrill::API.new ENV["SMTP_LOGIN_PASSWORD"]
  mandrill = Mandrill::API.new "bDcc2lKvRAmoIctJMLle4g"
  
  #Following from DGD
  #mandrill = Mandrill::API.new "WzZWJkSAhDBpgUjdeHjX4g"
  
  sender = "unknown"
  from = "unknown"
  if sender_domain.eql? "medtape" 
    sender = "hello@medtape.com"
    from = "Dr. Neha Sharma"
  end
  if sender_domain.eql? "doctorsgodigital"
    sender = "admin@doctorsgodigital.in"
    from = "Dr. Neena Sharma"
  end
  if sender_domain.eql? "buzz4health" 
    sender = "mailsupport@buzz4health.com"
    from = "Expert Panel at Buzz4health"

  end

  
  current_page = 0
  item_count = users.count
  puts "Starting to send email to " + item_count.to_s + " users"
  current_time = Time.now
  template_content = [{"name"=>"example name", "content"=>"example content"}]
  while item_count > 0
      
    #Just construct "to" and "merge_vars now and reset after each 200 users"

    recipients_temp = []
    merge_vars_arr = []
    users[(current_page * 200)..(200 * (current_page + 1))].each do |user|
      if user.Emails.size == 0
         next
       end

      if !user.nil? 
        breakfree = false
        user.Emails.each do |email|
          if Unsubscribe.where(:email => email).first.nil? == false
              breakfree = true
          end

        end
        if breakfree
         next
        end

        recipients_temp.push(MandrillHelper.getEmailReceipient(user.Emails[0],user.Name))
        merge_vars_arr.push({"rcpt"=>user.Emails[0],"vars"=>[{"name" => "Title", "content" => title},
                             {"name" => "description", "content" => description},
                             {"name" => "ImageUrl", "content" => image_url},
                             {"name" => "FNAME", "content" => user.Name},
                             {"name" => "ActionUrl", "content" => action_url}]})
          
      end        
    end
 

      
    begin
      message = {
         #"subject"=> "#{name}, we missed you on Buzz4health",
         "subject"=>subject,
         "from_email"=>sender,
         "from_name"=> from,
         "to"=> recipients_temp,
         "headers"=>{"Reply-To"=>sender},
         "merge"=>true,
         "preserve_recipients"=>false, 
         "merge_language"=>"mailchimp",
         "merge_vars"=>
              merge_vars_arr
        }
        #template_merge_vars =
        #    [{"name"=>"USER_NAME", "content"=>"Hitesh"}]  
        async = true
        result = mandrill.messages.send_template template_name, template_content, message,async
        puts "Mandrill email sent with code "+ result.to_s
    rescue Mandrill::Error => e
      # Mandrill errors are thrown as exceptions
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      # A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'    
      #raise
    end
    item_count-=200
    current_page+=1
  end

end 




def self.getEmailReceipients(email, name)
  mail_receipients = []
  mail_recipient = Hash.new
  mail_recipient["email"] = email
  mail_recipient["name"] = name
  mail_recipient["type"] = "to"
  mail_receipients.push(mail_recipient)
  return mail_receipients
end

def self.getEmailReceipient(email, name)

  mail_recipient = Hash.new
  mail_recipient["email"] = email
  mail_recipient["name"] = name
  mail_recipient["type"] = "to"
  return mail_recipient
end
end
