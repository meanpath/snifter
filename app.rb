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

post '/' do
  raw = request.env["rack.input"].read
  parsed = JSON.parse(raw)
  client = HipChat::Client.new(ENV['API_TOKEN'])
  room = client[ENV['room']]
  build = parsed['build']
  case build['status']
  when 'FAILED'
    room.send('Igor', "Igor regrets that a build failed on branch #{build['parameters']['branch']} (#{build['full_url']}). Whip me, it's my fault probably.", :color => 'red')
  else
    room.send('Igor', "Stupid Igor is not clever enough for your command: #{parsed.inspect}")
  end

end

get "/" do
  "Hello world!"
end
