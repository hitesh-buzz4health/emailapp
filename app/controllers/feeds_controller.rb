
class FeedsController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

	def create
		credentials = Google::Auth::UserRefreshCredentials.new(
		client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
		client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
		scope: [
		   "https://www.googleapis.com/auth/drive",
		   "https://spreadsheets.google.com/feeds/",
		],
		refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
		session = GoogleDrive::Session.from_credentials(credentials);0
		spreadsheet = session.spreadsheet_by_key("1xGYDA9bmHUePZj-T6GLN3j5GfOKQuiMNIxDRFqhjFd0") 
		ws = spreadsheet.worksheets
		ws[0][ws[0].num_rows+1,1] = params[:text]
		ws[0].save
	 	respond_to do |format|
	    format.json{
	      render :json => {:status => "OK", :message => "Writing " + params[:text]}
	    }

	  end
	end

end