######################################################
## CHECK OPTION
######################################################
OPT_STR="CKPT|SWITCH|ARCH|CLEANUP|FAILOVER|SNIPE|WAL|REBALANCE|LONGRUN|ERROR|DDL"

if [ $# -eq 0 ]
then
  DATE="\[`date '+%Y%m%d'` "
else
  DATE="\[$1 "
fi

if [ $# -eq 2 ]
then
  OPT=$2
else
  echo "usage] $0 <2023-01-01> <$OPT_STR>"
  exit -1
fi



######################################################
## CKPT INFO
######################################################
makeCkptInfo()
(
# get ckpt begin Times
cat system.trc* | grep -v "lid" | grep -B 1 "\[CHECKPOINT] begin" | grep -Ev "CHECKPOINT|\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get ckpt end Times
cat system.trc* | grep -v "lid" | grep -B 1 "\[CHECKPOINT] end" | grep -Ev "CHECKPOINT|\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > end.txt

# get Flushed Pages
cat system.trc* | grep -A 1 $DATE | grep "PAGE FLUSHER" | sort -k 4 | awk '{print $7}' | sed 's/(/ /g' | sed 's/)/ /g' | awk '{print $2}' > ff.txt


# display output
paste -d " " begin.txt end.txt ff.txt  > out.txt

# display output including elapsedTime
echo "beginTime,endTime,elaspedTime,flushPages"
while read a b c d e
do
str=`echo $a $b`
s1=`date --date="$str" +%s`

str=`echo $c $d`
e1=`date --date="$str" +%s`

ii=`expr $e1 - $s1`

echo "$a $b,$c $d,$ii,$e"
done < "out.txt"

)

######################################################
## LOG SWITCH INFO
######################################################
makeSwitchLog()
(
# get time on switch log
cat system.trc* | grep -B 1 "\[DATABASE] switch logfile" | grep -v "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get log group no
cat system.trc* | grep -A 1 $DATE | grep "\[DATABASE] switch logfile" | sed 's/(/ /g' | sed 's/)/ /g'| awk '{print $4 "," $5}' > ff.txt

# display output
echo "Time,groupNo,seq"
paste -d "," begin.txt ff.txt
)


######################################################
## LOG ARCHIVED
######################################################
makeArchiveLog()
(
# get archived begin Times
cat system.trc* | grep -B 1 "\[ARCHIVING] begin " | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get archived end Times
cat system.trc* | grep -B 1 "\[ARCHIVING] end " | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > end.txt

# get archive info
cat system.trc* | grep -A 1 $DATE | grep "\[ARCHIVELOG BEGIN] LOG"  | sed 's/(/ /g' | sed 's/)/ /g' | awk '{print $4 " " $5}' > ff.txt


# display output
paste -d " " begin.txt end.txt ff.txt > out.txt

# display output including elapsedTime
echo "beginTime,endTime,elapsedTime,source,archiveNo"
while read a b c d e f
do
str=`echo $a $b`
s1=`date --date="$str" +%s`

str=`echo $c $d`
e1=`date --date="$str" +%s`

ii=`expr $e1 - $s1`

echo "$a $b,$c $d,$ii,$e,$f"
done < "out.txt"

)




######################################################
## CLEANUP
######################################################
makeCleanupLog()
(
# get cleanup Times
cat system.trc* | grep -B 1 "\[CLEANUP] cleaning local session " | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get session info
cat system.trc* | grep -A 1 $DATE | grep "\[CLEANUP] cleaning local session " | sed 's/(/ /g' | sed 's/)/ /g' | awk '{print $10 "," $14 "," $17 "," $20}' > ff.txt


# display output
echo "Time,session,tx,prgram,pid"
paste -d "," begin.txt ff.txt
)



######################################################
## FAILOVER INFO
######################################################
makeFailoverLog()
(
# get time on begin failover
cat system.trc* | grep -B 1 "\[FAILOVER] begin" | grep -v "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get time on failover end
cat system.trc* | grep -B 1 "\[FAILOVER] end offline member" | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > end.txt

# get member
cat system.trc* | grep -B 1 "\[FAILOVER] offline member - member" | sed 's/(/ /g' | sed 's/)/ /g' | grep -A 1 $DATE | sort -k 1 | grep FAILOVER | awk '{print $6}' > ff.txt


# display output including elapsedTime
paste -d " " begin.txt end.txt ff.txt > out.txt

echo "beginTime,endTime,elapsedTime,memberId"
while read a b c d e
do
str=`echo $a $b`
s1=`date --date="$str" +%s`

str=`echo $c $d`
e1=`date --date="$str" +%s`

ii=`expr $e1 - $s1`

echo "$a $b,$c $d,$ii,$e"
done < "out.txt"
)




######################################################
## SNIPE
######################################################
makeSnipeLog()
(
# get cleanup Times
cat system.trc* | grep -B 1 "sniped remote session " | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get session info
cat system.trc* | grep -A 1 $DATE | grep "sniped remote session " | sed 's/(/ /g' | sed 's/)/ /g' | awk '{print $7 "," $11 "," $15}' > ff.txt


# display output
echo "Time,global_session,driver_session,local_session"
paste -d "," begin.txt ff.txt
)



######################################################
## enable/disable logging
######################################################
makeEnableDisableLog()
(
# begin
cat system.trc* | grep -B 1 "\[LOG FLUSHER] disable logging" | grep -v "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# end
cat system.trc* | grep -B 1 "\[ARCHIVING] enable logging" | grep -v "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > end.txt

# display output
paste -d " " begin.txt end.txt > out.txt

# display output including elapsedTime
echo "disableTime,enableTime,elapsedTime"
while read a b c d
do
str=`echo $a $b`
s1=`date --date="$str" +%s`

str=`echo $c $d`
e1=`date --date="$str" +%s`

ii=`expr $e1 - $s1`

echo "$a $b,$c $d,$ii"
done < "out.txt"
)


######################################################
## REBALANCE INFO
######################################################
makeRebalanceLog()
(
makeErrorLog > err.txt

# get rebalance begin Times
cat system.trc* | grep -B 1 "\[REBALANCE] rebalance lock table" | grep -B 1 "lock mode(IX" | grep -Ev "\--" | grep $DATE | sed 's/\[//g' | sed 's/]//g' | sed 's/(/ /g' | sed 's/)/ /g' | sort -k 1,2 | awk '{print $1 " " $2}' > begin.txt

# get rebalance tx
grep -B 1 "\[REBALANCE] rebalance lock table" system.trc* | grep -B 1 "lock mode(IX" | grep -Ev "\--" | grep -A 1 $DATE | sed 's/\[/ /g' | sed 's/]/ /g' | sed 's/(/ /g' | sed 's/)/ /g' | grep -v $DATE | awk '{print $15}' | grep "\." > tx1.txt


# get rebalance end Times
cat system.trc* | grep -B 1 -E "\[REBALANCE] finished at table|table already balanced|failed to rebalance table" | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > end.txt

# get target table
cat system.trc* | grep -B 1 -E "\[REBALANCE] finished at table|table already balanced|failed to rebalance table" | grep -Ev "\--" | grep -A 1 $DATE | grep -v $DATE | awk '{print $4 " or " $5 " or " $6}' | sed "s/'//g" > ff.txt


# display output
paste -d " " begin.txt tx1.txt end.txt ff.txt  > out.txt

# display output including elapsedTime
echo "beginTime,endTime,elaspedTime,table,status"
while read a b x c d e f g h i
do
str=`echo $a $b`
s1=`date --date="$str" +%s`

str=`echo $c $d`
e1=`date --date="$str" +%s`

ii=`expr $e1 - $s1`

#echo "$a $b,$c $d,$ii,$e,$f,$g,$h,$i"
if [ "x$i" = "xskipped" ]
then
   echo "$a $b,$c $d,$ii,$e,SKIP"
elif [ $e = "rebalance" ]
then
   msg=`grep "$c $d" err.txt | awk '{for(i=3;i<NF;i++) printf( "%s ", $i) }'`
   echo "$a $b,$c $d,$ii,$i,FAILURE,$msg"
elif [ $e = "table" ] && [ $f = "or" ]
then
   cnt1=`grep -B 1 -E "total synchronized record count" system.trc* | grep -Ev "\--" | grep -A 1 $a | grep -A 1 $x | grep $g | grep -v $a | sed 's/(/ /g' | sed 's/)/ /g' |awk '{print $19}'`
   echo "$a $b,$c $d,$ii,$g,SUCCESS,$cnt1,$x"
fi

done < "out.txt"

)




######################################################
## LONGRUN SQL
######################################################
makeLongRunLog()
(
# get long log Times
cat system.trc* | grep -B 1 "\[LONGRUN SQL]" | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# get target table
cat system.trc* | grep -A 1 $DATE | grep -B 1 "\[LONGRUN SQL]" | grep -Ev "\--" | grep -v $DATE | sed 's/\[/ /g' | sed 's/]/ /g' | sed 's/:/ /g' | awk '{print $4 "," $7 }' | sed 's/\[//g' > ff.txt


# get sqltext
cat system.trc* | grep -A 2 $DATE | grep -B 1 -A 1 "\[LONGRUN SQL]" | grep -v "\[LONGRUN SQL]" | grep -Ev "\--" | grep -v $DATE  > ff1.txt


# display output
echo "time,session,elapsedTime(ms),sql"
paste -d "," begin.txt ff.txt ff1.txt

)





######################################################
## ERROR
######################################################
makeErrorLog()
(
# begin
cat system.trc*  | grep -B 2 "ERR" | grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' | sort > begin.txt

# msg
cat system.trc*  | grep -B 2 "ERR" | grep -Ev "\--" | grep -A 2 $DATE | grep ERR | sed 's/\[//g' > ff.txt

# display output
paste -d "," begin.txt ff.txt
)

######################################################
## DDL
######################################################
makeDDLLog()
(
# get DDL Times
cat system.trc*| grep -B 1 "\[DDL"| grep -Ev "\--" | grep $DATE | awk '{print $1 " " $2 }' | sed 's/\[//g' |sort > begin.txt

# get state
cat system.trc*|grep -A 1 $DATE |grep -B 1 "\[DDL"| grep -oP '\[DDL.*\]'|awk '{print $2}'|tr -d ']' > state.txt 

# get DDL String

cat system.trc*|grep -A 1 $DATE |grep -B 1 "\[DDL"| grep -oP '\- \(.*'| tr -d '\-\(\)' |sed 's/^  //g' > string.txt

# display outputw
echo "time,state,sql"
paste -d "," begin.txt state.txt string.txt
)






######################################################
## RUN
######################################################
if [ $OPT = "CKPT" ]
then
  makeCkptInfo
elif [ $OPT = "SWITCH" ]
then
  makeSwitchLog
elif [ $OPT = "ARCH" ]
then
  makeArchiveLog
elif [ $OPT = "CLEANUP" ]
then
  makeCleanupLog
elif [ $OPT = "FAILOVER" ]
then
  makeFailoverLog
elif [ $OPT = "SNIPE" ]
then
  makeSnipeLog
elif [ $OPT = "WAL" ]
then
  makeEnableDisableLog
elif [ $OPT = "REBALANCE" ]
then
  makeRebalanceLog
elif [ $OPT = "LONGRUN" ]
then
  makeLongRunLog
elif [ $OPT = "ERROR" ]
then
  makeErrorLog
elif [ $OPT = "DDL" ]
then
  makeDDLLog
else
  echo "usage] $0 <2023-01-01> <$OPT_STR>"
fi


