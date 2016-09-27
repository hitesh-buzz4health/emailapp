#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= ('development')

require File.expand_path("../../config/environment", __FILE__)

class ExtractDetail 
  require 'spreadsheet' 
  
  def extract_from_data (fileName, excelName)
    book = Spreadsheet::Workbook.new
    @seenArray = Array.new
    rowIterator=0
    sheet1 = book.create_worksheet
    row = sheet1.row(rowIterator)
    row.replace ["Email","Phones","ReferenceSpecialization","ReferenceEmail","ReferenceName","ReferenceId","Name","isRefDoctor"]
    rowIterator+=1; 
    if fileName.eql? "all"
      puts "getting file from currect dir"
      allText = Dir["#{Dir.pwd}/**/*.txt"]
      puts allText
      allText.each do |textFile|
        puts textFile
        data = File.read(textFile)
        rowIterator=extract_from_String(data,sheet1,rowIterator)  
      end
    else
        data=File.read(fileName)
    end
    extract_from_String(data,sheet1,rowIterator)
    if excelName=~/\.xls$/
      book.write excelName 
    else
      book.write excelName +'.xls'
    end
  end

  def extract_from_String(processingString, sheet1, rowIterator)
    # data = File.read(inputFileName)
    temp= processingString.to_s

    array = temp.split("$$$")
    begin
          array.uniq! { |element| [eval(element)["ReferenceEmail"]+eval(element)["Name"]]}

      
    rescue Exception => e
      
    end
    row = sheet1.row(rowIterator)
    row.push("User Email")
    row.push("Phones")
    row.push("Reference Specialization")
    row.push("Reference Email")
    row.push("Reference Name")
    row.push("Reference Id")
    row.push("User Name")
    row.push("Is Refernce Doctor")
    rowIterator=rowIterator+1;
    array.each do |dataSet|
      begin
         hashPair = eval(dataSet)
         
         if !@seenArray.include? hashPair["ReferenceEmail"]+hashPair["Name"]
            @seenArray.push(hashPair["ReferenceEmail"]+hashPair["Name"])
            hashPair.each_pair { |key, value| 
              if value.kind_of?(Array)
                row.push(value.join(" "))
              else
                row.push(value)
              end
                }
                ref_data = Reference.new
                ref_data.emails = hashPair["Emails"]
                ref_data.phones = hashPair["Phones"]
                ref_data.ReferenceSpecialization = hashPair["ReferenceSpecialization"]
                ref_data.ReferenceName = hashPair["ReferenceSpecialization"]
                ref_data.ReferenceEmail = hashPair["ReferenceName"]
                ref_data.ReferenceId = hashPair["ReferenceId"]
                ref_data.Name = hashPair["Name"]
                ref_data.IsRefDoctor = hashPair["isRefDoctor"]
                ref_data.save
                puts "Saved a Mongo record"
                puts "New Mongo count => " + Reference.count_to_s




         end    
         rowIterator=rowIterator+1;
    
       
     rescue Exception => e
     rowIterator=rowIterator+1;
     puts "Error dealing with" + hashPair.to_s

         end
  
     end
    rowIterator
  end
end


#give the string form which u want to extract the data, it will create a excel in same folder in which project is there with data, every time u run the
#script it will overite the excel file with the same name
# sample command- ruby extract_detail.rb inputfile excelname
inputFileName = ARGV[0]
excelFileName = ARGV[1]
puts inputFileName + " "+ excelFileName

obj = ExtractDetail.new
obj.extract_from_data(inputFileName,excelFileName)


# allText = Dir["#{Dir.pwd}/**/*00*.txt"]
# allText.each do |textFile|
#   puts "Reading file" + textFile
#   textdata = File.read(textFile)
#   new_contents = textdata.gsub("},{", "}$$${")
#   # puts new_contents
#   File.open(textFile, "w") {|file| file.puts new_contents }
# end




