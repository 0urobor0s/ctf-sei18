import glob
import os



with open("base64.txt","rb") as x:
    data = x.read().replace('\n', '')

    with open('frame.png','r+') as f:
        lines = f.readlines()
        lines[-1] = data + lines[-1].rstrip()
        f.writelines(lines)
        f.close()

