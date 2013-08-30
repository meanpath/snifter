require "bundler/setup"
require "sinatra"
require 'hipchat'
require 'json'



# incoming format
#
# {"name":"JobName",
#  "url":"JobUrl",
#  "build":{"number":1,
# 	  "phase":"STARTED",
# 	  "status":"FAILED",
#           "url":"job/project/5",
#           "full_url":"http://ci.jenkins.org/job/project/5"
#           "parameters":{"branch":"master"}
# 	 }
# }
def buildlink(link)
  "<a href=\"#{link}/console\">console logs</a>"
end

happy_igor = ["No beating for Igor!",
              "I haven't been this happy since Master let me practice surgery on the visitor who spoke with his mouth full.",
              "May choirs of angels sing you to your rest, sweet master."]

sad_igor = ["Whip me, it's probably my fault.",
            "Calloo callay, fire and brimstone upon the evildoers!",
            "Should I bring your spiked gauntlets, sir?"]

secret_root = ENV['SECRET_ROOT']

post "/#{secret_root}/adam" do
  client = HipChat::Client.new(ENV['SECRET_API_TOKEN'])
  room = client[ENV['room']]
  room.send("AdamCEO", params[:message])
end

post "/#{secret_root}" do
  raw = request.env["rack.input"].read
  parsed = JSON.parse(raw)
  client = HipChat::Client.new(ENV['API_TOKEN'])
  room = client[ENV['room']]
  build = parsed['build']
  # room.send('Igor', "debugging: #{parsed.inspect}")

  if %w{STARTED COMPLETED}.include?(build['phase'])
    # don't care: just want finished
    return "OK"
  end
  return "OK" # disabling untill we fix it
  case build['status']
  when 'FAILURE'
    room.send('Igor', "@mark @eric Igor regrets that a #{parsed['name']} build failed (#{buildlink(build['full_url'])}).
#{sad_igor.sample}", :color => 'red')
  when 'SUCCESS'

    room.send('Igor', "Igor is so happy: #{parsed['name']} is green. #{happy_igor.sample} (#{buildlink(build['full_url'])}).", :color => 'green')
  else
    room.send('Igor', "Stupid Igor is not clever enough for your command: #{parsed.inspect}", :color => 'purple')
  end

end
