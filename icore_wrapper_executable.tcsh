#! /bin/tcsh -fe

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date '+%m/%d/%Y %H:%M:%S'`
echo 
echo Wrapper Started at:
echo $startTime
echo
echo Version 2.05 
echo
echo This Wrapper will wrap around and run these 3 programs:
echo 1\) fbt3 and PSFavr8
echo 2\) ICORE
echo 3\) MDET
echo

set SNRthreshold = 1.8
#check hyphenated argument
@ i = 0
set arg_SNR = ""
set rsyncSet = "false"
while ($i < $# + 1)
     #user input -SNR argument
     if("$argv[$i]" == "-SNR") then
        @ temp = $i + 1
        if($temp < $# + 1) then
                if($argv[$temp] != "") then
                        set arg_SNR = $argv[$temp]
			set SNRthreshold = $arg_SNR
                        echo Custom SNR == $arg_SNR
                else
                        echo please enter SNR after '-SNR'
                endif
        else
                echo please enter SNR after '-SNR'
        endif
      else if("$argv[$i]" == "-p") then
	#parallel mode, ignore setup environment
	echo parallelmode3 called
	set ParentDir = $2
        set RadecID = $3
        echo Parent Dir ==  $ParentDir
        echo Tile Name == $RadecID
        echo
	goto ParallelMode3
      else if("$argv[$i]" == "-rsync") then
	echo Argument "-rsync" detected. Will rsync Tyto, Otus, and Athene.
	set rsyncSet = "true"
      endif
      @ i +=  1
end

if ($# < 2) then #($# != 2 && $# != 3) then
        #Error handling
        #Too many or too little arguments
        echo ""
        echo "ERROR: not enough arguments:"
        echo Mode 1 call:
        echo ./icore_wrapper_executable_opt1.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./icore_wrapper_executable_opt1.tcsh 2 ParentDir/ ParentDir/
        echo Mode 3 call:
        echo ./icore_wrapper_executable_opt1.tcsh 3 ParentDir/ TileName
        echo
        echo Exiting...
        exit
#Mode1
else if ($1 == 1) then
        set ParentDir = $2
	set InputsDir = ${ParentDir}/UnWISE/
	set OutputsDir = ${ParentDir}/CatWISE/
	echo Inputs directory ==  $InputsDir
	echo Outputs directory == $OutputsDir
	echo "Are these the correct input and output directories? (y/n)"
	set userInput = $<
	
	#Error handling
	#if user input dir wrong
	if($userInput != "Y" && $userInput != "y") then
		echo Please execute program again with full Input Directory path as the 2nd parameter and the Ouput Directory path as your 3rd parameter  
		#TODO actually throw an error instead of just outputing to stdout... output to stderr
		echo
		echo Exiting...	
		exit
	endif
	#if directories dont exist, throw error
	if(! -d $InputsDir) then  
		echo ERROR: Input Directory $InputsDir doest not exist.
		echo	
		echo Exiting...
		exit
	endif
#Don't need to check since OutputsDir is made if DNE
#	if (! -d $OutputsDir) then
#		echo ERROR: Output Directory $OutputsDir does not exist.
#		echo	
#		echo Exiting...
#		exit
#	endif
	
	goto Mode1
#Mode2 List of Tiles Mode
else if ($1 == 2) then
	set InputsList = $3
        set ParentDir = $2
        echo Inputs list ==  $InputsList
        echo Parent directory == $ParentDir
        echo
        echo "Is this the correct input list and Parent directory? (y/n)"
        set userInput = $<

    #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input List file as the 2nd parameter and the Parent Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -f $InputsList) then
                echo ERROR: Input List file $InputsList doest not exist.
                echo
                echo Exiting...
                exit
        endif
        if (! -d $ParentDir) then
                echo ERROR: Parent Directory $ParentDir does not exist.
                echo
                echo Exiting...
                exit
        endif
	goto Mode2
#Mode3 Single Tile Mode
else if ($1 == 3) then
        set ParentDir = $2
        set RadecID = $3
        echo Parent Dir ==  $ParentDir
        echo Tile Name == $RadecID
        echo
        echo "Is this the correct Parent Directory and Tile Name? (y/n)"
        set userInput = $<
        #Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with Parent Directory as the 2nd parameter and the Tile Name as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -d $ParentDir) then
		echo
                echo ERROR: $ParentDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
echo "going to Mode3"
        goto Mode3
else
	#Error handling
	#mode 1/2 not second parameter. program exits.
	echo ERROR: mode 1, 2, or 3 not selected
	echo
        echo Mode 1 call:
        echo ./icore_wrapper_executable_opt1.tcsh 1 ParentDir/
        echo Mode 2 call:
        echo ./icore_wrapper_executable_opt1.tcsh 2 inputList.txt ParentDir/
        echo Mode 3 call:
        echo ./icore_wrapper_executable_opt1.tcsh 3 ParentDir/ TileName
        echo
	echo Exiting...
	exit
endif




Mode1:
#===============================================================================================================================================================	
# links parent and wrapper dir to run "tcsh" and "source SORUCEME" in parent dir
# this assumes tcsh is installed
echo Creating temp files...
cd ..
tcsh & source SOURCEME && cd $wrapperDir

# loops through all of the tiles and executes icore

set FulldepthDir = ${InputsDir}/

echo Wrapper now starting...

echo
echo

echo "NOTE: fbt3 and PSFavr8 will delete any existing PSFs you have in $InputsDir"
echo 
echo "Do you want to run fbt3 and PSFavr8 (y/n)?"
set userInput = $<
if($userInput != "Y" && $userInput != "y") then
        goto ICORE_Wrapper_Mode1
else 
	goto fbt3_PSFavr8_Wrapper_Mode1
endif

fbt3_PSFavr8_Wrapper_Mode1:

foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

	foreach RadecIDDir ($RaRaRaDir*/)

                echo =============================== starting mdet wrapper loop iteration =================================
        #Stops calling programs if number of scripts running is greater than number of threads on CPU

                set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
                @ tempIndex = ($tempSize - 8)
                set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
                set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo $FulldepthDir
                echo $RadecIDDir
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

		echo calling mdet wrapper mode 3 on $RadecID
                (echo y |  ./icore_wrapper_executable.tcsh 3 $ParentDir $RadecID -SNR $SNRthreshold -p) &  #&& (echo Wrapper Call for ${RadecID} success!)

                if(`ps -ef | grep icore_wrapper_executable | wc -l` > 14) then
                        echo ${RadecID} More than 12 icore_wrapper_executable processes, waiting...
                        while(`ps -ef | grep icore_wrapper_executable | wc -l` > 14)
                                sleep 1
                                #echo IM WATING
                                #do nothing
                        end
                        echo ${RadecID} Done waiting!
                endif



                echo mdet wrapper for ${RadecID} done!

                echo ================================ ending mdet wrapper loop iteration =================================
        end
    end


#===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
#rsync loop
foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

	foreach RadecIDDir ($RaRaRaDir*/)

                set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
                @ tempIndex = ($tempSize - 8)
                set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
                set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

	if($rsyncSet == "true") then
	#rsync
	echo running rsync on tile $RadecID
        set currIP = `curl ipecho.net/plain ; echo`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                echo On Tyto!
                
               #Transfer to Otus
		ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Otus $otus_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.75:$otus_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Otus $otus_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
               #Transfer to Athene
		ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Athene $athene_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.72:$athene_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Athene $athene_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/tyto1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/athene1/g'`
                echo On Otus!

                #transfer to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto
                #transfer to Athene
                echo rsync Otus\'s $CatWISEDir to Athene
        else if($currIP == "137.78.80.72") then #Athene
                echo On Athene!

                #transfer to Tyto
                echo rsync Athene\'s $CatWISEDir to Tyto
                #transfer to Otus
                echo rsync Athene\'s $CatWISEDir to Otus
        endif
	endif
  end
end


    echo
    goto Done


ICORE_Wrapper_Mode1:

foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

        foreach RadecIDDir ($RaRaRaDir*/)

                echo =============================== starting mdet wrapper loop iteration =================================
        #Stops calling programs if number of scripts running is greater than number of threads on CPU

                set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
                @ tempIndex = ($tempSize - 8)
                set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
                set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo $FulldepthDir
                echo $RadecIDDir
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

                (echo n | ./icore_wrapper_executable.tcsh 3 $ParentDir $RadecID -SNR $SNRthreshold -p) &  #&& (echo Wrapper Call for ${RadecID} success!)

                if(`ps -ef | grep icore_wrapper_executable | wc -l` > 14) then
                        echo ${RadecID} More than 12 icore_wrapper_executable processes, waiting...
                        while(`ps -ef | grep icore_wrapper_executable | wc -l` > 14)
                                sleep 1
                                #echo IM WATING
                                #do nothing
                        end
                        echo ${RadecID} Done waiting!
                endif


                echo mdet wrapper for ${RadecID} done!

                echo ================================ ending mdet wrapper loop iteration =================================
        end
    end


#===============================================================================================================================================================

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!

#rsync loop
foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile

	foreach RadecIDDir ($RaRaRaDir*/)

                set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
                @ tempIndex = ($tempSize - 8)
                set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
                set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

	if($rsyncSet == "true") then
	#rsync
	echo running rsync on tile $RadecID
        set currIP = `curl ipecho.net/plain ; echo`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                echo On Tyto!
                
               #Transfer to Otus
		ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Otus $otus_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.75:$otus_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Otus $otus_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
               #Transfer to Athene
		ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Athene $athene_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.72:$athene_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Athene $athene_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/tyto1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/athene1/g'`
                echo On Otus!

                #transfer to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto
                #transfer to Athene
                echo rsync Otus\'s $CatWISEDir to Athene
        else if($currIP == "137.78.80.72") then #Athene
                echo On Athene!

                #transfer to Tyto
                echo rsync Athene\'s $CatWISEDir to Tyto
                #transfer to Otus
                echo rsync Athene\'s $CatWISEDir to Otus
        endif
	endif
  end
end

    echo
    goto Done



Mode2:
#===============================================================================================================================================================	
# links parent and wrapper dir to run "tcsh" and "source SORUCEME" in parent dir
# this assumes tcsh is installed
echo Creating temp files...
cd ..
tcsh & source SOURCEME && cd $wrapperDir

# loops through all of the tiles and executes icore

echo Wrapper now starting...

echo
echo

echo "NOTE: fbt3 and PSFavr8 will delete any existing PSFs you have in ${ParentDir}/CatWISE"
echo 
echo "Do you want to run fbt3 and PSFavr8 (y/n)?"
set userInput = $<
if($userInput != "Y" && $userInput != "y") then
        goto ICORE_Wrapper_Mode2
else 
	goto fbt3_PSFavr8_Wrapper_Mode2
endif


fbt3_PSFavr8_Wrapper_Mode2:
foreach line (`cat $InputsList`)

                echo =============================== starting mdet wrapper loop iteration =================================
        	set RadecID = `echo $line`
        	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

                (echo y | ./icore_wrapper_executable.tcsh 3 $ParentDir $RadecID -SNR $SNRthreshold -p) &  #&& (echo Wrapper Call for ${RadecID} success!)

                if(`ps -ef | grep icore_wrapper_executable | wc -l` > 14) then
                        echo ${RadecID} More than 12 icore_wrapper_executable processes, waiting...
                        while(`ps -ef | grep icore_wrapper_executable | wc -l` > 14)
                                sleep 1
                                #echo IM WATING
                                #do nothing
                        end
                        echo ${RadecID} Done waiting!
                endif

                echo mdet wrapper for ${RadecID} done!

                echo ================================ ending mdet wrapper loop iteration =================================
end

    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
    echo now performing rsync steps...
#rsync loop
foreach line (`cat $InputsList`)

        	set RadecID = `echo $line`
        	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

	if($rsyncSet == "true") then
	#rsync
	echo running rsync on tile $RadecID
        set currIP = `curl ipecho.net/plain ; echo`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                echo On Tyto!
                
               #Transfer to Otus
		ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Otus $otus_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.75:$otus_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Otus $otus_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
               #Transfer to Athene
		ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Athene $athene_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.72:$athene_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Athene $athene_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/tyto1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/athene1/g'`
                echo On Otus!

                #transfer to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto
                #transfer to Athene
                echo rsync Otus\'s $CatWISEDir to Athene
        else if($currIP == "137.78.80.72") then #Athene
                echo On Athene!

                #transfer to Tyto
                echo rsync Athene\'s $CatWISEDir to Tyto
                #transfer to Otus
                echo rsync Athene\'s $CatWISEDir to Otus
        endif
	endif

end


#===============================================================================================================================================================

    echo finished rsync, done!
    echo
    goto Done


ICORE_Wrapper_Mode2:

foreach line (`cat $InputsList`)

                echo =============================== starting mdet wrapper loop iteration =================================
                set RadecID = `echo $line`
                set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

                (echo n | ./icore_wrapper_executable.tcsh 3 $ParentDir $RadecID -SNR $SNRthreshold -p) &  #&& (echo Wrapper Call for ${RadecID} success!)
                
		if(`ps -ef | grep icore_wrapper_executable | wc -l` > 14) then
                        echo ${RadecID} More than 12 icore_wrapper_executable processes, waiting...
                        while(`ps -ef | grep icore_wrapper_executable | wc -l` > 14)
                                sleep 1
                                #echo IM WATING
                                #do nothing
                        end
                        echo ${RadecID} Done waiting!
                endif

                echo mdet wrapper for ${RadecID} done!

                echo ================================ ending mdet wrapper loop iteration =================================
end
    #wait for background processes to finish
    wait
    echo wphot wrapper finished!
#rsync loop
foreach line (`cat $InputsList`)

        	set RadecID = `echo $line`
        	set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
                set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
                set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
		set OUTPUTdir = ${CatWISEDir}
                set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/
                echo RadecID == $RadecID
                echo RaRaRa == $RaRaRa

	if($rsyncSet == "true") then
	#rsync
	echo running rsync on tile $RadecID
        set currIP = `curl ipecho.net/plain ; echo`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                echo On Tyto!
                
               #Transfer to Otus
		ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Otus $otus_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.75:$otus_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Otus $otus_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
               #Transfer to Athene
		ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Athene $athene_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.72:$athene_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Athene $athene_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/tyto1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/athene1/g'`
                echo On Otus!

                #transfer to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto
                #transfer to Athene
                echo rsync Otus\'s $CatWISEDir to Athene
        else if($currIP == "137.78.80.72") then #Athene
                echo On Athene!

                #transfer to Tyto
                echo rsync Athene\'s $CatWISEDir to Tyto
                #transfer to Otus
                echo rsync Athene\'s $CatWISEDir to Otus
        endif
	endif

end

#===============================================================================================================================================================

    echo
    goto Done




Mode3:

#===============================================================================================================================================================	
# links parent and wrapper dir to run "tcsh" and "source SORUCEME" in parent dir
# this assumes tcsh is installed
echo Creating temp files...
cd ..
tcsh & source SOURCEME && cd $wrapperDir

ParallelMode3:

        set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
        set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
        set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
	set OUTPUTdir = ${CatWISEDir}
        set TileDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/

        #Error Checking
        if(! -d $UnWISEDir) then
                echo ERROR: $UnWISEDir does not exist.
                echo
                echo Exiting...
                exit
        endif
        if(! -d $CatWISEDir) then
                echo $CatWISEDir does not exist. Creating $CatWISEDir
		mkdir -p $CatWISEDir
        endif
	echo UnWISEDir == $UnWISEDir
	echo CatWISEDir == $CatWISEDir
# loops through all of the tiles and executes icore


echo Wrapper now starting...

echo
echo

echo "NOTE: fbt3 and PSFavr8 will delete any existing PSFs you have in $TileDir"
echo 
echo "Do you want to run fbt3 and PSFavr8 (y/n)?"
set userInput = $<
if($userInput != "Y" && $userInput != "y") then
	echo going to start run with ICORE
        goto ICORE_Wrapper_Mode3
else 
	echo going to start run with MDET
	goto fbt3_PSFavr8_Wrapper_Mode3
endif


fbt3_PSFavr8_Wrapper_Mode3:
#===============================================================================================================================================================
#fbt3 and PSFavr8 Wrapper

echo
echo
echo 1\) fbt3 and PSFavr8 programs now starting...

 
		echo "--------------------------------------- start fbt3 and PSFavr8 wrapper ---------------------------------------"
		
		set preworkINPUTdir = ${UnWISEDir}
		echo fbt3 and PSFavr8 Input Dir === $preworkINPUTdir
		set preworkOUTPUTdir = ${CatWISEDir}

		if(`mkdir -p ${preworkOUTPUTdir}/ProgramTerminalOutput/`) then
                        echo creating ${preworkOUTPUTdir}/ProgramTerminalOutput/
                endif

		echo calling fbt3 and PSFavr8 on ${RadecID} tile
		
		if(`mkdir -p ${preworkOUTPUTdir}`) then
			echo Creating directory ${preworkOUTPUTdir}...
		endif
		if(`mkdir -p ${preworkOUTPUTdir}/Asce`) then
                        echo Creating directory ${preworkOUTPUTdir}/Asce...
                endif
		if(`mkdir -p ${preworkOUTPUTdir}/Desc`) then
                        echo Creating directory ${preworkOUTPUTdir}/Desc...
                endif
		#removes any existing psfs
		echo
	        echo Deleting any PSFs if they exist...	
		if ( `find ${preworkOUTPUTdir} -maxdepth 1 -type f -name "*psf*" | wc -l` > 0 ) then
     		   	echo PSFs found in ${preworkOUTPUTdir}. Deleting...
			rm -f ${preworkOUTPUTdir}/*psf*  
		else if ( `find ${preworkOUTPUTdir}/Asce/ -maxdepth 1 -type f -name "*psf*" | wc -l` > 0 ) then
                        echo ${preworkOUTPUTdir}/Asce/ has psfs. Deleting...
			rm -f ${preworkOUTPUTdir}/Asce/*psf*
		else if ( `find ${preworkOUTPUTdir}/Desc/ -maxdepth 1 -type f -name "*psf*" | wc -l` > 0 ) then
                        echo ${preworkOUTPUTdir}/Desc/ has psfs. Deleting...
			rm -f ${preworkOUTPUTdir}/Desc/*psf*
		endif

		 # fbt3 & PSFavr8 call
                (/Users/CatWISE/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w1-frames.fits ${preworkOUTPUTdir}/ProgramTerminalOutput/fbt3_w1.txt )
                (/Users/CatWISE/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w2-frames.fits ${preworkOUTPUTdir}/ProgramTerminalOutput/fbt3_w2.txt ) 
                (/Users/CatWISE/PSFavr8 -i /Users/CatWISE/Focal_Plane_PSFs -o $preworkOUTPUTdir -a1 ${preworkOUTPUTdir}/ProgramTerminalOutput/fbt3_w1.txt -a2 ${preworkOUTPUTdir}/ProgramTerminalOutput/fbt3_w2.txt -t $RadecID -da )

		echo fbt3 and PSFavr8 for ${RadecID} done!
		
		echo "---------------------------------------- end fbt3 and PSFavr8 wrapper ----------------------------------------"

#===============================================================================================================================================================

echo fbt3 and PSFavr8 wrapper finished!
echo

ICORE_Wrapper_Mode3:
#===============================================================================================================================================================

echo 2\) ICORE program now starting...


	
		echo "-------------------------------------------- start ICORE wrapper ---------------------------------------------"
		
		set INPUTdir = ${UnWISEDir}
		set OUTPUTdir = ${CatWISEDir}
		#InputsDir used for icore_template... TODO make sure template depents on INPUTdir instead...
		set InputsDir = $INPUTdir
		
		echo Current Input Directory === $INPUTdir
		echo Current Output Directory === $OUTPUTdir
		mkdir -p $OUTPUTdir
		mkdir -p ${OUTPUTdir}/ProgramTerminalOutput/
		#===============================================================================================================================================
	
		# Copies icore_template to make an icore_coadd script for w1 and w2
		# NOTE: this assumes "band" variable is in the 4th line of icore_template
		cp  ${wrapperDir}/icore_template.tcsh ${OUTPUTdir}/ProgramTerminalOutput/icore_coadd_w1
		cp  ${wrapperDir}/icore_template.tcsh ${OUTPUTdir}/ProgramTerminalOutput/icore_coadd_w2
		sed -i --follow-symlinks '4s/1/2/' ${OUTPUTdir}/ProgramTerminalOutput/icore_coadd_w2
	
		# Sources/Runs Wrapper executables (one for band 1, other for band 2)
		# This should run concurrently/in parallel
		echo Running ICORE for $RadecID
	
	        #TODO: output error message if this doesnt execute!
		echo Running ICORE for bands 1 and 2
		(source ${OUTPUTdir}/ProgramTerminalOutput/icore_coadd_w1 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w1_output.txt)
		(source ${OUTPUTdir}/ProgramTerminalOutput/icore_coadd_w2 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w2_output.txt)

	        if ($status != 0) then
		    echo ERROR: ICORE failed with an exit status of $status. Exitiing...
		    exit
                endif	    
	
		echo ICORE for $RadecID done!	
		echo "--------------------------------------------- end ICORE wrapper ----------------------------------------------"
		
#===============================================================================================================================================================

echo ICORE wrapper finished!
echo

#===============================================================================================================================================================
#MDET Wrapper

echo
echo
echo 3\) MDET program now starting...

		echo "--------------------------------------------- start MDET wrapper ---------------------------------------------"
		
		set MDETInputdir = ${CatWISEDir}
		echo MDET Input Dir === $MDETInputdir
		
		echo calling MDET on ${RadecID} tile
		
		echo MDET image1 location ${MDETInputdir}/mosaic-w1-int.fits	
		echo MDET image2 location ${MDETInputdir}/mosaic-w2-int.fits	

		# MDET call
		(${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -backwindow 400.0 -threshold $SNRthreshold -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 >& ${MDETInputdir}/ProgramTerminalOutput/mdet_output.txt)
	        if ($status != 0) then
		    echo ERROR: mdet failed with an exit status of $status. Exiting...
		    exit 
                endif	    
		
		echo MDET for ${RadecID} done!
		
		echo "---------------------------------------------- end MDET wrapper ----------------------------------------------"
#===============================================================================================================================================================
	#rsync folders from Tyto, Athene, Otus
	
	#TORSYNC
	#sync the detlist*****
	#sync the psf's (?) 

#===============================================================================================================================================================

	if($rsyncSet == "true") then
	#rsync
	echo running rsync on tile $RadecID
        set currIP = `curl ipecho.net/plain ; echo`
        echo current IP = $currIP
        if($currIP == "137.78.30.21") then #Tyto
                set otus_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/otus1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/CatWISE1/athene1/g'`
                echo On Tyto!
                
               #Transfer to Otus
		ssh ${user}@137.78.80.75 "mkdir -p $otus_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Otus $otus_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.75:$otus_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Otus $otus_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.75:$otus_CatWISEDir
               #Transfer to Athene
		ssh ${user}@137.78.80.72 "mkdir -p $athene_CatWISEDir"
                echo rsync Tyto\'s $CatWISEDir/detlist.tbl to Athene $athene_CatWISEDir
                rsync -avu  $CatWISEDir/detlist.tbl ${user}@137.78.80.72:$athene_CatWISEDir
                echo rsync Tyto\'s $CatWISEDir psfs to Athene $athene_CatWISEDir
                rsync -avu  --include "psf" $CatWISEDir ${user}@137.78.80.72:$athene_CatWISEDir
        else if($currIP == "137.78.80.75") then  #Otus
                set tyto_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/tyto1/g'`
                set athene_CatWISEDir = `echo $CatWISEDir | sed 's/otus1/athene1/g'`
                echo On Otus!

                #transfer to Tyto
                echo rsync Otus\'s $CatWISEDir to Tyto
                #transfer to Athene
                echo rsync Otus\'s $CatWISEDir to Athene
        else if($currIP == "137.78.80.72") then #Athene
                echo On Athene!

                #transfer to Tyto
                echo rsync Athene\'s $CatWISEDir to Tyto
                #transfer to Otus
                echo rsync Athene\'s $CatWISEDir to Otus
        endif
	endif

	echo MDET wrapper finished!
	echo
	goto Done

Done:		
# Deletes and cleans up files
cd $wrapperDir
echo Deleting Wrapper temp files...
source icore_cleanup_wrapper.tcsh
echo Done deleting!


#===============================================================================================================================================================
echo Wrapper finished!
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Ended at:
echo $endTime
echo
