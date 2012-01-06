require 'rubygems'
require 'eventmachine'

$control = false
$clients = []
$waiting_clients = []

class Connection < EM::Connection
attr_accessor :queue, :server_connection
	def initialize
    		port, *ip_parts = get_peername[2,6].unpack "nC4"
		ip = ip_parts.join('.')
		puts "Client Connection from: #{ip}."
		$clients.push self
		$waiting_clients.push self
		@server_connection = false
		$control.demand_new_connection
    	end
    	def receive_data(data)
		if !@server_connection
			@server_connection.send_data data
		else
			@queue.push data
		end
    	end
    	def unbind
    		puts "Lost connection from client. Closing Server connection."
		@server_connection.close_connection_after_writing
    	end
end
class ServerConnection < EM::Connection
attr_accessor :client_connection
	def initialize
		port, *ip_parts = get_peername[2,6].unpack "nC4"
		ip = ip_parts.join('.')
		puts "Server Connection from: #{ip}."
		@client_connection = $waiting_clients.pop(0)
		if pop == nil
			puts "No waiting connections"
			close_connection_after_writing
		else
			puts "Attaching to connection."
			@client_connection.server_connection = self
			puts "Sending queue."
			while (data = @client_connection.queue.pop(0))!=nil
				send_data data
			end
		end
	end
	def receive_data(data)
		@client_connection.send_data data
	end
	def unbind
    		puts "Lost connection from server. Closing client connection."
		@client_connection.close_connection_after_writing
    	end
end
class ControlConnection < EM::Connection
	def initialize
		$control = self

		port, *ip_parts = get_peername[2,6].unpack "nC4"
		ip = ip_parts.join('.')
		puts "Gained Control Connection from: #{ip}."
	end
	def demand_new_connection
		send_data "new_connection"
	end
end

EventMachine.run {
    EventMachine::start_server "0.0.0.0", 25564, Connection
    EventMachine::start_server "0.0.0.0", 25563, ServerConnection
    EventMachine::start_server "0.0.0.0", 25562, ControlConnection
}
