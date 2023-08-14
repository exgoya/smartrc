import os

class Trc:
    filenames = []

    # 인스턴스 생성시 init
    def __init__(self, name):
      self.name = name
 
    # with 호출시 반환될 객체
    def __enter__(self):
         return self

    # search 함수
    def search(self,dirname):
        with os.scandir(dirname) as scans:
            for scan in scans:
                if self.name in scan.name:
                   self.filenames.append(scan.name)

    # with 구문을 빠져나가기 전 수행됨
    def __exit__(self,exc_type,exe_val,exe_tb):
       del self

with Trc("system.trc") as d:
  d.search("./lgtrc/G1N1")
  print(d.filenames)