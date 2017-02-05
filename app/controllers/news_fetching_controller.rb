
# removing once gem isntalled
require 'nokogiri'
require 'open-uri'
require "google_drive"


class NewsFetchingController < ApplicationController

 def index
 end 
  

 def post
	 credentials = Google::Auth::UserRefreshCredentials.new(
 client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
 client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
 scope: [
   "https://www.googleapis.com/auth/drive",
   "https://spreadsheets.google.com/feeds/",
 ],
 refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
 session = GoogleDrive::Session.from_credentials(credentials);0
	rss_spreadsheet = session.spreadsheet_by_key("1DlxONl2_wL6MCRVgwpEP4_T7HOEX3oJC-uEM5PuWFiQ").worksheets[0]
	output_news_feed = session.spreadsheet_by_key("1Lt8r3_9Y64JRlUGri3gDyW8qTAigDBvtqB3uhTJbzrU").worksheets[0]


	2.upto(10) do |item|

	      if rss_spreadsheet[item , 1].length == 0
	                puts "TNS: Empty Group found in sheet " + item.to_s 
	                next
	        end

		current_url = rss_spreadsheet[item,1]
	    puts current_url 
		page = Nokogiri::XML(open(current_url))

	    begin 
			page.css("item").each do | item |

	                      begin
	                        
		 					 link =item.css("link").text 
						 	 description =  item.css("description").text
						 	 description.gsub!(/(<[^>]*>)|\n|\t/s) {" "}

						    rescue Exception => e	        	
						           puts "TNS: caught exception while removing html tags #{e}! ohnoes!"
						    end 
							     
				        postSharingResult(output_news_feed , link  ,description  )
				        puts "TNS: Posting result on the excel"

	          end

		 rescue Exception => e	        	
				           puts "TNS: caught exception while Scrapping news #{e}! ohnoes!"
		  end 
		    
	  end

	 end 


	def postSharingResult(output_news_feed  , link  ,description )

	                 hashtags = ["#doctors20 " , "#doctors" ,"#medicalnews" ,"#buzz4health"]

		              present_row_no = output_news_feed.num_rows + 1 
		              output_news_feed[present_row_no ,1] = truncateDescirption(description).to_s + hashtags.sample 
		              output_news_feed[present_row_no ,2] =  "\n" + link
		              output_news_feed.save     
		         
	 end 

	def truncateDescirption( description )
	  if description.length > 95
	    return description[0 , 95] + "... "
	  end 	
	  return description 
	end 


end 