# trello-github-migrator
This is a simple command line utility written in Ruby that imports tasks from Trello as issues to a GitHub repository.

This utility leverages the [ruby-trello](https://github.com/jeremytregunna/ruby-trello) Trello library by jeremytreguanna and the [github](https://github.com/piotrmurach/github) GitHub library by piotrmurach.

## Configuration
Requires Ruby 2.1.0 or newer.

Install bundler gem if it is not already installed.

```
gem install bundler
```

Install required gems with bundler
```
budle install
```

Don't forget to add your GitHub and Trello personal information to [config.json](https://github.com/newbootz/trello-github-migrator/blob/master/config.json). Once this is done you should be good to go!

You can find more info [here](https://developers.trello.com/sandbox) on how to attain the necessary tokens for the Trello API.

You can find more info [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) on how to attain your personal access token for GitHub.

## Usage

You can run the --help command to get a description of the available commands and infromation how to use them.
```
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
```

You can view your GitHub repositories with the ```show github-repos``` command below.
```
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
```
You can view your Trello task boards using the ```show trello-boards``` command as shown below.
```
$ ruby trello-github-migrator.rb show trello-boards
Welcome Board : 58bdd84534723e12e506bbe6
chewy-test-board : 58be0526f460518b51089be7
personal-test-board : 58be12d09fdbba10095599a8
```

Using a board id like the ones show above, you can view all the task lists that are part of the specified board. See example below.
```
$ ruby trello-github-migrator.rb show trello-lists 58be0526f460518b51089be7
to-do : 58be055d583ca94cebc06275
doing : 58be0560bbab18dd0d23b092
done : 58be0564e5b4b9cee6e7ad99
 ```
 
 You can decide to import an entire board of tasks into a specified GitHub repository. The tasks will be imported as GitHub issues. See the example below.
 ```
$ ruby trello-github-migrator.rb migrate-board 58be0526f460518b51089be7 newbootz issues-testing
```

You can decide to import only a list of tasks into a specified GitHub repository. The tasks will be imported as GitHub issues. See the example below.
```
$ ruby trello-github-migrator.rb migrate-list 58be0564e5b4b9cee6e7ad99 newbootz issues-testing
```
