require 'rubygems'
require 'eventmachine'

$control = false
$clients = []

class ClientConnection < EventMachine::Connection
	attr_accessor :server_connection
	def initialize
		@first_run = true
		$clients.push self
		puts "Client connection."
	end
	def receive_data data
		if @first_run
			@server_connection = EventMachine.connect 'localhost', 25565, ServerConnection
			@server_connection.client_connection = self
		end
		@server_connection.send_data data
	end
	def unbind
		puts "Lost connection from client. Closing Server connection."
		@server_connection.close_connection_after_writing
	end
end
class ServerConnection < EventMachine::Connection
	attr_accessor :client_connection
	def initialize
		puts "New server connection."
	end
	def receive_data data
		@client_connection.send_data data
	end
	def unbind
		puts "Lost server connection. Closing client connection."
		@client_connection.close_connection_after_writing
	end
end
class ControlConnection
	def initialize
		$control = self
	end
	def receive_data data
		if data="new_connection"
			EventMachine.connect 'mc.outerearth.net', 25563, ClientConnection
		end
	end
	def unbind
	end
end
EventMachine.run {
	EventMachine.connect 'mc.outerearth.net', 25562, ControlConnection
}
