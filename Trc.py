import os

class Trc:
    filenames = []

    def __init__(self, name):
      self.name = name

    def __enter__(self):
        print(self.name)
        return self

    def search(self,dirname):
        with os.scandir(dirname) as scans:
            for scan in scans:
                if self.name in scan.name:
                   self.filenames.append(scan.name)

    def __exit__(self,exc_type,exe_val,exe_tb):
       del self
       print('with exit')


with Trc("system.trc") as d:
  d.search("./lgtrc/G1N1")

#for filename in d.filenames:
  print(d.filenames)

#del d
#print(d.name)