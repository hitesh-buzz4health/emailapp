class EmailsController < ApplicationController


def new
end

def create
end


def show

end




def send_email
	if params[:ref_ids]
	       @references = Reference.find(params[:ref_ids])
   respond_to do |format|
        format.html
        
    end

	 end


end

def finish_campaign
	
   MandrillHelper.send_email_bulk($Users, params[:subject], params[:template_name],
                                   params[:title], params[:description], params[:image_url], params[:action_url])
   redirect_to "/references"
end


end
