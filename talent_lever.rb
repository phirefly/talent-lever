require 'faraday'
require 'json'
require 'date'

raise "You need to pass in a key through the API_KEY environment variable when running this script" unless ENV['API_KEY']
raise "You need to pass in a key through the CANDIDATE_ID environment variable when running this script" unless ENV['CANDIDATE_ID']

conn = Faraday.new(:url => 'https://api.lever.co/v1') do |faraday|
  faraday.request  :url_encoded
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

api_key = ENV['API_KEY']
candidate_id = ENV['CANDIDATE_ID']
conn.basic_auth(api_key, "")

response = conn.get "/v1/candidates/#{candidate_id}", { :username => api_key }

#Get the application id from the response
response_hash = JSON.parse(response.body)
puts response_hash['data'].keys

puts '***'
candidate_applications = response_hash['data']['applications']
puts candidate_applications
puts '***'

#Make a request to the api about application
application_response = conn.get "/v1/candidates/#{candidate_id}/applications/#{candidate_applications.first}", { :username => api_key }
puts '***'
application = JSON.parse(application_response.body)['data']
puts application.keys

created_at_seconds = (application['createdAt'].to_f / 1000).to_s
created_at_time = Date.strptime(created_at_seconds, '%s')
puts created_at_time.strftime("Started on %m/%d/%Y at %I:%M%p")

puts '***'

#All candidates
all_candidates = conn.get "/v1/candidates", { :username => api_key }
#Take all of their ids and store them

candidate_ids = []
candidates = JSON.parse(all_candidates.body)['data']
puts "*"*50
puts "last candidate: #{candidates.last}"
puts "*"*50

candidates.each do |candidate|
  candidate_ids << candidate['id']
end

# puts "*"*50
# puts "candidate ids: #{candidate_ids}"
# puts "*"*50

#Look up all applications
candidate_ids.each do |id|
  application_candidate_response = conn.get "/v1/candidates/#{id}/applications", { :username => api_key }
  application = JSON.parse(application_candidate_response.body)['data'].first
  # puts application
  puts "Created at: #{application['createdAt']}"
  puts "Archived at: #{application['archived']['archivedAt']}"
  puts '***'
end

#Calculate the averages



