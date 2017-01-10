

class  GraphsController < ApplicationController


def index
  stats_data()
end 


 
 def stats_data()
   
     session = GoogleDrive::Session.from_config("config.json")
     output_spreadsheet = session.spreadsheet_by_key("1wV5NKZmPUiCI-COHoKdwDnLy_pwvzIY57Eq2IXdmQ9M").worksheets[0]



 end 



end
