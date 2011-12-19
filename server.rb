require 'socket'
require 'thread'
		
class Server
	def initialize
		@@c_socket = TCPSocket.open("mc.outerearth.net",25564)
		puts "Connected to client"
		@@s_socket = false
		
		puts "Client listening thread open."
		while data = @@c_socket.getc
			if !@@s_socket
				@@s_socket = TCPSocket.open("10.108.3.5",25565)
				puts "connected to server"
				@@s = Thread.new do
					puts "Server listening thread open."
					while data = @@s_socket.getc
						@@c_socket.putc data
						puts "To C: #{data}"
					end
				end
			end
			@@s_socket.putc data
			puts "To S: #{data}"
		end
	end
end

s = Server.new
