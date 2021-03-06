# ruby-jira-scripts

## addFixVersionToIssuesWithJIRASearch.rb

This ruby script adds the provided version name to the fixVersion of all JIRA issues resulting of a JQL search query.

The interactive script asks for:
* the JIRA URL (e.g. https://www.foobar.com/jira)
* the login
* the password
* the fix version name to add
* the query using JIRA Query Language (JQL)

## addFixVersionToAllEpicIssues.rb

This ruby script adds the provided version name to the fixVersion of a JIRA Epic issue, all its linked JIRA Story issues and the stories Subtask issues.

The interactive script asks for:
* the JIRA URL (e.g. https://www.foobar.com/jira)
* the login
* the password
* the fix version name to add
* the JIRA Epic issue key

## removeFixVersionToIssuesWithJIRASearch.rb

This ruby script removes the provided version name to the fixVersion of all JIRA issues resulting of a JQL search query.

The interactive script asks for:
* the JIRA URL (e.g. https://www.foobar.com/jira)
* the login
* the password
* the fix version name to remove
* the query using JIRA Query Language (JQL)

## addLabelToIssuesWithJIRASearch.rb

This ruby script adds the provided label to the fixVersion of all JIRA issues resulting of a JQL search query.

The interactive script asks for:
* the JIRA URL (e.g. https://www.foobar.com/jira)
* the login
* the password
* the label to add
* the query using JIRA Query Language (JQL)
