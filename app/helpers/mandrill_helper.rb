module MandrillHelper
    def send_template( user_id, email, name, num_of_comments, credit_points, agrees,
                                      user_avatar, subject, template_name,
                                      title, description, image_url, action_url)
      begin
        profile_link = "http://#{Group.first.domain}/" + "users/#{user_id}"
        mandrill = Mandrill::API.new ENV["SMTP_LOGIN_PASSWORD"]
        #template_name = "active-retargeting"

        template_content = [{"name"=>"example name", "content"=>"example content"}]
        recipients = NotifierMandrill.getEmailReceipients(email, name)
        message = {
         #"subject"=> "#{name}, your weekly stats are here",
         "subject"=>subject,
         "from_email"=>"mailsupport@buzz4health.com",
         "from_name"=> "Buzz4health",
         "to"=> recipients,
         "headers"=>{"Reply-To"=>"mailsupport@buzz4health.com"},
         "merge"=>true,
         "merge_language"=>"mailchimp",
         "global_merge_vars"=>[{"name"=>"UserProfile", "content"=>profile_link},
                                {"name" => "NumOfComments", "content"=>num_of_comments},
                                {"name" => "CreditPoints", "content" => credit_points},
                                {"name" => "TotalAgrees", "content" => agrees},
                                {"name" => "UserAvatar", "content" => user_avatar},
                                {"name" => "Title", "content" => title},
                                {"name" => "Description", "content" => description},
                                {"name" => "ImageUrl", "content" => image_url},
                                {"name" => "ActionUrl", "content" => action_url}],
         "merge_vars"=>
              [{"rcpt"=>email,
                "vars"=>[{"name"=>"FNAME", "content"=>name}]}]
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
    end






end