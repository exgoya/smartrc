import os

class Trc:
    filenames = []

    # 인스턴스 생성시 init
    def __init__(self):
        pass
 
    # with 호출시 반환될 객체
    def __enter__(self):
         return self

    # search 함수
    def search(self,dirname,filename):
        with os.scandir(dirname) as scans:
            for scan in scans:
                if filename in scan.name:
                   self.filenames.append(scan.name)

    # with 구문을 빠져나가기 전 수행됨
    def __exit__(self,exc_type,exe_val,exe_tb):
       del self

with Trc() as d:
  d.search("./trc/G1N1","system.trc")
  print(d.filenames)