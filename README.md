# RoundRobin
Apex class to provide round robin functionality using the members of a public group.

## Components:
* RoundRobin.cls - Apex class that provides a method to get the next user in a round robin fashion from a public group (users are provided in the ascending order of name)

* RoundRobinLastAssignment - Custom setting that stores the last used user from a public group

## Install Steps:
* Use the botton below to deploy the code to your org:

<a href="https://githubsfdeploy.herokuapp.com?owner=veenasundara&repo=RoundRobin">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

* Create public group that you would like to use for round robin assignment

* Add users to the group

* In the apex code that needs to the round robin assignment, call the method **_getNextUser_** from the  RoundRobin Apex Class to get the next user to assign

NOTE - this can be used for any number of groups. So, you can use different groups for different round robin assgnments
