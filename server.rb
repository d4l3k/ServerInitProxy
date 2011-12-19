require 'rubygems'
require 'eventmachine'
		
class Server
	def initialize
		puts "Connecting to client"
		@@c_socket = EventMachine.connect 'mc.outerearth.net', 25564, ServConnection, true
		@@first_run = true
	end
end

class ServConnection < EventMachine::Connection
	attr_accessor :client
	def initialize client
		@client = client
	end
	def post_init
		puts "Connected. Client: #{@client}"
	end
	def recieve_data data
		puts "Recieved data"
		if @client
			"from client"
			if @@first_run
				put "First Run!"
				@@s_socket = EventMachine.connect 'localhost',25565, ServConnection, false
			end
			@@s_socket.send_data data
			puts "To S: #{data}"
		else
			@@c_socket.send_data data
			puts "To C: #{data}"
		end
	end
	def unbind
	end
end
EventMachine.run {
	@@server = Server.new
}
