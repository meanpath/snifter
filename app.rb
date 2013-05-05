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
  puts parsed.inspect
  parsed.inspect
end

get "/" do
  "Hello world!"
end
