# trello-github-migrator
This is a simple command line utility written in Ruby that imports tasks from Trello as issues to a GitHub repository.

### Installation

### Usage

$ ruby trello-github-migrator.rb --help
USAGE:
                show github-repos
Description: Shows all repos this user is part of in GitHub.

                show github-milestones <username_or_organization> <github_repo_name>
                Description: Shows all milestones that are open in the specified GitHub repo.

                show trello-boards
                Description: Shows all boards under this Trello account.

                show trello-lists <trello_board_id>
                Description: Shows all lists under this Trello account.

                migrate-board <trello_board_id> <username_or_organization> <github_repo_name>
                Description: Migrates all tasks on a board into GitHub repository. Trello tasks will be created as issues.

                migrate-list <trello_list_id> <username_or_organization> <github_repo_name>
                Description: Migrates Trello list of tasks into GitHub repository.Trello tasks will be created as GitHub Issues.


$ ruby trello-github-migrator.rb show github-repos
CollaborateIOS
ZooKeeper
github-for-developers-sept-2015
intro-to-github
cs373-idb
UMOW
awesome-readme
cs356_project1
cs356_project2
ghissues
github
issues-testing
nodejs_project
ruby-trello
School-Projects
selenium
Spoon-Knife
trello-github-migrator
cs371_wrenn
cs371p-voting

$ ruby trello-github-migrator.rb show trello-boards
Welcome Board : 58bdd84534723e12e506bbe6
chewy-test-board : 58be0526f460518b51089be7
personal-test-board : 58be12d09fdbba10095599a8

$ ruby trello-github-migrator.rb show trello-lists 58be0526f460518b51089be7
to-do : 58be055d583ca94cebc06275
doing : 58be0560bbab18dd0d23b092
done : 58be0564e5b4b9cee6e7ad99
                
$ ruby trello-github-migrator.rb migrate-board 58be0526f460518b51089be7 newbootz issues-testing

$ ruby trello-github-migrator.rb migrate-list 58be0564e5b4b9cee6e7ad99 newbootz issues-testing
