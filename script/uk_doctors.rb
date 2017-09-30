require 'open-uri'
require 'workers'
require 'nokogiri'



def routine(f,link,count)

    begin
        #encoded_url = URI.encode(link)
        #link = URI.parse(encoded_url)    
        #link = "http://privatehealth.co.uk/doctors-and-health-professionals/"

        doc = Nokogiri::HTML(open(link.strip));0
#            puts "Opened"
        doc_name = doc.css("h1[class='page_title']").text.gsub("\n","")
        specialty = doc.css("span[itemprop='MedicalSpecialty']").text
        location = doc.css("span[itemprop='addressLocality']").text.gsub("\n","")
        phone = doc.css("span[class='revealTelVal']").text
        email = doc.css("a[class~='email_convert']").text.gsub(" (dot) ",".").gsub(" (at) ","@").gsub("\n","").strip
        if email.eql?("") == true
                puts  "This link doesnt have a doctor" + count.to_s
#               puts link
            
        else
            country = "UK"
            count = count + 1
            puts  count.to_s + "====>" + doc_name + "|" << specialty + "|" + location + "|" + phone + "|" + email + "|" + country + "\n"
            f.flock(File::LOCK_EX)
            f <<doc_name << "|" << specialty << "|" << location << "|" << phone << "|" << email << "|" << country << "\n"
        end
    rescue Exception => e
        puts "#{e}: " + link 
    end

end 


# Initialize a worker pool.
pool = Workers::Pool.new(:on_exception => proc { |e|
  puts "A worker encountered an exception: #{e.class}: #{e.message}"
})



File.open("UKDoctors.txt", "w+") do |f|
    count = 0
    File.readlines("urls.out").each do |link|
        pool.perform do
            count = count + 1
            routine(f,link, count)
        end
    end
    # Wait up to 30 seconds for the workers to cleanly shutdown (or forcefully kill them).
    pool.dispose(30) do
      puts "Worker thread #{Thread.current.object_id} is shutting down."
    end
end
