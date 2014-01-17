require 'net/http'
require 'net/https'
require 'nokogiri'
require 'twilio-ruby'


#TODO: Put your account id and auth token from Twilio here.
@account_sid = ''
@auth_token = ''

def get_availability_ssl(crn, term)

  http = Net::HTTP.new("selfservice.mypurdue.purdue.edu", 443)
  http.use_ssl = true
  resp, result = http.get("/prod/bwckschd.p_disp_detail_sched?term_in=#{term}&crn_in=#{crn}")
  page = Nokogiri::HTML.parse(resp.body)

  #get class name
  class_name = page.css("table.datadisplaytable")[0].css("th")[0].content
  
  #get open seats 
  data_table = page.css("table.datadisplaytable")[1]
  row = data_table.css("tr")[1]
  remaining = row.css("td")[2].content.to_i
  if remaining > 0
    push_message class_name, remaining
  end

end

def push_message(class_name, open_slots)
	@client = Twilio::REST::Client.new @account_sid, @auth_token

	@client.account.messages.create({
		:from => '', #TODO: Be sure to change these values to the ones corresponding with your account!!
		:to => '',
		:body => "There are #{open_slots} open seats in #{class_name}! Go register!",
	})
end

course_number = ARGV[0] ? ARGV[0] : "53454"
term_number = ARGV[1] ? ARGV[1] : "201410"

if(!ARGV[0] || !ARGV[1])
  puts "Usage: ruby watch.rb crn term"
  puts "(Term is 201410 for Fall 2014)"
else
  get_availability_ssl(course_number, term_number)
end
