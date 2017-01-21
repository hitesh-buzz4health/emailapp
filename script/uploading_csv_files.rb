
#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)

require'csv'
require'json'

class ExtractCsvFiles



	   def initialize( path_to_dir)
	     	users = Array.new 
	        fecthing_csv(path_to_dir , users)


	   end 

		def dumping_data( users )
			users.each do | item |
		       
		     puts  item
		     Reference.collection.insert_one(item)

		     
			end 

		end

		def fecthing_csv(path_to_dir , users)


			CSV.foreach( path_to_dir) do |row|
				user = Hash.new
		 
			         if !row[0].nil?
					     user["Name"] = row[0]
				    end
		              
		            if !row[1].nil?
					user["Phones"] = row[1]
			        end 

				  	if !row[2].nil?

		             user["Emails"] = row[2]
		            end

			          if !row[8].nil?
						user["Specialization"] = row[8]
				      end  
		               
		           
			        if !row[7].nil?
						user["PinCode"] = row[7]
				     end  
		                  
		             
                    if !row[4].nil?
						user["Address"] = row[4]
				    end

				   if !user.empty?
		             user["ReferenceName"] = "Just Dial"

				        user.to_json
				        users << user 
				   end
		    end 
		  
		   dumping_data(users)
		end 




end 

ExtractCsvFiles.new ("/home/sonal/sonal/ruby/final/one.csv")