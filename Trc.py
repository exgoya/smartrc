import os

class Trc:
    filenames = []

    def __init__(self, name):
      self.name = name

    def search(self,dirname):
        with os.scandir(dirname) as scans:
            for scan in scans:
                if self.name in scan.name:
                   self.filenames.append(scan.name)


d = Trc("system.trc")
d.search("./lgtrc/G1N1")

for filename in d.filenames:
    print(filename)

#print(d.name)
