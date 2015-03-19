#!/bin/sh
#
#
# Created by JoinTheRealms @ xda-developers.com

cwd=$(pwd)
file=$1
runCount=$2
loop=0
run=1
timer=0
dataTransfer=0

# call this function to write copy info to log
timestamp()
{
fsize=$(( $2 / 1024 / 1024 ))"MBs" # File size in megabytes
fsize1=$(( $2 / $1 )) #Bytes per second
fsize2=$(( $fsize1 / 1024 / 1024 )) #Convert bytes to megabytes
fsize3="Transferred:$fsize""(Average Speed:""$fsize2""MBps"")"
dataTotal="total: "$(( $3 /1024/1024 ))"MBs"
time=$(date +"%T") 
middle=" - "
message=$(
if [ $4 -le 1 ] 
then
	echo "'$file Copied successfully $loop time!'"
else
	echo "'$file Copied successfully $loop times!'"
fi)
logMessage=$time$middle$message$middle$fsize3$middle$dataTotal
echo $logMessage >> $cwd/tmpMMCTEST/log
}

#look for previous tests in current working directory
if [ -d $cwd/tmpMMCTEST/log ]
then
	echo "Previous Test Found at '$cwd/tmpMMCTEST'"
	echo "Test result was:"
	echo ""
	tail -1 $cwd/tmpMMCTEST/log
	echo ""
	rm $cwd/tmpMMCTEST/$file  2> /dev/null
	echo "New Test? (Y/N)"
	read usrinput
	case $usrinput in
		[yY] | [yY][Ee][Ss] )
			run=1 ;;
		[nN] | [nN][oO] )
			run=0 ;;
		*)
			echo "Invaild Option" ;;
	esac
fi
# Setup enviroment
mkdir $cwd/tmpMMCTEST 2> /dev/null
touch $cwd/tmpMMCTEST/log 2> /dev/null
while [ $run -eq 1 ] 
do
	if [ -z $file ] # arg test1
	then
		echo ""
		echo "Please provide a file, mmctest [file] [timesToRun]"
		run=0
		break
	fi

	if [ $file = "--help" ] # arg test2
	then
		echo ""
		echo "mmctest:"
		echo ""

		echo "Testing Asus T100TA MMC lockups. Pick a larger file, this script copies a file to a temp directory, then logs information, finally deletes the copy. This loops the amount of times specified. This type of disk activity causes a lockup with kernels 3.17+ (as of 4.0r3 kernel). This scipt logs some information thats somewhat helpful for debugging."
		echo ""
		echo "./mmctest [file] [amount of times to run]"
		echo ""
		run=0	
		break
	fi

	if [ -z $runCount ] # arg test3
	then
		echo "Please provide a number of times to run"
		run=0
		break
	fi

	if [ $runCount -le 1 ] # arg test4
	then
		echo "Please provide a number greater than 1"
		run=0
		break
	fi

	time=$(date +"%T")
	echo "$time - Starting mmctest for $file $runCount times" > $cwd/tmpMMCTEST/log

	# Run rsync on a file multiple times and copy the resulting times to log
	while [ $loop -lt $runCount ] && [ $run -ne 0 ]
	do
		clear
		loop=`expr $loop + 1`
		echo "-----------------------------------------------------------"
		tail -n 1 $cwd/tmpMMCTEST/log
		echo "-----------------------------------------------------------"
		echo "Run: $loop/$runCount"
		if [ $loop -gt 1 ] 
		then
			echo "Copied: "$(( $dataTransfer / 1024 / 1024 ))"MBs"
		fi
		echo "-----------------------------------------------------------"
		start=`date +%s`
		rsync -Pa $cwd/$file $cwd/tmpMMCTEST
		fin=`date +%s`
		duration=$((fin-start))
		echo $duration
		filesize1=$(stat -c%s "$cwd/$file")
		dataTransfer=$(( $dataTransfer + $filesize1 ))
		timestamp $duration $filesize1 $dataTransfer $loop
		echo ""
		rm $cwd/tmpMMCTEST/$file  &>/dev/null
		clear

	done
	run=0
	
done

if [ $loop -gt 1 ]
then
	echo "Test Completed $loop times"
	echo "Save log? (Y/N)"
	read quit
	case $quit in
		[yY] | [yY][Ee][Ss] )
			echo "Saved to $cwd/ !"
			cp $cwd/tmpMMCTEST/log $cwd/
			 ;;
		[nN] | [nN][oO] )
			echo "Complete!"
			 ;;
		*)
			echo "Invaild Option" ;;
	esac
fi
#clean up only if test finishes without locking up
rm -r $cwd/tmpMMCTEST/* 2>&1
rmdir $cwd/tmpMMCTEST 2>&1

