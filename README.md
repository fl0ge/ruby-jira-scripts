# ruby-jira-scripts

## addFixVersionToAllEpicIssues.rb

This ruby script adds the provided version name to the fixVersion of a JIRA Epic issue, all its linked JIRA Story issues and the stories Subtask issues.

The interactive script asks for:
* the JIRA URL (e.g. https://www.foobar.com/jira)
* the login
* the password
* the fix version name to add
* the JIRA Epic issue key
