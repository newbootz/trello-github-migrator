#!/usr/bin/env ruby

# Source: git@github.com:newbootz/trello-github-migrator.git
# Website: https://github.com/newbootz/trello-github-migrator
# Author: Jesus Galvan (@newbootz)

#Installation and configuration
#gem install bundler
#bundle install
#Add your authorization information to configuration files (config.json)

#How to use this utility
# ruby trello-migrator.rb <COMMAND> <ARGUMENTS> 

#COMMANDS
# show github-repos
# show github-milestones <username_or_organization> <repo_name>
# show trello-boards
# show trello-lists <board_id>
# migrate-list <trello_list_id> <username_or_organization> <github_repo_name>
# migrate-board <trello_board_id> <username_or_organization> <github_repo_name>

#required libraries
require 'github_api'
require 'trello'
require 'json'
include Trello

#ignore warnings for Hashie class
Hashie.logger = Logger.new(nil)

#read the config.json file and load the data
config_file = File.read('config.json')
config_hash = JSON.parse(config_file)
github_data = config_hash["github"]
trello_data = config_hash["trello"]

#Configuration for Trello CLI
#__________________________________________________________
TRELLO_DEVELOPER_PUBLIC_KEY = trello_data["TRELLO_DEVELOPER_PUBLIC_KEY"]
TRELLO_MEMBER_TOKEN = trello_data["TRELLO_MEMBER_TOKEN"]

Trello.configure do |c|
	c.developer_public_key = TRELLO_DEVELOPER_PUBLIC_KEY
	c.member_token = TRELLO_MEMBER_TOKEN
end
trello_user = Member.find("me")
#__________________________________________________________

#Configuration for GitHub CLI
#__________________________________________________________
GITHUB_USERNAME = github_data["GITHUB_USERNAME"]
GITHUB_PA_TOKEN = github_data["GITHUB_PA_TOKEN"]
GITHUB_URL = github_data["GITHUB_URL"]
GITHUB_API_ENDPOINT = github_data["GITHUB_API_ENDPOINT"]
Github.configure do |c|
  c.basic_auth = "#{GITHUB_USERNAME}:#{GITHUB_PA_TOKEN}"
  c.endpoint    = GITHUB_API_ENDPOINT
  c.site        = GITHUB_URL
end
github = Github.new
#__________________________________________________________

#Parse the command and execute
system("clear")
case ARGV[0]
# 'show' command can list github-repos, github-milestones trello-boards, or trello-lists
when 'show'
	ARGV[1].nil? ? show_cmd = "invalid" : show_cmd = ARGV[1]

	#output the user's list of repos to the console
	if show_cmd == "github-repos"
		repos = github.repos.list
		repos.each { |r| puts r["name"] }

	#output the user's list of milestones along with the id for the specified repo
	elsif show_cmd == "github-milestones"
		usr_org_name = ARGV[2]
		repo_name = ARGV[3]
		if usr_org_name.to_s.empty? or repo_name.to_s.empty?
			puts "INVALID ARGUMENTS: Please provide a valid argument for 'show github-milestones' command."
			puts "\n"
			puts "USAGE:             show github-milestones <username_or_organization> <github_repo_name>"
		else
			milestones = github.issues.milestones.list user: "#{usr_org_name}", repo: "#{repo_name}", state: "open"
			milestones.each { |m| puts "#{m["title"]} : #{m["number"]}"}
		end

	#show all boards along with their id for this trello user
	elsif show_cmd == "trello-boards"
		all_boards = Board.all
		all_boards.each { |b| puts "#{b.name} : #{b.id}"}

	#show all trello lists along with their ids for this trello user
	elsif show_cmd == "trello-lists"
		board_id = ARGV[2]
		if board_id.to_s.empty?
			puts "INVALID ARGUMENTS: Please provide a valid argument for 'show trello-lists <trello_board_id>' command."
			puts "\n"
			puts "USAGE:             show trello-lists <trello_board_id>"
		else
			user_board = Board.find("#{board_id}")
			if user_board.has_lists?
				board_lists = user_board.lists
				board_lists.each { |l| puts "#{l.name} : #{l.id}"}
			end
		end
	#the 'show' command was not valid... display proper usage of the 'show' commands
	else
		puts "INVALID ARGUMENTS: Please provide a valid argument for 'show' command."
		puts "\n"
		puts "USAGE:             show github-repos"
		puts "                   show github-milestones <username_or_organization> <github_repo_name>"
		puts "                   show trello-boards"
		puts "                   show trello-lists <trello_board_id>"
	end

#migrate-list command will migrate all tasks in a trello list into a target GitHub Repository as GitHub issues
when 'migrate-list'
	ARGV[1].nil? ? list_id = "invalid" : list_id = ARGV[1]
	org_usr_name = ARGV[2]
	repo_name = ARGV[3]

	if list_id == "invalid" or repo_name.to_s.empty? or org_usr_name.to_s.empty?
		puts "INVALID ARGUMENTS: Please provide a valid argument for 'migrate-list' command."
		puts "\n"
		puts "USAGE:             migrate-list <trello_list_id> <username_or_organization> <github_repo_name>"
	else
		user_list = List.find("#{list_id}")
		list_tasks = user_list.cards
		list_tasks.each do |t|
			title = t.name
			closed = t.badges["dueComplete"]
			body = t.desc
			#upload issue
			result = github.issues.create user: org_usr_name, repo: repo_name, title: "#{title}", body: "#{body}", 
			assignee: GITHUB_USERNAME
			issue_number = result["number"]
			if closed == true
				github.issues.edit user: org_usr_name, repo: repo_name, number: issue_number.to_i, state: "closed"
			end
		end
	end

#migrate-board command will migrate all tasks in trello board into target GitHub repository as GitHub issues.
when "migrate-board"
	ARGV[1].nil? ? board_id = "invalid" : board_id = ARGV[1]
	org_usr_name = ARGV[2]
	repo_name = ARGV[3]
	if board_id == "invalid" or repo_name.to_s.empty? or org_usr_name.to_s.empty?
		puts "INVALID ARGUMENTS: Please provide a valid argument for 'migrate-board' command."
		puts "\n"
		puts "USAGE:             migrate-board <trello_board_id> <username_or_organization> <github_repo_name>"
	else
		user_board = Board.find("#{board_id}")
		board_tasks = user_board.cards
		board_tasks.each do |t|
			title = t.name
			closed = t.badges["dueComplete"]
			body = t.desc
			#upload issue
			result = github.issues.create user: org_usr_name, repo: repo_name, title: "#{title}", body: "#{body}", 
			assignee: GITHUB_USERNAME
			issue_number = result["number"]
			if closed == true
				github.issues.edit user: org_usr_name, repo: repo_name, number: issue_number.to_i, state: "closed"
			end
		end
	end
when '--help'
	puts "USAGE:"
	puts "\t\tshow github-repos\nDescription: Shows all repos this user is part of in GitHub." 
	puts "\n\t\tshow github-milestones <username_or_organization> <github_repo_name>\n\t\tDescription: Shows all milestones that are open in the specified GitHub repo."
	puts "\n\t\tshow trello-boards\n\t\tDescription: Shows all boards under this Trello account."
	puts "\n\t\tshow trello-lists <trello_board_id>\n\t\tDescription: Shows all lists under this Trello account."
	puts "\n\t\tmigrate-board <trello_board_id> <username_or_organization> <github_repo_name>\n\t\tDescription: Migrates all tasks on a board into GitHub repository. Trello tasks will be created as issues."
    puts "\n\t\tmigrate-list <trello_list_id> <username_or_organization> <github_repo_name>\n\t\tDescription: Migrates Trello list of tasks into GitHub repository.Trello tasks will be created as GitHub Issues."
    # puts "                   migrate <trello_list_id> <username_or_organization> <github_milestone_number>\nDescription: Migrates this list of tasks into specified GitHub repository milestone. Trello tasks will be created as GitHub Issues."

else
	puts "INVALID ARGUMENTS: Please provide a valid command."
	puts "\n"
	puts "USAGE:"
	puts "\t\tshow github-repos\nDescription: Shows all repos this user is part of in GitHub." 
	puts "\n\t\tshow github-milestones <username_or_organization> <github_repo_name>\n\t\tDescription: Shows all milestones that are open in the specified GitHub repo."
	puts "\n\t\tshow trello-boards\n\t\tDescription: Shows all boards under this Trello account."
	puts "\n\t\tshow trello-lists <trello_board_id>\n\t\tDescription: Shows all lists under this Trello account."
	puts "\n\t\tmigrate-board <trello_board_id> <username_or_organization> <github_repo_name>\n\t\tDescription: Migrates all tasks on a board into GitHub repository. Trello tasks will be created as issues."
    puts "\n\t\tmigrate-list <trello_list_id> <username_or_organization> <github_repo_name>\n\t\tDescription: Migrates Trello list of tasks into GitHub repository.Trello tasks will be created as GitHub Issues."
    # puts "                   migrate <trello_list_id> <username_or_organization> <github_milestone_number>\nDescription: Migrates this list of tasks into specified GitHub repository milestone. Trello tasks will be created as GitHub Issues."

end