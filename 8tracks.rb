require 'net/http'
require 'json'
puts "Jack The Ripper"
puts "Input the full URL to the 8tracks mix"
mixurl=gets.chomp
xApiKey = "b5de95d329b4cbfc3605a3c46072b8601b997c5b"
if(mixurl[0..4].eql? "https") then
	path=mixurl[19..-1]
	user=mixurl[20..-1][/([a-zA-Z0-9_-]*)/]
else
	path=mixurl[18..-1]
	user=mixurl[19..-1][/([a-zA-Z0-9_-]*)/]
end
mix=path[user.length+2..-1]
mixesurl='http://8tracks.com/users/'+user+'/mixes.jsonp?api_key='+ xApiKey +'&per_page=300'
respr = Net::HTTP.get_response(URI.parse(mixesurl))
datar = respr.body
resultr=JSON.parse(datar)
i=0
while i<resultr["mixes"].length do
	pathr=resultr["mixes"][i]["path"]
	if pathr.eql? path then
		break
	end
	i+=1
end
url = 'http://8tracks.com/sets/460486803/play.jsonp?mix_id='+resultr["mixes"][i]["id"].to_s()+'&api_key='+xApiKey
resp = Net::HTTP.get_response(URI.parse(url))
data = resp.body
result=JSON.parse(data)
directory_name = Dir::pwd + "/" + mix
if(!File.directory?(directory_name)) then
	Dir::mkdir(directory_name)
end
Dir.chdir(directory_name)
while !result["set"]["at_end"] do
	puts result["set"]["track"]["name"]+"-"+result["set"]["track"]["performer"]
	start=result["set"]["track"]["url"][/http:\/\/(([a-zA-Z0-9]*)\.([a-zA-Z0-9]*))*/]
	index=start.length
	start=start[7..-1]
	file=result["set"]["track"]["url"][index..-1]
	if(!File.exist?(result["set"]["track"]["name"]+"-"+result["set"]["track"]["performer"]+"."+result["set"]["track"]["url"][-3..-1])) then
		Net::HTTP.start(start) do |http|
	   	respr = http.get(file)
	   	begin
   	   	open(result["set"]["track"]["name"]+"-"+result["set"]["track"]["performer"]+"."+result["set"]["track"]["url"][-3..-1], "wb") do |file|
       		file.write(respr.body)
   	   		end
   	   	rescue Exception => e
   	   		puts e
   	   	end
	    end
	end   
	puts "Done."
	url = 'http://8tracks.com/sets/460486803/next.jsonp?mix_id='+resultr["mixes"][i]["id"].to_s()+'&api_key='+xApiKey
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	result=JSON.parse(data)
end
