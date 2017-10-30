
#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)

require'csv'
require'json'

class ExtractPhysicianSampleCsvFile



def initialize( path_to_dir)
users = Array.new 
fecthing_csv(path_to_dir , users)


end 

def dumping_data( users )
users.each do | item |

puts  item
ExternalDbUser.collection.insert_one(item)


end 

end

def fecthing_csv(path_to_dir , users)


CSV.foreach( path_to_dir) do |row|
user = Hash.new

if !row[0].nil?
user["practice"] = row[0]
end

if !row[1].nil?
user["address"] = row[1]
end 

if !row[3].nil?

user["city"] = row[3]
end

if !row[4].nil?
user["state"] = row[4]
end  


if !row[5].nil?
user["zip"] = row[5]
end  


if !row[6].nil?
user["county"] = row[6]
end
if !row[7].nil?
user["phone"] = row[7]
end
if !row[8].nil?
user["fax"] = row[8]
end
if !row[11].nil?
user["name"] = row[11]
end

if !row[12].nil?
user["email"] = row[12]
end
if !row[13].nil?
user["gender"] = row[13]
end
if !row[14].nil?
user["title"] = row[14]
end

if !row[15].nil?
user["specializations"] = row[15]
end

if !row[16].nil?
user["sic_code"] = row[16]
end

if !row[19].nil?
user["website"] = row[19]
end

if !user.empty?
user["country_code"] = "US"

user.to_json
users << user 
end
end 

dumping_data(users)
end 




end 

ExtractPhysicianSampleCsvFile.new ("../../data/PhysicianSample.csv")