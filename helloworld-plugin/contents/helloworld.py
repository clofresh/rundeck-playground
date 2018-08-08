import sys
import os.path

import yaml

print("Hello python from {}".format(sys.argv[1]))

with open(sys.argv[2], 'rb') as f:
    config = yaml.load(f.read())

print(config)
