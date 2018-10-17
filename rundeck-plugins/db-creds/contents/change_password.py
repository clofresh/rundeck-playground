import sys
import os.path

import yaml
import pyaml

config_path = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
print('Updating {} with db user credentials: {}'.format(config_path, user))

with open(config_path, 'r') as f:
    config = yaml.load(f.read())
config['db']['user'] = user
config['db']['password'] = password

with open(config_path, 'w') as f:
    f.write(pyaml.dump(config))

print('Done')
