#!/usr/bin/python
import socket
import re
class Bot:

    def __init__(self):
        self.flag = "https://ghostbin.com/paste/9r5u4"
        self.channel = "#cesium"
        self.botnick = "SEI"
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.connect(("chat.freenode.net",6667))
        self.s.send("USER "+ self.botnick +" "
            + self.botnick +" "+ self.botnick + " "
            + self.botnick + "\n")
        self.s.send("NICK "+self.botnick+"\n")

    def message(self,message):
        self.s.send("PRIVMSG "+self.channel+" :"+message+"\r\n")

    def privMessage(self,message,user):
        self.s.send("PRIVMSG "+user+" :"+message+"\r\n")

    def connect(self):
        self.s.send("JOIN "+self.channel + "\n")
        ircmsg = ""
        while ircmsg.find("End of /NAMES list.") == -1:
          ircmsg = self.s.recv(2048).decode("UTF-8")
          ircmsg = ircmsg.strip('\n\r')
          ##print(ircmsg)

    def readlines(self, recv_buffer=4096, delim='\n'):
        buffer = ''
        data = True
        while data:
            data = self.s.recv(recv_buffer)
            buffer += data

            while buffer.find(delim) != -1:
                line, buffer = buffer.split('\n', 1)
                yield line
        return

    def read(self):
        for line in self.readlines():
            if line.find("PING :") != -1:
                self.message("PONG :pingis\n")
            if line.lower().find("flag") != -1:
                regex = r".*(?=!)"
                find = re.search(regex,line)
                username = find.group()
                self.privMessage(self.flag,username[1:])


if __name__ == '__main__':
    bot = Bot()
    bot.connect()
    bot.message("ola")
    bot.read()
