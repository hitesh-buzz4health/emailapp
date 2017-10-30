#!/usr/bin/env ruby

require'workers'

def ScrollBrowser(browser,num,delay)
    for i in 1..num 
        begin    
            browser.scroll.to :bottom
            puts "Scrolling for the " + i.to_s
            sleep delay
        
        rescue Exception => ex
        
            puts "An error of type #{ex.class} happened, message is #{ex.message}"
            #f << "\n"
            #f << doc_name.to_s + "|" + mob_num.to_s + "|" + email_id.to_s + "|" +  business_name.to_s + "|" + address + "|" + area.to_s + "|" + city.to_s + "|" + pin.to_s + "|" + keywords.to_s + "|" + button.href.to_s
            puts     "\n"
        end
    end
end

def load_spec(browser,f)
    count_docs = 0

    progress_fast = ProgressBar.create(:starting_at => 20, :total => nil)

    browser.lis(:class , "cntanr").each do |button|
        
        begin   
            progress_fast.increment
            #browser.link(:text, "Edit").click
            if button.visible? == false
                #puts button.href + " Not Visible, trying next user"
                next
            end
            f << "\n"
            puts "Processing a new item..."
            #button.click
            start = Time.now
            
            headless = Headless.new
            puts "Child RattleHead..."
            headless.start

#Selenium::WebDriver::Firefox::Binary.path = "/home/bliss/Downloads/tor-browser_en-US/Browser/firefox"
            #profile = Selenium::WebDriver::Firefox::Profile.new
            # profile.proxy = Selenium::WebDriver::Proxy.new :http => '46.101.129.227:3128', :ssl => '46.101.129.227:8080'


            child_bs = Watir::Browser.new :firefox 

            child_bs.goto button.attribute_value("data-href")


            # sec = browser.section(:id => "best_deal_div").section(:class => "jpbg").span(:class => "jcl")
            # if sec.visible?
            #   sec.click
            # end
            # if browser.windows.count > 2
            #   browser.windows[2..-1].each(&:close)
            # end
            #button.window(:title, POPUPWINDOW).close
            #clicking on the edit button 
            child_bs.link(:text ,"Edit This").click
            child_bs.link(:text,"Edit / Modify this business").click
            #browser.rab.window(:title, POPUPWINDOW).close
            child_bs.radio(:id, "rdoUser").set
            child_bs.form(:id => "cat").button(:class => "jbtn").click
            # sec = browser.section(:id => "best_deal_div").section(:class => "jpbg").span(:class => "jcl")
            # if sec.visible?
            #   sec.click
            # end
            business_name = child_bs.text_field(:id => "bus_name").value
            address = child_bs.text_field(:id => "bui_name").value + child_bs.text_field(:id => "street_name").value + child_bs.text_field(:id => "lan_name").value
            #Get info on this user
            area = child_bs.text_field(:id => "are_name").value
            city = child_bs.text_field(:id => "city_name").value
            pin =    child_bs.select_list.selected_options.map(&:text).first
            #getting contact information
            child_bs.link(:text =>"Contact Information").click
            doc_name = child_bs.text_field(:name => "contact_person_name[]").value
            mob_num = child_bs.text_field(:name => "mob_name[]").value
            landline_num = child_bs.text_field(:id => "lan_num[]").value
            email_id = child_bs.text_field(:name => "email_id[]").value
            website = child_bs.text_field(:name => "website").value

            begin

                child_bs.link(:text =>"View/Remove Keywords").click
                keywords = ""
                sleep 10
                child_bs.div(:class => "keyword").ul.lis.each do |keyword|
                    keywords = keywords + keyword.text
                end
            rescue Exception => ex
            puts "An error of type #{ex.class} happened, message is #{ex.message}"

            end 

            f << doc_name.to_s + "|" + mob_num.to_s + "|" + email_id.to_s + "|" +  business_name.to_s + "|" + address.to_s + "|" + area.to_s + "|" + city.to_s + "|" + pin.to_s + "|" + keywords.to_s + "|" +  button.attribute_value("data-href").to_s
            count_docs = count_docs + 1
            puts "Writing " + "'" + business_name.to_s + "' :" + count_docs.to_s 
            f << "\n"
            puts "Time taken to extract " + (Time.now - start).to_s + " seconds." 
            #browser.close
        rescue Exception => ex
            f<< "\n"
             puts "An error of type #{ex.class} happened, message is #{ex.message}"

            f << "An error of type #{ex.class} happened, message is #{ex.message}"
            #f << "\n"
            #f << doc_name.to_s + "|" + mob_num.to_s + "|" + email_id.to_s + "|" +  business_name.to_s + "|" + address + "|" + area.to_s + "|" + city.to_s + "|" + pin.to_s + "|" + keywords.to_s + "|" + button.href.to_s
            f << "\n"
            if child_bs != nil
                child_bs.close
            end
            next
        end
        if child_bs != nil
            child_bs.close
        end
        

    end
   return count_docs
end
def loadCity(city_link)
    #browser.input(:id => "bd_name")
  

    require 'watir'
    require 'watir-scroll'
    require 'headless'
    require 'date'
    require 'ruby-progressbar'
    begin
        progress_slow = ProgressBar.create(:starting_at => 20, :total => nil)
        puts "Opening Log X>!<!X"
        File.open("MasterLog.txt", "w+") do |log|
            begin
            headless = Headless.new
            puts "Initializing RattleHead..."
            headless.start


#Selenium::WebDriver::Firefox::Binary.path = "/home/bliss/Downloads/tor-browser_en-US/Browser/firefox"
            #profile = Selenium::WebDriver::Chrome::Profile.new
            #profile.proxy = Selenium::WebDriver::Proxy.new :http => '46.101.129.227:3128', :ssl => '46.101.129.227:8080'


            browser = Watir::Browser.new :firefox
            browser.goto city_link
            
            begin
            sec = browser.section(:id => "best_deal_div").section(:class => "jpbg").span(:class => "jcl")
            if sec.visible?
                sec.click
            end
            rescue
            end
            source_links = []
            source_links << city_link
            browser.ul(:class => "related-catg").wait_until_present
            browser.ul(:class => "related-catg").lis.each do |link|
                if link.text == "Also use Justdial for:"
                    break
                end
                source_links << link.a.href
            end
            count_links = 0
            source_links.each do |source_link|
                browser.goto source_link
                begin
                sec = browser.section(:id => "best_deal_div").section(:class => "jpbg").span(:class => "jcl")
                if sec.visible?
                    sec.click
                end
                rescue
                end

                


                pre_city = source_link.split("/")[source_link.split("/").size-3]
                pre_spec = source_link.split("/")[source_link.split("/").size-2]
                file_name =  pre_city + "_" + pre_spec

                if File.exists?('./data/just_dial/just_dial_data/'+file_name + ".csv") == true
                    next
                end
                ScrollBrowser(browser,100,1)
                items = browser.links(:text, "Edit").count/2

                log << "Doctors Fetched from : " + pre_city + " With Specialization " + pre_spec + "=" + items.to_s

                log << "\n"
                puts  "Doctors Fetched from : " + pre_city + " With Specialization " + pre_spec + "=" + items.to_s
                puts "\n"

                log << "Time: " + DateTime.now.to_s
                log << "\n"
                log << "Writing " + file_name
                log << "\n"
                puts "Writing " + file_name
                puts "\n"

                count_links = count_links + 1
                File.open('./data/just_dial/just_dial_data/'+file_name + ".csv","w+") do |f|
                    begin
                        docs_written = load_spec(browser,f).to_s
                        f << "\n"   
                        log << docs_written.to_s + " Doctors written"
                        log << "\n"
                        puts docs_written.to_s + " Doctors written"
                        puts "\n"
                    rescue
                    end

                end
                progress_slow.increment

            end
            rescue
            end

            browser.close
            headless.destroy
        end

    rescue Exception => ex
                 puts "An error of type #{ex.class} happened, message is #{ex.message}"
    end

end

line_num = 0
file = ARGV[0]
group = Workers::TaskGroup.new

File.open(file).each do |line|
    
     group.add(:max_tries => 10) do 
      puts "Worker Thread #{Thread.current.object_id} is starting"
      puts "Loading City: #{line_num += 1} #{line}"
      loadCity(line)
     end
end

group.run



group.tasks.each do |t|
  if t.failed? == true
     puts "Task failed"
     puts   t.exception  # The exception if one exists.
  end
end

puts "Script finished."
