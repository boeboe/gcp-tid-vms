#!/usr/bin/env python3

import os, socket

from datetime import datetime
from functools import partial
from http.server import HTTPServer, BaseHTTPRequestHandler

class CustomHandler(BaseHTTPRequestHandler):

  def __init__(self, host, ip, msg, region, zone, *args, **kwargs):
    self.host = host
    self.ip = ip
    self.msg = msg
    self.region = region
    self.zone = zone
    super().__init__(*args, **kwargs)

  def do_GET(self):
    self.send_response(200)
    self.send_header('content-type','application/json')
    self.end_headers()

    json_response = """{
  "destination_ip": "%s",
  "headers": "%s",
  "host": "%s",
  "message": "%s",
  "region": "%s",
  "source_ip": "%s",
  "timestamp": "%s",
  "zone": "%s"
}""" % (self.ip, list(filter(None, str(self.headers).splitlines())), self.host, self.msg,
        self.region, self.client_address[0], str(datetime.now()), self.zone)

    self.wfile.write(json_response.encode())

def main():
  HTTP_PORT = int(os.getenv('HTTP_PORT', 8080))
  HOST = socket.gethostname()
  IP = socket.gethostbyname(HOST)
  MSG = os.getenv('MSG', "Hello grasshopper!")
  REGION = os.getenv('REGION', "Unkown")
  ZONE = os.getenv('ZONE', "Unkown")

  handler = partial(CustomHandler, HOST, IP, MSG, REGION, ZONE)
  srv = HTTPServer(('',HTTP_PORT), handler)
  print('Server started on port %s' %HTTP_PORT)
  print('  Host %s' %HOST)
  print('  Ip %s' %IP)
  print('  Msg %s' %MSG)
  print('  Region %s' %REGION)
  print('  Zone %s' %ZONE)
  srv.serve_forever()

if __name__ == '__main__':
  main()
