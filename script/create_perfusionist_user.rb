csv_text = File.read("data/LM-Posting.csv")
csv = CSV.parse(csv_text, :headers => false)

total_count = csv.count
isnext = true
count = 0 
u_name = ""
(1..total_count-1).each do |i|
    count = count + 1
    last2 = csv[i-1][0]
	last =  csv[i][0]
	if isnext == true && count == 2
	  isnext = false
	  u_name = last
	end
	if last.nil?
	  email = last2
	  pUser = PerfusionistUser.new
	  pUser.name = u_name
	  pUser.email = email
	  pUser.save!
	  count = 0
	  isnext = true
	end
end
