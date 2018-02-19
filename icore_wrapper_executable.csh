#! /bin/tcsh -fe

#===============================================================================================================================================================

set wrapperDir = $PWD
set startTime = `date '+%m/%d/%Y %H:%M:%S'`
echo 
echo Wrapper Started at:
echo $startTime
echo
echo Version 2.01 
echo
echo This Wrapper will wrap around and run these 3 programs:
#echo This Wrapper will wrap around and run these 4 programs:
echo 1\) fbt3 and PSFavr8
echo 2\) ICORE
echo 3\) MDET
#echo 4\) WPHOTPMC
#echo ================================================================================================================
#echo WARNING\: Elijah is doing testing\/editing to this program \(Oct10 2017\). This script will not work propperly.
#echo ================================================================================================================

if ($# != 3) then
	#Error handling
	#Too many or too little arguments	
	echo "ERROR: not enough arguments:"
	echo "Parameters for wrapper must be in the order:"
	echo 1\) Mode 1 2 or 3 \(1 == Input directory, 2 == Input listof Tiles, 2 == Single Tile\)
	echo 2\) Input directory or list or Parent Directory
	echo 3\) Output directory or Tile Name
	echo "i.e. './icore_wrapper_executable.csh option InputDir/List OutputDir'" 
	echo 
	echo Exiting...
	exit 
#Mode1 Everything Mode
else if ($1 == 1) then
	set InputsDir = $2
	set OutputsDir = $3
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
	if (! -d $OutputsDir) then
		echo ERROR: Output Directory $OutputsDir does not exist.
		echo	
		echo Exiting...
		exit
	endif
	
	goto Mode1
#Mode2 List of Tiles Mode
else if ($1 == 2) then
		set InputsList = $2
        set OutputsDir = $3
        echo Inputs list ==  $InputsList
        echo Outputs directory == $OutputsDir
		echo
        echo "Is this the correct input list and output directory? (y/n)"
        set userInput = $<
 	
	#Error handling
        #if user input dir wrong
        if($userInput != "Y" && $userInput != "y") then
                echo Please execute program again with full Input List file as the 2nd parameter and the Ouput Directory path as your 3rd parameter
                #TODO actually throw an error instead of just outputing to stdout... output to stderr
                echo
                echo Exiting...
                exit
        endif
        #if directories dont exist, throw error
        if(! -f $InputsList) then
                echo ERROR: Input List file $InputsDir doest not exist.
                echo
                echo Exiting...
                exit
        endif
        if (! -d $OutputsDir) then
                echo ERROR: Output Directory $OutputsDir does not exist.
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
        echo "Is this the correct Parent Directory  and Tile Name? (y/n)"
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
	echo ERROR mode 1, 2, or 3 not selected
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
#===============================================================================================================================================================
#fbt3 and PSFavr8 Wrapper

echo
echo
echo 1\) fbt3 and PSFavr8 programs now starting...

#TESTING
#while
foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile
	
	foreach RadecIDDir ($RaRaRaDir*/)
	
		echo =============================== start fbt3 and PSFavr8  wrapper loop iteration =================================
 
		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
		@ tempIndex = ($tempSize - 8)
		set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	
		echo $RadecIDDir
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID
	
		echo "--------------------------------------- start fbt3 and PSFavr8 wrapper ---------------------------------------"
		
		set preworkINPUTdir = ${FulldepthDir}${RaRaRa}/${RadecID}/
		echo fbt3 and PSFavr8 Input Dir === $preworkINPUTdir
		set preworkOUTPUTdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/

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


		# fbt3 call
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w1-frames.fits fbt3_w1.txt &
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w2-frames.fits fbt3_w2.txt &
	        if ($status != 0) then
		    echo fbt3 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		wait
		#PSFavr8
		/Volumes/CatWISE1/jwf/src/PSFavr8/PSFavr8 -i /Volumes/CatWISE1/jwf/Focal_Plane_PSFs -o $preworkOUTPUTdir -a1 fbt3_w1.txt -a2 fbt3_w2.txt -t $RadecID -da &
	        if ($status != 0) then
		    echo PSFavr8 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		
			
		#TODO  make sure the PSF input in icore_template matches with the output file name in psfavr8
			

		#Stops calling programs if number of scripts running is greater than number of threads on CPU
                while(`ps -ef | grep PSFavr8 | wc -l` > 12)
                        #echo IM WATING
			#do nothing
                end
		
		echo fbt3 and PSFavr8 for ${RadecID} done!
		
		echo "---------------------------------------- end fbt3 and PSFavr8 wrapper ----------------------------------------"
		echo ================================ end fbt3 and PSFavr8 wrapper loop iteration =================================
	end
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo fbt3 and PSFavr8 wrapper finished!
echo

ICORE_Wrapper_Mode1:
#===============================================================================================================================================================

echo 2\) ICORE programs now starting...

foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile
	
	foreach RadecIDDir ($RaRaRaDir*/)

		echo ===================================== start ICORE wrapper loop iteration =====================================

		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
		@ tempIndex = ($tempSize - 8)
		set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
		echo Current Directory running Wrapper == $RadecIDDir
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID
	
		echo "-------------------------------------------- start ICORE wrapper ---------------------------------------------"
		
		set INPUTdir = ${FulldepthDir}${RaRaRa}/${RadecID}/
		set OUTPUTdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/
		
		echo Current Input Directory === $INPUTdir
		echo Current Output Directory === $OUTPUTdir
		mkdir -p $OUTPUTdir
		mkdir -p ${OUTPUTdir}/ProgramTerminalOutput/
		#===============================================================================================================================================
	
		# Copies icore_template to make an icore_coadd script for w1 and w2
		# NOTE: this assumes "band" variable is in the 4th line of icore_template
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w1
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w2
		sed -i --follow-symlinks '4s/1/2/' ${wrapperDir}/icore_coadd_w2
	
		# Sources/Runs Wrapper executables (one for band 1, other for band 2)
		# This should run concurrently/in parallel
		echo Running ICORE for $RadecID
	
	        #TODO: output error message if this doesnt execute!
		echo Running ICORE for bands 1 and 2 in PARALLEL
		(source ${wrapperDir}/icore_coadd_w1 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w1_output.txt) & 
		(source ${wrapperDir}/icore_coadd_w2 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w2_output.txt) & 
#		wait

	        if ($status != 0) then
		    echo ERROR: ICORE failed with an exit status of $status. Exitiing...
		    exit
                endif	    
		#echo running ICORE for bands 1 and 2 in GNU PARALLEL
		#parallel ::: 'source ${wrapperDir}/icore_coadd_w2 |& tee ${OUTPUTdir}/wrapper_w2_output.txt' 'source ${wrapperDir}/icore_coadd_w2 |& tee ${OUTPUTdir}/wrapper_w2_output.txt' 
		#(echo '"source '$wrapperDir'/icore_coadd_w1 |& tee '$OUTPUTdir'/wrapper_w1_output.txt"' ; echo '"source '$wrapperDir'/icore_coadd_w2 |& tee '$OUTPUTdir'/wrapper_w2_output.txt\"') | parallel
		#echo done with GNU parallel		
	
		#TODO run in parallel! Fix the background not closing problem
		#echo running ICORE for bands 1 and 2 in SERIES
		#(source ${wrapperDir}/icore_coadd_w1 |& tee "$OUTPUTdir"/wrapper_w1_output.txt)   
		#(source ${wrapperDir}/icore_coadd_w2 |& tee "$OUTPUTdir"/wrapper_w2_output.txt) 
	
		#Stops calling programs if number of scripts running is greater than number of threads on CPU
		while(`ps -ef | grep icore_coadd_w | wc -l` > 12)
                	#do nothing
        	end
			
		echo ICORE for $RadecID done!	
		echo "--------------------------------------------- end ICORE wrapper ----------------------------------------------"
		
		echo ====================================== end ICORE wrapper loop iteration ======================================
	end
end
#===============================================================================================================================================================

#wait for background processes to finish
wait
echo ICORE wrapper finished!
echo

#===============================================================================================================================================================
#MDET Wrapper

echo
echo
echo 3\) MDET programs now starting...

foreach RaRaRaDir ($FulldepthDir*/) #for each directory in FulldepthDir, get each RadecIDdir, run wrapper on RadecID tile
	
	foreach RadecIDDir ($RaRaRaDir*/)
	
		echo ===================================== start MDET wrapper loop iteration ======================================
 
		set tempSize = `echo $RadecIDDir  | awk '{print length($0)}'`
		@ tempIndex = ($tempSize - 8)
		set RadecID = `echo $RadecIDDir | awk -v startIndex=$tempIndex '{print substr($0,startIndex,8)}'`
		set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
	
		echo $RadecIDDir
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID
	
		echo "--------------------------------------------- start MDET wrapper ---------------------------------------------"
		
		set MDETInputdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/
		echo MDET Input Dir === $MDETInputdir
		
		echo calling MDET on ${RadecID} tile
			
		# MDET call
		(${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -backwindow 400.0 -threshold 2.40 -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 >& ${MDETInputdir}/ProgramTerminalOutput/mdet_output.txt) &	
	        if ($status != 0) then
		    echo ERROR: mdet failed with an exit status of $status. Exiting...
		    exit 
                endif	    
		# MDET with Masks	
		#${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -cmask1 ${MDETInputdir}/1124p045_ac51-w1-cmsk-3.fits -cmask2 ${MDETInputdir}1124p045_ac51-w2-cmsk-3.fits -backwindow 400.0 -threshold 2.40 -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 	
		
		#Stops calling programs if number of scripts running is greater than number of threads on CPU
                while(`ps -ef | grep mdet | wc -l` > 12)
                        #echo IM WATING
			#do nothing
                end
		
		echo MDET for ${RadecID} done!
		
		echo "---------------------------------------------- end MDET wrapper ----------------------------------------------"
		echo ====================================== end MDET wrapper loop iteration =======================================
	end
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo MDET wrapper finished!
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

echo "NOTE: fbt3 and PSFavr8 will delete any existing PSFs you have in $OutputsDir"
echo 
echo "Do you want to run fbt3 and PSFavr8 (y/n)?"
set userInput = $<
if($userInput != "Y" && $userInput != "y") then
        goto ICORE_Wrapper_Mode2
else 
	goto fbt3_PSFavr8_Wrapper_Mode2
endif


fbt3_PSFavr8_Wrapper_Mode2:
#===============================================================================================================================================================
#fbt3 and PSFavr8 Wrapper

echo
echo
echo 1\) fbt3 and PSFavr8 programs now starting...

#TESTING
#while
foreach line (`cat $InputsList`)
	
		echo =============================== start fbt3 and PSFavr8  wrapper loop iteration =================================
 
		set RaRaRa =  `echo $line | awk -F "/" '{print $(NF-1)}'`
		set RadecID = `echo $line | awk -F "/" '{print $(NF)}'`
		
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID

		echo "--------------------------------------- start fbt3 and PSFavr8 wrapper ---------------------------------------"
		
		set preworkINPUTdir = $line
		echo fbt3 and PSFavr8 Input Dir === $preworkINPUTdir
		set preworkOUTPUTdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/

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
#		if (`ls ${preworkOUTPUTdir}*psf* >& /dev/null`)  then
#			echo PSFs exist in ${preworkOUTPUTdir} 
#			echo Deleting PSF files now...
#			rm -f ${preworkOUTPUTdir}*psf*               
#		else if (`ls ${preworkOUTPUTdir}/Asce/*psf* >& /dev/null`) then 
#			echo PSFs exist in ${preworkOUTPUTdir}/Asce/ 
#			echo Deleting PSF files now...
#			rm -f ${preworkOUTPUTdir}/Asce/*psf*
#		else if (`ls ${preworkOUTPUTdir}/Desc/*psf* >& /dev/null`) then 
#			echo PSFs exist in ${preworkOUTPUTdir}/Desc/ 
#			echo Deleting PSF files now...
#			rm -f ${preworkOUTPUTdir}/Desc/*psf*
#		endif
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


		# fbt3 call
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w1-frames.fits fbt3_w1.txt &
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w2-frames.fits fbt3_w2.txt &
	        if ($status != 0) then
		    echo fbt3 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		wait
		#PSFavr8
		/Volumes/CatWISE1/jwf/src/PSFavr8/PSFavr8 -i /Volumes/CatWISE1/jwf/Focal_Plane_PSFs -o $preworkOUTPUTdir -a1 fbt3_w1.txt -a2 fbt3_w2.txt -t $RadecID -da &
	        if ($status != 0) then
		    echo PSFavr8 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		
			
		#TODO  make sure the PSF input in icore_template matches with the output file name in psfavr8
			

		#Stops calling programs if number of scripts running is greater than number of threads on CPU
                while(`ps -ef | grep PSFavr8 | wc -l` > 12)
                        #echo IM WATING
			#do nothing
                end
		
		echo fbt3 and PSFavr8 for ${RadecID} done!
		
		echo "---------------------------------------- end fbt3 and PSFavr8 wrapper ----------------------------------------"
		echo ================================ end fbt3 and PSFavr8 wrapper loop iteration =================================
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo fbt3 and PSFavr8 wrapper finished!
echo

ICORE_Wrapper_Mode2:
#===============================================================================================================================================================

echo 2\) ICORE programs now starting...

foreach line (`cat $InputsList`)
		echo ===================================== start ICORE wrapper loop iteration =====================================

		set RaRaRa =  `echo $line | awk -F "/" '{print $(NF-1)}'`
		set RadecID = `echo $line | awk -F "/" '{print $(NF)}'`
		
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID
		
		echo "-------------------------------------------- start ICORE wrapper ---------------------------------------------"
		
		set inputdir = $line
		set OUTPUTdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/
		
		echo Current Input Directory === $line
		echo Current Output Directory === $OUTPUTdir
		mkdir -p $OUTPUTdir
		mkdir -p ${OUTPUTdir}/ProgramTerminalOutput/
		#===============================================================================================================================================
	
		# Copies icore_template to make an icore_coadd script for w1 and w2
		# NOTE: this assumes "band" variable is in the 4th line of icore_template
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w1
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w2
		sed -i --follow-symlinks '4s/1/2/' ${wrapperDir}/icore_coadd_w2
	
		# Sources/Runs Wrapper executables (one for band 1, other for band 2)
		# This should run concurrently/in parallel
		echo Running ICORE for $RadecID
	
	        #TODO: output error message if this doesnt execute!
		echo Running ICORE for bands 1 and 2 in PARALLEL
		(source ${wrapperDir}/icore_coadd_w1 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w1_output.txt) & 
		(source ${wrapperDir}/icore_coadd_w2 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w2_output.txt) & 
#		wait

	        if ($status != 0) then
		    echo ERROR: ICORE failed with an exit status of $status. Exitiing...
		    exit
                endif	    
		#echo running ICORE for bands 1 and 2 in GNU PARALLEL
		#parallel ::: 'source ${wrapperDir}/icore_coadd_w2 |& tee ${OUTPUTdir}/wrapper_w2_output.txt' 'source ${wrapperDir}/icore_coadd_w2 |& tee ${OUTPUTdir}/wrapper_w2_output.txt' 
		#(echo '"source '$wrapperDir'/icore_coadd_w1 |& tee '$OUTPUTdir'/wrapper_w1_output.txt"' ; echo '"source '$wrapperDir'/icore_coadd_w2 |& tee '$OUTPUTdir'/wrapper_w2_output.txt\"') | parallel
		#echo done with GNU parallel		
	
		#TODO run in parallel! Fix the background not closing problem
		#echo running ICORE for bands 1 and 2 in SERIES
		#(source ${wrapperDir}/icore_coadd_w1 |& tee "$OUTPUTdir"/wrapper_w1_output.txt)   
		#(source ${wrapperDir}/icore_coadd_w2 |& tee "$OUTPUTdir"/wrapper_w2_output.txt) 
	
		#Stops calling programs if number of scripts running is greater than number of threads on CPU
		while(`ps -ef | grep icore_coadd_w | wc -l` > 12)
                	#do nothing
        	end
			
		echo ICORE for $RadecID done!	
		echo "--------------------------------------------- end ICORE wrapper ----------------------------------------------"
		
		echo ====================================== end ICORE wrapper loop iteration ======================================
end
#===============================================================================================================================================================

#wait for background processes to finish
wait
echo ICORE wrapper finished!
echo

#===============================================================================================================================================================
#MDET Wrapper

echo
echo
echo 3\) MDET programs now starting...

	
foreach line (`cat $InputsList`)	
		echo ===================================== start MDET wrapper loop iteration ======================================
 
		set RaRaRa =  `echo $line | awk -F "/" '{print $(NF-1)}'`
		set RadecID = `echo $line | awk -F "/" '{print $(NF)}'`
		
		echo "RaRaRa == "$RaRaRa
		echo "RadecID == "$RadecID
	
		echo "--------------------------------------------- start MDET wrapper ---------------------------------------------"
		
		set MDETInputdir = ${OutputsDir}/${RaRaRa}/${RadecID}/Full/
		echo MDET Input Dir === $MDETInputdir
		
		echo calling MDET on ${RadecID} tile
			
		# MDET call
		(${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -backwindow 400.0 -threshold 2.40 -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 >& ${MDETInputdir}/ProgramTerminalOutput/mdet_output.txt) &	
	        if ($status != 0) then
		    echo ERROR: mdet failed with an exit status of $status. Exiting...
		    exit 
                endif	    
		# MDET with Masks	
		#${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -cmask1 ${MDETInputdir}/1124p045_ac51-w1-cmsk-3.fits -cmask2 ${MDETInputdir}1124p045_ac51-w2-cmsk-3.fits -backwindow 400.0 -threshold 2.40 -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 	
		
		#Stops calling programs if number of scripts running is greater than number of threads on CPU
                while(`ps -ef | grep mdet | wc -l` > 12)
                        #echo IM WATING
			#do nothing
                end
		
		echo MDET for ${RadecID} done!
		
		echo "---------------------------------------------- end MDET wrapper ----------------------------------------------"
		echo ====================================== end MDET wrapper loop iteration =======================================
end

#===============================================================================================================================================================

#wait for background processes to finish
wait
echo MDET wrapper finished!
echo
goto Done

Mode3:
        set RaRaRa = `echo $RadecID | awk '{print substr($0,0,3)}'`
        set UnWISEDir = $ParentDir/UnWISE/$RaRaRa/$RadecID/
        set CatWISEDir = $ParentDir/CatWISE/$RaRaRa/$RadecID/Full/
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

echo "NOTE: fbt3 and PSFavr8 will delete any existing PSFs you have in $TileDir"
echo 
echo "Do you want to run fbt3 and PSFavr8 (y/n)?"
set userInput = $<
if($userInput != "Y" && $userInput != "y") then
        goto ICORE_Wrapper_Mode3
else 
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


		# fbt3 call
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w1-frames.fits fbt3_w1.txt
		/Volumes/CatWISE1/jwf/src/fbt3/fbt3 ${preworkINPUTdir}/unwise-${RadecID}-w2-frames.fits fbt3_w2.txt
	        if ($status != 0) then
		    echo fbt3 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		wait
		#PSFavr8
		/Volumes/CatWISE1/jwf/src/PSFavr8/PSFavr8 -i /Volumes/CatWISE1/jwf/Focal_Plane_PSFs -o $preworkOUTPUTdir -a1 fbt3_w1.txt -a2 fbt3_w2.txt -t $RadecID -da 
	        if ($status != 0) then
		    echo PSFavr8 failed with an exit status of $status. Exiting...
		    exit
                endif	    
		
			
		#TODO  make sure the PSF input in icore_template matches with the output file name in psfavr8

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
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w1
		cp  ${wrapperDir}/icore_template.csh ${wrapperDir}/icore_coadd_w2
		sed -i --follow-symlinks '4s/1/2/' ${wrapperDir}/icore_coadd_w2
	
		# Sources/Runs Wrapper executables (one for band 1, other for band 2)
		# This should run concurrently/in parallel
		echo Running ICORE for $RadecID
	
	        #TODO: output error message if this doesnt execute!
		echo Running ICORE for bands 1 and 2 in PARALLEL
		(source ${wrapperDir}/icore_coadd_w1 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w1_output.txt)
		(source ${wrapperDir}/icore_coadd_w2 >& ${OUTPUTdir}/ProgramTerminalOutput/icore_w2_output.txt)

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
		(${wrapperDir}/mdet -image1 ${MDETInputdir}/mosaic-w1-int.fits -image2 ${MDETInputdir}/mosaic-w2-int.fits -sigimage1 ${MDETInputdir}/mosaic-w1-unc.fits -sigimage2 ${MDETInputdir}/mosaic-w2-unc.fits -backwindow 400.0 -threshold 2.40 -m -c -outlist ${MDETInputdir}/detlist.tbl -fwhm1 6.000 -fwhm2 6.000 >& ${MDETInputdir}/ProgramTerminalOutput/mdet_output.txt)
	        if ($status != 0) then
		    echo ERROR: mdet failed with an exit status of $status. Exiting...
		    exit 
                endif	    
		
		echo MDET for ${RadecID} done!
		
		echo "---------------------------------------------- end MDET wrapper ----------------------------------------------"

#===============================================================================================================================================================

echo MDET wrapper finished!
echo
goto Done

Done:		
# Deletes and cleans up files
cd $wrapperDir
echo Deleting Wrapper temp files...
source icore_cleanup_wrapper.csh
echo Done deleting!


#===============================================================================================================================================================
echo Wrapper finished!
set endTime = `date '+%m/%d/%Y %H:%M:%S'`
echo
echo Wrapper Ended at:
echo $endTime
echo
