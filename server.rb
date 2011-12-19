require 'rubygems'
require 'eventmachine'
		
class Server
	attr_accessor :c_socket, :s_socket
	def initialize
		puts "Connecting to client"
		@c_socket = EventMachine.connect 'mc.outerearth.net', 25564, Connection, true
		@s_socket = false
	end
end

class Connection < EM::Connection
	attr_accessor :client
	def initialize client
		@client = client
	end
	def post_init
		puts "Connected. Client: #{@client}"
	end
	def recieve_data data
		if @client
			if !@@server.s_socket
				put "Connecting to server"
				@@server.s_socket = EventMachine.connect 'localhost',25565, Connection, false
			end

			@@server.s_socket.send_data data
			puts "To S: #{data}"
		else
			@@server.c_socket.send_data data
			puts "To C: #{data}"
		end
	end
end
EventMachine.run {
	@@server = Server.new
}
