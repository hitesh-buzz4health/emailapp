class ThirdPartyVisitorsController < ApplicationController





def index
    @visitorInmonth = {}
    ThirdPartyVisitor.where(:created_at.gte => (Date.today.prev_month.beginning_of_month)).order_by(:created_at, :desc).each do |s|
      if @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")].nil?
        @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")] = Hash.new(0)
      end
      @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")]["count"] += 1
      
      if @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")]["country"] == 0
        @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")]["country"] =  s.country_code
      else
        @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")]["country"] = @visitorInmonth[s.created_at.in_time_zone("Chennai").strftime("%d-%b-%Y")]["country"] + ", " + s.country_code
      end
      
    end
	
end

def send_blank_gif
  send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
end
 
# Then this can be used in an action like so:
def track_visitor

  if !params[:vid].nil? && !params[:cid].nil?
  	@visitor = ThirdPartyVisitor.where(:visitor_id => params[:vid],:campaign_id => params[:cid]).first
    if !@visitor.nil?
  	  @visitor.count = @visitor.count + 1
      if !params[:cc].nil? && @visitor.country_code.nil?
        @visitor.country_code = params[:cc]
      end  
    else	
  	  @visitor = ThirdPartyVisitor.create(:visitor_id => params[:vid],:campaign_id => params[:cid],:country_code => params[:cc])
  	end
  else
  	@visitor = ThirdPartyVisitor.create(:campaign_id => params[:cid],:country_code => params[:cc])
  end
  @visitor.save!
  # Now send a blank image back.
  send_blank_gif
end

end
