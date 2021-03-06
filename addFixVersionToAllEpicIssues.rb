# Ruby script to add a fix version by name to an Epic, its Stories and all the Subtasks (acceptance tests or other subtasks)
# author: Florian Gerus

require 'net/http'
require 'net/https'
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

puts "JIRA Epic key that needs to be updated along with the stories and its subtasks: "
jira_epic_key = gets.chomp

jira_uri = URI.parse(jira_url)
http = Net::HTTP.new(jira_uri.host, jira_uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

updated_issues_count = 0

get_epic_request = Net::HTTP::Get.new("/rest/api/2/issue/#{jira_epic_key}")
get_epic_request.basic_auth "#{login}", "#{password}"

get_epic_response = http.request(get_epic_request)

get_epic_json = JSON.parse(get_epic_response.body)

epic_id = get_epic_json['id']
epic_name = get_epic_json['fields']['summary']
puts "Adding fixVersion #{fix_version} to Epic #{jira_epic_key} (#{epic_name})"

update_fix_version http, login, password, fix_version, epic_id
updated_issues_count += 1

get_stories_request = Net::HTTP::Get.new("/rest/api/2/search?jql='Epic%20Link'%3D#{jira_epic_key}")
get_stories_request.basic_auth "#{login}", "#{password}"

get_stories_response = http.request(get_stories_request)

get_stories_json = JSON.parse(get_stories_response.body)

stories = get_stories_json['issues']

for story in stories
	jira_issue_key = "#{story['key']}"

	# Get issue
	get_issue_request = Net::HTTP::Get.new("/rest/api/2/issue/#{jira_issue_key}")
	get_issue_request.basic_auth "#{login}", "#{password}"
	
	get_issue_response = http.request(get_issue_request)

	get_issue_json = JSON.parse(get_issue_response.body)

	issue_id = get_issue_json['id']
	puts "Adding fixVersion #{fix_version} to Story #{jira_issue_key} (#{story['fields']['summary']})"
	update_fix_version http, login, password, fix_version, issue_id
	updated_issues_count += 1

	sub_tasks_array = get_issue_json['fields']['subtasks']
	for sub_task in sub_tasks_array
		sub_task_id = sub_task['id']
		puts "Adding fixVersion #{fix_version} to Task #{sub_task['key']} (#{sub_task['fields']['summary']})"
		update_fix_version http, login, password, fix_version, sub_task_id
		updated_issues_count += 1
	end
end

puts "#{updated_issues_count} issues updated."
