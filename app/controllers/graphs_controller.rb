

class  GraphsController < ApplicationController


def index
  stats_data()
end 


 
 def stats_data()
   
      credentials = Google::Auth::UserRefreshCredentials.new(
 client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
 client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
 scope: [
   "https://www.googleapis.com/auth/drive",
   "https://spreadsheets.google.com/feeds/",
 ],
 refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
 session = GoogleDrive::Session.from_credentials(credentials);0
     output_spreadsheet = session.spreadsheet_by_key("1wV5NKZmPUiCI-COHoKdwDnLy_pwvzIY57Eq2IXdmQ9M").worksheets[0]



 end 



end
