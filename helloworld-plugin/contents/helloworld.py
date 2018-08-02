import sys
import os.path

print("Hello python from {}".format(sys.argv[1]))


stuff = []
for i in range(1, 10):
    stuff.append(os.path.join('a'))
