#! /bin/tcsh -f

# CatWISE band number: 1 OR 2: 
set band = 1

echo Running ICORE for band ${band}...

#===========================================================================

# Creating input file lists using input folders, extracting the file names to a txt file: 
mkdir -p ${OUTPUTdir}/ProgramTerminalOutput/Lists
set psf_list_file = ${OUTPUTdir}/ProgramTerminalOutput/Lists/PSFs_list_w${band}.txt
set int_list_file = ${OUTPUTdir}/ProgramTerminalOutput/Lists/img_list_w${band}.txt
set unc_list_file = ${OUTPUTdir}/ProgramTerminalOutput/Lists/unc_list_w${band}.txt

# NOTE: this extraction assumes that ALL files follow the same format. Please name files accordingly.
# This will delete the previous list files. They will be deleted b/c they take up unnecessary space.

#below will take the psf out of each tile... if its the same psf, can't we just have the psf in the ONE folder? vvv
find ${OUTPUTdir} -type f | grep unwise-w${band}-psf-awaic-01x01-01x01.fits  > ${psf_list_file}
#find ${OUTPUTdir} -type f | grep unWISE-w${band}-psf-wpro-01x01-01x01.fits  > ${psf_list_file}
#find ${OUTPUTdir} -type f | grep w${band}-psf-  > ${psf_list_file}
#find ${INPUTdir} -type f | grep w${band}-psf-  > ${psf_list_file}

find ${INPUTdir} -type f | grep w${band}-img-u > ${int_list_file}
find ${INPUTdir} -type f | grep w${band}-std-u > ${unc_list_file}
#find ${INPUTdir} -type f | grep w${band}-img-m > ${int_list_file}
#find ${INPUTdir} -type f | grep w${band}-std-m > ${unc_list_file}
#===========================================================================
#modhead fix
set intImageFileName = `head -n1 ${int_list_file}`
set modHeadOuptut = `${wrapperDir}/modhead ${intImageFileName} band`
if ("$modHeadOuptut" == 'Keyword does not exist') then
	echo BAND keyword did not exist in ${intImageFileName}. 
	echo Adding BAND keyword now... 
	chmod u+w ${intImageFileName}
	${wrapperDir}/modhead ${intImageFileName} band ${band}
	chmod u-w ${intImageFileName}
endif
 
# takes ra and dec from fits headers
set Header = "`echo ${intImageFileName} | xargs head -n1`"
#echo Header === "$Header"
 
# Right Ascension of footprint center [deg]:
set ra = `echo "$Header" | awk 'match($0,"CRVAL1"){print RSTART}'   | awk -v headerString="$Header" '{print substr(headerString,$0 + 20,10)}'`
#echo CRVAL TEST
#${wrapperDir}/modhead ${intImageFileName} crval1 | sed "s/CRVAL1.*=/ /"
# Declination of footprint center [deg]:
set dec = `echo "$Header" | awk 'match($0,"CRVAL2"){print RSTART}'   | awk -v headerString="$Header" '{print substr(headerString,$0 + 20,10)}'`
#${wrapperDir}/modhead ${intImageFileName} crval2 | sed "s/CRVAL2.*=/ /"

#Calling Icore:
#===========================================================================

# WISE observations of Spiral Galaxy IC342. Generic script to create 
# coadd for any WISE band [see icore_hires_wise for HiRes'ing]. 
# For details, see the README file in the root directory where you
# installed ICORE.

#===========================================================================
# primary I/O: footprint geometry, files and output dir.
 
#band, ra, and dec are defined in above code

# Rotation of footprint: +Y axis W of N: 0 <= rot < 360 [deg]:
set rot = 0

# E-W footprint dimension for rot = 0 [deg]:
set sx = 1.564444

# N-S footprint dimension for rot = 0 [deg]:
set sy = 1.564444

# Filename containing list of input intensity frames:
set inimglist = $int_list_file

# Filename containing list of input mask frames (if available):
#set inmsklist = $msk_list_file

# Filename containing list of input uncertainty frames (if available):
set inunclist = $unc_list_file

# Filename containing PRF image file (only used if sccoad=0 below):
set inpsflist = $psf_list_file

# Output directory name for products:
set outdir = ${OUTPUTdir}

# if want area-overlap weighted coadd, set sccoad=1, otherwise set to 0 to
# use PRF listed above as interpolation kernel. For sccoad=1, drizzle factor
# "-d_coad" below [default=1] may be of interest:
set sccoad = 0 

# Number of concurrent threads to run (for speed). Set to number of
# CPU cores available on your machine.
set nthreads = 24 
#===========================================================================

# Band dependent parameters, optimized for WISE:

if( $band == 1 ) then
  set magzp = 20.5;
  set paodet = 2.73;
  set pbodet = 20;
  set ratmax = 2.2;
  set bmatch = 1;
  set bmeth = 2;
  set gausize = 699;
  set gausigm = 174;
  set clsig = 8;
  set tlodet = 16.0;
  set tuodet = 14.0;
  set tsodet = 8.0;
  set tnodet = 350000;
  set tgodet = 200000;
  set tsatodet = 464000;
  set neiodet = 10;
  set nszodet = 5;
  set expodet = 11;
  set mcoad = 405273647;
else if( $band == 2 ) then
  set magzp = 19.5;
  set paodet = 2.73;
  set pbodet = 20;
  set ratmax = 1.4;
  set bmatch = 1;
  set bmeth = 2;
  set gausize = 699;
  set gausigm = 174;
  set clsig = 8;
  set tlodet = 16.0;
  set tuodet = 14.0;
  set tsodet = 8.0;
  set tnodet = 350000;
  set tgodet = 200000;
  set tsatodet = 464000;
  set neiodet = 10;
  set nszodet = 5;
  set expodet = 11;
  set mcoad = 405273647;
else
  echo "\n*** Band not recognized; quitting...\n";
  exit;
endif

#------------------------------------------------------------------------
# execute icore.

icore \
               -imglist $inimglist \
#              -msklist $inmsklist \
               -unclist $inunclist \
               -psflist $inpsflist \
               -outdir  $outdir \
               -qameta  $outdir/qametrics.tbl \
               -qagrid  3 \
               -sizeX $sx \
               -sizeY $sy \
               -ra  $ra \
               -dec $dec \
               -rot $rot \
               -nthreads $nthreads \
# other coadd generation parameters: \
               -m_coad $mcoad \
# following are all saturation bits: \
               -ms_coad 523264 \
               -pa_coad 1.375 \
               -pc_coad 0.5 \
               -ct_coad 0.0001 \
               -wf_coad 0 \
               -sf_coad 1 \
               -sc_coad $sccoad \
               -d_coad 1.0 \
               -n_coad 1 \
               -rf_coad 0 \
               -if_coad 0  \
               -crep_coad 0 \
               -cmin_coad 4 \
               -o1_coad $outdir/mosaic-w${band}-int.fits \
               -o2_coad $outdir/mosaic-w${band}-cov.fits \
               -o3_coad $outdir/mosaic-w${band}-unc.fits \
# various switches: \
               -coadd \
               -v \
               -sv

#===========================================================================
#fixes permissions on Inputs/lists and outdir
chmod 775 ${OUTPUTdir}/ProgramTerminalOutput/Lists ; chmod 664 ${OUTPUTdir}/ProgramTerminalOutput/Lists/*
chmod 775 $outdir ; chmod 764 $outdir/*

#===========================================================================
echo Successfully ran ICORE for band ${band}!
