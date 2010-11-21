require 'net/imap'
require 'net/http'
require 'rubygems'
require 'yaml'

class Geekmail
	def self.run
		config_location = File.expand_path("~/.geekmail.conf")
		begin
			Geekmail.check_mail(YAML.load_file(config_location)["config"])
		rescue ArgumentError => e
			"Your configuration file seems to be missconfigured: #{e}"
		rescue Errno::ENOENT => e
			"Couldn't locate your config file. Please create it as #{config_location}"
		end
	end
	
	private
	def self.check_mail(config)
		tries = 5
		while (tries > 0) do

			begin
			  # make a connection to imap account
			  imap = Net::IMAP.new(config["host"], config["port"], true)
			  imap.login(config["username"], config["password"])
			  # select inbox as our mailbox to process
			  imap.examine('Inbox')

				number_of_message = 0
			  # count number of emails
			  imap.uid_search(["NOT", "DELETED"]).each do |uid|
					number_of_message += 1
			  end

				# Log out
			  imap.logout
			  imap.disconnect

				return number_of_message

			# NoResponseError and ByResponseError happen often when imap'ing
			rescue => e
				tries -= 1
				sleep(1)
				"Failed to get mail count" if (tries == 0)
			end			
		end
	end
end