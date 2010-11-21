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
		
			number_of_message

		# NoResponseError and ByResponseError happen often when imap'ing
		rescue Net::IMAP::NoResponseError => e
			"NoResponseError #{e}"
		rescue Net::IMAP::ByeResponseError => e
			"ByeResponseError #{e}"
		rescue => e
			"Unfortunate error..."
		end
	end
end