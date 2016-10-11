class UnsubscribesController < ApplicationController


  def new
    #redirect_to questions_path(:format => :mobile)
  end
  def create
    if params[:email] == ""
      flash[:notice] = "Please enter a valid email id"
      redirect_to "/unsubscribe"
      return  
    end
      
    u_check = Unsubscribe.where(:email => params[:email]).first
    if u_check.nil? == false
      flash[:notice] = "You have already been unsubscribed"
      redirect_to :root
      return
    end
    uns = Unsubscribe.new
    uns.email = params[:email]
    uns.reason = params[:reason]
    uns.save
    
    #If an existing user, set notification options
    user = User.where(:email => params[:email]).first
    if user.nil? == false
        user.notification_opts.inactive_emailer = false
        user.notification_opts.active_emailer = false
        user.save
    end
    
    flash[:notice] = "You have been unsubscribed from the mailing list"
    redirect_to :root    
  end

end
