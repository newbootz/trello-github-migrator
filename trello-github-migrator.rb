#!/usr/bin/env ruby

# Source: git@github.com:newbootz/trello-github-migrator.git
# Website: https://github.com/newbootz/trello-github-migrator
# Author: Jesus Galvan (@newbootz)

#Installation and configuration
#gem install bundler
#bundle install
#Add your authorization information to configuration files (trello_cofig.json & github_config.json)

#How to use this utility
# ruby trello-migrator.rb 

# show github-repos
# show github-milestones <repo_name>

# show trello-boards
# show trello-lists <board_id>

# migrate <board_id> <repo_name>
# migrate <list_id> <repo_name>
# migrate <list_id> <milestone_number>

# $LOAD_PATH.unshift 'ruby-trello/lib'
require 'github_api'
require 'trello'
require 'json'
include Trello
Hashie.logger = Logger.new(nil)
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

system("clear")

case ARGV[0]
# 'show' command can list github-repos, github-milestones trello-boards, or trello-lists
when 'show'
	ARGV[1].nil? ? show_cmd = "invalid" : show_cmd = ARGV[1]

	if show_cmd == "github-repos"
		repos = github.repos.list
		repos.each { |r| puts r["name"] }

	elsif show_cmd == "github-milestones"
		usr_org_name = ARGV[2]
		repo_name = ARGV[3]
		if usr_org_name.to_s.empty? or repo_name.to_s.empty?
			puts "INVALID ARGUMENTS: Please provide a valid argument for 'show github-milestones' command."
			puts "\n"
			puts "USAGE:             show github-milestones <username_or_organization> <github_repo_name>"
		else
			milestones = github.issues.milestones.list user: "#{usr_org_name}", repo: "#{repo_name}", state: "open"
			milestones.each { |m| puts m["title"]}
		end

	elsif show_cmd == "trello-boards"
		all_boards = Board.all
		all_boards.each { |b| puts "#{b.name} : #{b.id}"}

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
	else
		puts "INVALID ARGUMENTS: Please provide a valid argument for 'show' command."
		puts "\n"
		puts "USAGE:             show github-repos"
		puts "                   show github-milestones <username_or_organization> <github_repo_name>"
		puts "                   show trello-boards"
		puts "                   show trello-lists <trello_board_id>"
	end
when 'migrate'
	ARGV[1].nil? ? trello_resource = "invalid" : show_cmd = ARGV[1]
when '--help'
	puts "USAGE:             show github-repos\nDescription: Shows all repos this user is part of in GitHub." 
	puts "                   show github-milestones <username_or_organization> <github_repo_name>\nDescription: Shows all milestones that are open in the specified GitHub repo."
	puts "                   show trello-boards\nDescription: Shows all boards under this Trello account."
	puts "                   show trello-lists <trello_board_id>\nDescription: Shows all lists under this Trello account."
	puts "                   migrate <trello_board_id> <github_repo_name>"
    puts "                   migrate <trello_list_id> <username_or_organization> <github_repo_name>\nDescription: Migrates Trello list of tasks into GitHub repository.Trello tasks will be created as GitHub Issues."
    puts "                   migrate <trello_list_id> <username_or_organization> <github_milestone_number>\nDescription: Migrates this list of tasks into specified GitHub repository milestone. Trello tasks will be created as GitHub Issues."

else
	puts "INVALID ARGUMENTS: Please provide a valid command."
	puts "\n"
	puts "USAGE:             show github-repos\nDescription: Shows all repos this user is part of in GitHub." 
	puts "                   show github-milestones <username_or_organization> <github_repo_name>\nDescription: Shows all milestones that are open in the specified GitHub repo."
	puts "                   show trello-boards\nDescription: Shows all boards under this Trello account."
	puts "                   show trello-lists <trello_board_id>\nDescription: Shows all lists under this Trello account."
	puts "                   migrate <trello_board_id> <github_repo_name>"
    puts "                   migrate <trello_list_id> <username_or_organization> <github_repo_name>\nDescription: Migrates Trello list of tasks into GitHub repository.Trello tasks will be created as GitHub Issues."
    puts "                   migrate <trello_list_id> <username_or_organization> <github_milestone_number>\nDescription: Migrates this list of tasks into specified GitHub repository milestone. Trello tasks will be created as GitHub Issues."

end