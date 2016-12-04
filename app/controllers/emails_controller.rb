class EmailsController < ApplicationController


def new
end

def create
end


def show

end




def send_email


  if params[:delete_selected]
    
    if params[:ref_ids]

          @references = $Saved
          @references.any_in(:_id => params[:ref_ids]).destroy_all


     end
      redirect_to "/references"

  else
  	if params[:ref_ids]
  	       @references = Reference.find(params[:ref_ids])
     respond_to do |format|
          format.html
          
      end

  	 end
  end

end

def finish_campaign
	
   MandrillHelper.send_email_bulk($Users, params[:subject], params[:template_name],
                                   params[:title], params[:description], params[:image_url], params[:action_url])
   
   users = Hash.new
   puts "Sent email to " + $Users.count.to_s
   $Users.each do |user|
    users[user.Name] = user.Emails[0] if user.Emails.size > 0
   end
   h = History.new
   h.list = users
   h.name = params[:profile_name]
   h.subject = params[:subject]
   h.cta = params[:action_url]
   h.count = $Users.count
   h.created_at = Time.now
   h.save



   redirect_to "/histories"
end


end
