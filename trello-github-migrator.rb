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


$LOAD_PATH.unshift 'lib'

require 'github_api'
require 'trello'
require 'json'
# include Trello

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
#__________________________________________________________

system("clear")

case ARGV[0]
when 'show'
	ARGV[1].nil? ? show_cmd = "invalid" : show_cmd = ARGV[1]
	if show_cmd == "github-repos"
		puts "show github repos"
	elsif show_cmd == "gihub-milestones"
		puts "show milestones"
	elsif show_cmd == "trello-boards"
		puts "show boards"
	elsif show_cmd == "trello-lists"
		puts "show lists" 
	else
		puts "INVALID ARGUMENTS: Please provide a valid argument for 'show' command."
		puts "\n"
		puts "USAGE:             show github-repos"
		puts "                   show github-milestones <github_repo_name>"
		puts "                   show trello-boards"
		puts "                   show trello-lists <trello_board_id>"
	end
when 'migrate'
	puts "implement migrate commands"
when '--help'
	puts "implement --help command"

else
	puts "INVALID ARGUMENTS: Please provide a valid command."
	puts "\n"
	puts "USAGE:             show github-repos"
	puts "                   show github-milestones <github_repo_name>"
	puts "                   show trello-boards"
	puts "                   show trello-lists <trello_board_id>"
	puts "                   migrate <trello_board_id> <github_repo_name>"
    puts "                   migrate <trello_list_id> <github_repo_name>"
    puts "                   migrate <trello_list_id> <github_milestone_number>"
end
