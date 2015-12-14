require 'monitor'
require 'web.server'

monitor.init()

local Server = web.webserver.create{
   actions=monitor.Actions,
   default='web/index.html',
   -- If the test property is defined then static files are pulled from the sandbox 
   -- rather than from the mile-stoned versioned copies of the files.  In production
   -- the test propery should be commmented out.
   --test='admin'    
}  

function main(Data)
   trace(monitor.Actions)
   Server:serveRequest{data=Data}
end
