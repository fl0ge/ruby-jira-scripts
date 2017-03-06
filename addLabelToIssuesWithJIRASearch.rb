# Ruby script to add a label to all issues using a JQL Search query
# author: Florian Gerus

require 'net/http'
require 'net/https'
require 'uri'
require 'rubygems'
require 'json'

def add_label(http, login, password, fix_version, issue_id)
	add_label_request = Net::HTTP::Put.new("/rest/api/2/issue/#{issue_id}")
	add_label_request.basic_auth "#{login}", "#{password}"
	add_label_request.content_type = 'application/json'
	add_label_request.body = '{ "update" : { "labels": [ {"add": "'+"#{fix_version}"+'" } ] } }'

	add_label_response = http.request(add_label_request)
end

puts "JIRA URL (e.g. https://www.foobar.com/jira): "
jira_url = gets.chomp

puts "Login: "
login = gets.chomp

puts "Password (hidden): "
system 'stty -echo'
password = gets.chomp
system 'stty echo'

puts "Label to add: "
fix_version = gets.chomp

puts "JIRA query for the list of issues to be updated (JQL): "
jira_search = gets.chomp

jira_uri = URI.parse(jira_url)
http = Net::HTTP.new(jira_uri.host, jira_uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

updated_issues_count = 0

search_uri = URI.escape("/rest/api/2/search?jql=#{jira_search}&maxResults=200")
get_issues_request = Net::HTTP::Get.new(search_uri)
get_issues_request.basic_auth "#{login}", "#{password}"

get_issues_response = http.request(get_issues_request)
get_issues_json = JSON.parse(get_issues_response.body)
issues = get_issues_json['issues']

for issue in issues
	jira_issue_key = "#{issue['key']}"

	# Get issue
	get_issue_request = Net::HTTP::Get.new("/rest/api/2/issue/#{jira_issue_key}")
	get_issue_request.basic_auth "#{login}", "#{password}"
	
	get_issue_response = http.request(get_issue_request)

	get_issue_json = JSON.parse(get_issue_response.body)

	issue_id = get_issue_json['id']
	puts "Adding label #{fix_version} to issue #{jira_issue_key} (#{issue['fields']['summary']})"
	add_label http, login, password, fix_version, issue_id
	updated_issues_count += 1
end

puts "#{updated_issues_count} issues updated."
