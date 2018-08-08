#!/usr/bin/python3 -u

import os
import signal
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT_NUMBER = int(os.environ.get('APP_PORT', 8080))


class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"Hello World !")

    def do_HEAD(self):
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        pass


def main():
    try:
        server = HTTPServer(('', PORT_NUMBER), AppHandler)
        print('Started httpserver on port %d' % PORT_NUMBER)
        server.serve_forever()
    except KeyboardInterrupt:
        print('^C received, shutting down the web server')
        server.socket.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
