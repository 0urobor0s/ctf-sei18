#!/usr/bin/python
import base64
import sys

import base64

with open(sys.argv[1], "rb") as image_file:
    print base64.b64encode(image_file.read())
