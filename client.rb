require 'rubygems'
require 'eventmachine'

@@server = false
@@client = false

class Connection < EM::Connection
    def initialize
	    if !$server
		    $server = self
		    @s = true
		    puts "Server connected!"
	    elsif
		    $client = self
		    @s = false
		    puts "Client connected!"
	    end
    end
    def receive_data(data)
	    if !@s
		    $server.send_data data
		    puts "to server"
	    else
		    $client.send_data data
		    puts "to client"
	    end
	    puts data
    end
    def unbind
    	puts "Lost connection. server: #{@s}"
    end
end

EventMachine.run {
    EventMachine::start_server "0.0.0.0", 25564, Connection
}
