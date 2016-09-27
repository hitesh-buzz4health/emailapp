allText = Dir["#{Dir.pwd}/db/*.txt"]
allText.each do |textFile|
	puts "Reading file" + textFile
	textdata = File.read(textFile)
	new_contents = textdata.gsub("}{", "}$$${")
	# puts new_contents
	File.open(textFile, "w") {|file| file.puts new_contents }
end
