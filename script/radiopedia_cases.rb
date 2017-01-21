#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)
session = GoogleDrive::Session.from_config("config.json")
spreadsheet = session.spreadsheet_by_key("1v6hKOYR3MI5Pv076cUwcbZtoA7uFJmWQRKUQlGlj9Z0") 
ws = spreadsheet.worksheets
File.open("master_radiopedia.txt","w") do |master_file|
    for count in 48..100
        fh = {}  
        modality_hash = []
        for row in 1..300
            begin
                link = ws[0][count*300+row+1,10]
                puts "Processing" + link
                puts "****************************** " + (count*300+row+1).to_s + " ******************"
                doc = Nokogiri::HTML(open(link))    
                begin
                    system = doc.css("div[class~='meta-item-systems']").text
                    tags = doc.css("div[class~='meta-item-tags']").text
                rescue
                    puts "Error finding tags or system"
                end
                
                begin
                
                    presentation = doc.css("div[id='case-patient-presentation'] div p").text
                rescue
                     ws[0][count*300+row+1,13] = ws[0][count*300+row+1,13] + "$" + "Unable to find case presentation"
                     puts "Unable to find case presentation"   
                     presentation = "Unable to find case presentation"
                end
                begin
                    patient_data = doc.css("div[id='case-patient-data']").text    
                rescue
                    ws[0][count*300+row+1,13] = ws[0][count*300+row+1,13] + "$" + "Unable to find patient data"
                    puts "Unable to find patient data"
                    patient_data = "Unable to find patient data"
                end
                begin
                    question = session.find("p[class='q']").text
                    session.click_link("Show Answer").text
                    answer = session.find("p[class='a']").text
                
                rescue
                    puts "Q & A section not found for " + link
                     question = "Q & A section not found"
                     answer = question
                end
                studies = doc.css("div[class~='case-study']")
                studies.each do |study|
                    study_desc = study.css("div[class~='study-desc'] h2").text
                    study_finding = study.css("div[class~='study-findings'] p").text
                    study_modalities = "https://radiopaedia.org/" + study[:'data-study-stacks-url']
                    modality_json = Nokogiri::HTML(open(study_modalities)).text
                    hash_modality = {}
                    hash_modality["study_desc"] = study_desc
                    puts "Study desc: " +  hash_modality["study_desc"]
                    hash_modality["study_finding"] = study_finding
                    hash_array = JSON.load modality_json
                    hash_modality["study_modalities_json"] = hash_array
                    modality_hash.push(hash_modality)    
                end
                description = ""
                doc.css("div[id='case-discussion'] p").each do |des|
                    description = description + des.text + "\n "
                end

                num_related_links = doc.css("div[id='case-related-articles'] ul li a").count
                related_links = {}
                doc.css("div[id='case-related-articles'] ul li a").each do |rl|
                    related_links[rl.text] = rl[:href]
                end    
                # ws[0][count*300+row+1,1] = question
                # ws[0][count*300+row+1,2] = answer
                # ws[0][count*300+row+1,3] = presentation
                # ws[0][count*300+row+1,4] = patient_data
                # ws[0][count*300+row+1,5] = studies.count
                # #ws[0][row+1,6] = modality_hash.to_s
                # ws[0][count*300+row+1,7] = description
                # ws[0][count*300+row+1,8] = num_related_links
                # ws[0][count*300+row+1,9] = related_links.to_s
                # ws[0][count*300+row+1,11] = system
                # ws[0][count*300+row+1,12] = tags
                # ws[0].save
                master_file << question << "$$$" << answer << "$$$" << presentation << "$$$" << patient_data << "$$$" << studies.count << "$$$" << description << "$$$" << num_related_links << "$$$" << related_links.to_s << "$$$" << system << "$$$" << tags << "\n\n"
                master_file <<"**************************************" <<"\n\n\n"            
            rescue Exception => e
                 puts "caught exception #{e}! !"
                ws[0][count*300+row+1,13] = ws[0][count*300+row+1,13] + "$" +"caught exception #{e}! !"
            end        
        
        end
        File.open("modality.txt"+ count.to_s, 'w') do |file|
        
            fh[link] = modality_hash
            file.write(fh)
        end
    end
end

