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
def buildlink(link, text)
  "<a href=\"#{link}\">#{text}</a>"
end

post '/' do
  raw = request.env["rack.input"].read
  parsed = JSON.parse(raw)
  client = HipChat::Client.new(ENV['API_TOKEN'])
  room = client[ENV['room']]
  build = parsed['build']
  room.send('Igor', "debugging: #{parsed.inspect}")

  if %w{STARTED COMPLETED}.include?(build['phase'])
    # don't care: just want finished
    return "OK"
  end

  case build['status']
  when 'FAILED'
    room.send('Igor', "Igor regrets that a #{parsed['name']} build failed on branch #{build['parameters']['branch']} #{buildlink(build['full_url'], build['full_url'])}
Whip me, it's my fault probably.", :color => 'red')
  when 'SUCCESS'

    room.send('Igor', "Igor is so happy: branch #{build['parameters']['branch']} of #{parsed['name']} is green. (#{buildlink(build['full_url'], build['full_url'])}).")
  else
    room.send('Igor', "Stupid Igor is not clever enough for your command: #{parsed.inspect}")
  end

end
