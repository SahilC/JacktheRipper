require 'net/http'
require 'json'
puts "8tracks mix downloader v1.0"
puts "Input the full URL to the 8tracks mix"
mixurl=gets.chomp
path=mixurl[18..-1]
user=mixurl[19..-1][/([a-zA-Z0-9_]*)/]
mixesurl='http://8tracks.com/users/'+user+'/mixes.jsonp?api_key=b5de95d329b4cbfc3605a3c46072b8601b997c5b&per_page=300'
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
url = 'http://8tracks.com/sets/460486803/play.jsonp?mix_id='+resultr["mixes"][i]["id"].to_s()+'&api_key=b5de95d329b4cbfc3605a3c46072b8601b997c5b'
resp = Net::HTTP.get_response(URI.parse(url))
data = resp.body
result=JSON.parse(data)
while !result["set"]["at_end"] do
	puts result["set"]["track"]["name"]+"-"+result["set"]["track"]["performer"]
	start=result["set"]["track"]["url"][/http:\/\/(([a-zA-Z0-9]*)\.([a-zA-Z0-9]*))*/]
	index=start.length
	start=start[7..-1]
	file=result["set"]["track"]["url"][index..-1]
	Net::HTTP.start(start) do |http|
	   respr = http.get(file)
   	open(result["set"]["track"]["name"]+"-"+result["set"]["track"]["performer"]+"."+result["set"]["track"]["url"][-3..-1], "wb") do |file|
        	file.write(respr.body)
   	end
	end
	puts "Done."
	url = 'http://8tracks.com/sets/460486803/next.jsonp?mix_id='+resultr["mixes"][i]["id"].to_s()+'&api_key=b5de95d329b4cbfc3605a3c46072b8601b997c5b'
	resp = Net::HTTP.get_response(URI.parse(url))
	data = resp.body
	result=JSON.parse(data)
end