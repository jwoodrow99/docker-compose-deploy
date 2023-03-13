# importing all the functions 
# from http.server module
from http.server import *
  
# creating a class for handling 
# basic Get and Post Requests
class GFG(BaseHTTPRequestHandler):
    
    # creating a function for Get Request
    def do_GET(self):
        
        # Success Response --> 200
        self.send_response(200)
          
        # Type of file that we are using for creating our
        # web server.
        self.send_header('content-type', 'text/html')
        self.end_headers()
          
        # what we write in this function it gets visible on our
        # web-server
        self.wfile.write('<h1>Hello World! From Python.</h1>'.encode())
  
  
# this is the object which take port 
# number and the server-name
# for running the server
port = HTTPServer(('', 9000), GFG)
  
# this is used for running our 
# server as long as we wish
# i.e. forever
port.serve_forever()