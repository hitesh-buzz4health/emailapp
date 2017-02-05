#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)
root_path = "https://www.dermnetnz.org"
 credentials = Google::Auth::UserRefreshCredentials.new(
 client_id: "156404022533-kv0hntucj24bnhbderr5kstc195ihu2e.apps.googleusercontent.com",
 client_secret: "rzi6_TO-iHJwvmZwjR_E-x1-",
 scope: [
   "https://www.googleapis.com/auth/drive",
   "https://spreadsheets.google.com/feeds/",
 ],
 refresh_token: "1/BYLIVCaqF0YmO8ujY36tvzQMGzBI5fgxA0KF3BmkwnjFLV_ixSX3IDAxtS1GUta4")
 session = GoogleDrive::Session.from_credentials(credentials);0
spreadsheet = session.spreadsheet_by_key("1FvXbkf7UJwy_d8u4eSXRoU1zaHeAdzY0RbawH5zKVQc");0 
ws = spreadsheet.worksheets;0
count = 0
start_counter = 216549
File.open("master_dermanz.txt","a") do |master_file|
    File.readlines("dermanz.txt").each do |link|
        begin
            count = count + 1
            if start_counter > count
                puts "Skipping" + link
                next
            end

            puts "Processing " + link
            if link.match("/quizzes/") == nil
                puts "Not a quiz"
                next
            end
            doc = Nokogiri::HTML(open(link));0
            
            case_heading = doc.css("h1[class='with-breadcrumbs']").text
            num_of_images = doc.css("div[class='images'] a").count

            case_arr = []
            doc.css("div[class='images'] a").each do |image|
                
                case_arr<<{"image_src" => image.css("img")[0][:src]}
            end

            qna = {}
            num_of_questions = doc.css("div[class='quiz-question']").count

            num_of_questions.times do |count|
                qna[doc.css("div[class='quiz-question'] label")[count].text] = doc.css("div[class='quiz-answer']")[count].text.gsub("\n","").gsub("\t","")             
            end

            master_file << case_heading << "$$" << num_of_images << "$$" << case_arr << "$$" << num_of_questions << "$$" <<qna << "$$" << link <<"\n\n" 
            master_file << "**************************************"
            # ws[0][count,1] = case_heading
            # ws[0][count,2] = link;0
            # ws[0][count,3] = case_arr;0
            # ws[0].save;0
            puts "******************** " + count.to_s + " ******************** "   
        rescue Exception => e
            puts "caught exception #{e}! ! processing link" 
            #ws[0][count,6] = "#{e}"
            #ws[0].save;0   
        end

    end
end


