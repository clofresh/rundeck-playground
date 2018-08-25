#!/usr/local/bin/python3 -u

import os
import signal
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

import psycopg2
import yaml

PORT_NUMBER = int(os.environ.get('APP_PORT', 8080))

with open('/etc/web.yaml') as f:
    config = yaml.load(f.read())

db = psycopg2.connect(**config['db'])

class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            with db.cursor() as cur:
                cur.execute('select version()')
                (pgversion,) = cur.fetchone()
            body = b'Hello World. Connected to database: ' + bytes(pgversion, 'utf-8')
        except Exception:
            status_code = 500
            body = b'Error'
            raise
        else:
            status_code = 200
        finally:
            self.send_response(status_code)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(body)

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
    finally:
        db.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
