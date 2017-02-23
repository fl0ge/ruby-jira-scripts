# Ruby script to add a fix version by name to all issues using a JQL Search query
# author: Florian Gerus

require 'net/http'
require 'net/https'
require 'uri'
require 'rubygems'
require 'json'

def update_fix_version(http, login, password, fix_version, issue_id)
	update_fix_version_request = Net::HTTP::Put.new("/rest/api/2/issue/#{issue_id}")
	update_fix_version_request.basic_auth "#{login}", "#{password}"
	update_fix_version_request.content_type = 'application/json'
	update_fix_version_request.body = '{ "update" : { "fixVersions": [	{"add":	{"name": "'+"#{fix_version}"+'" }}]}}'

	update_fix_version_response = http.request(update_fix_version_request)
end

puts "JIRA URL (e.g. https://www.foobar.com/jira): "
jira_url = gets.chomp

puts "Login: "
login = gets.chomp

puts "Password (hidden): "
system 'stty -echo'
password = gets.chomp
system 'stty echo'

puts "Fix version to add: "
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
	puts "Adding fixVersion #{fix_version} to issue #{jira_issue_key} (#{issue['fields']['summary']})"
	update_fix_version http, login, password, fix_version, issue_id
	updated_issues_count += 1
end

puts "#{updated_issues_count} issues updated."
