#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)
root_path = "http://www.ultrasoundcases.info/"
session = GoogleDrive::Session.from_config("config.json");0
spreadsheet = session.spreadsheet_by_key("1uU_oaoaLh-93GXSkU1sBdutHYECU6c_WdhgWTbNLXA4");0 
ws = spreadsheet.worksheets;0
count = 0
start_counter = 20754

File.open("master_ultrasound_2.txt","w") do |master_file|
    File.readlines("urls.out").each do |link|
        begin
            count = count + 1
            if start_counter > count
                puts "Skipping" + link
                next
            end
            puts "Processing " + link
            doc = Nokogiri::HTML(open(link));0
            case_hash = {}
            case_heading = doc.css("div[id='divContentInner'] h1").text

            doc.css("table tr").each do |row|
                
                    arr_images = []
                    arr_swf = []    
                    case_title = row.css("p[class='case-title']").text
                    image_modalities = row.css("div[class='MediaSlide']")


                    #detect image or swf
                    image_found=true
                    begin
                        row.css("div[class='MediaSlide']")[0].css("img")[0][:src]
                        puts "Image set found"
                    rescue
                        puts "SWF set found"
                        image_found = false
                    end

                    image_modalities.each do |modality|
                        begin
                            image = {}
                            if image_found == true
                                image["source"]=modality.css("img")[0][:src]
                                image["caption"] = modality.css("div")[1].text
                                arr_images << image 
                            else
                                image["source"]= root_path + modality.css("object param[name='movie']")[0][:value]
                                image["caption"] = modality.css("div")[1].text
                                arr_swf << image
                            end
                       rescue Exception => e
                            puts "caught exception #{e}! ! processing row"

                        end    

                    end
                    if image_found == true
                        case_hash[case_title + "$IMAGES$"] = arr_images;0
                    else
                        case_hash[case_title + "$SWF$"] = arr_swf;0

                    end
             
            end
            # ws[0][count,1] = case_heading
            # ws[0][count,2] = link;0
            # ws[0][count,3] = case_hash;0
            # ws[0].save;0
            master_file << case_heading << "$$" << link << "$$" << case_hash
            master_file << "\n\n"

            puts "******************** " + count.to_s + " ******************** "   
        rescue Exception => e
            puts "caught exception #{e}! ! processing link" 
            ws[0][count,6] = "#{e}"
            ws[0].save;0   
        end

    end
end


