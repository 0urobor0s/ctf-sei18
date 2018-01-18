#!/usr/bin/python
import base64
import sys

with open(sys.argv[1],'rb') as r:
    data = r.read().replace('\n','')
    print base64.b64decode(data)
