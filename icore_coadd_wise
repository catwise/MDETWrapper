#! /bin/tcsh -f

# WISE observations of Spiral Galaxy IC342. Generic script to create 
# coadd for any WISE band [see icore_hires_wise for HiRes'ing]. 
# For details, see the README file in the root directory where you
# installed ICORE.

#========================================================================
# primary I/O: footprint geometry, files and output dir.

# WISE band number: 1,2,3,4: 
set band = 1

# Right Ascension of footprint center [deg]:
set ra = 56.70208333

# Declination of footprint center [deg]:
set dec = 68.09611111

# Rotation of footprint: +Y axis W of N: 0 <= rot < 360 [deg]:
set rot = 199.5

# E-W footprint dimension for rot = 0 [deg]:
set sx = 0.4

# N-S footprint dimension for rot = 0 [deg]:
set sy = 0.4

# Filename containing list of input intensity frames:
set inimglist = wise/ImageList${band}.txt

# Filename containing list of input mask frames (if available):
set inmsklist = wise/MaskList${band}.txt

# Filename containing list of input uncertainty frames (if available):
set inunclist = wise/UncertList${band}.txt

# Filename containing PRF image file (only used if sccoad=0 below):
set inpsflist = wise/PRFList_coad${band}.txt

# Output directory name for products:
set outdir = wise/outputs_coad${band}

# if want area-overlap weighted coadd, set sccoad=1, otherwise set to 0 to
# use PRF listed above as interpolation kernel. For sccoad=1, drizzle factor
# "-d_coad" below [default=1] may be of interest:
set sccoad = 0

# Number of concurrent threads to run (for speed). Set to number of
# CPU cores available on your machine.
set nthreads = 8
#========================================================================

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
else if( $band == 3 ) then
  set magzp = 18.0;
  set paodet = 2.73;
  set pbodet = 20;
  set ratmax = 1.2;
  set bmatch = 1;
  set bmeth = 2;
  set gausize = 699;
  set gausigm = 174;
  set clsig = 8;
  set tlodet = 12.0;
  set tuodet = 7.0;
  set tsodet = 8.0;
  set tnodet = 400000;
  set tgodet = 200000;
  set tsatodet = 464000;
  set neiodet = 7;
  set nszodet = 5;
  set expodet = 13;
  set mcoad = 405273647;
else if( $band == 4 ) then
  set magzp = 13.0;
  set paodet = 5.43;
  set pbodet = 36;
  set ratmax = 1.13;
  set bmatch = 1;
  set bmeth = 2;
  set gausize = 341;
  set gausigm = 87;
  set clsig = 8;
  set tlodet = 12.0;
  set tuodet = 7.0;
  set tsodet = 8.0;
  set tnodet = 100000;
  set tgodet = 70000;
  set tsatodet = 116000;
  set neiodet = 7;
  set nszodet = 5;
  set expodet = 13;
  set mcoad = 405273647;
else
  echo "\n*** Band not recognized; quitting...\n";
  exit;
endif

#------------------------------------------------------------------------
# execute icore.

icore \
               -imglist $inimglist \
               -msklist $inmsklist \
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
\
# outlier detection parameters: \
#               -pa_odet $paodet \
#               -pb_odet $pbodet \
#               -nx_odet 1 \
#               -ny_odet 1 \
              # -tl_odet $tlodet \
              # -tu_odet $tuodet \
              # -ts_odet $tsodet \
              # -ta_odet 0.26 \
              # -r_odet 2.0 \
              # -s_odet 1.0 \
              # -b_odet 0 \
              # -h_odet 1 \
              # -k_odet 3.0 \
              # -q_odet 5.0 \
              # -w_odet 3 \
              # -d_odet 1 \
              # -ns_odet 5 \
              # -ip_odet 1 \
              # -is_odet 2000.0 \
              # -m_odet 134217728 \
              # -mg_odet 268435456 \
              # -tn_odet $tnodet \
              # -tg_odet $tgodet \
              # -tsat_odet $tsatodet \
              # -nei_odet $neiodet \
              # -nsz_odet $nszodet \
              # -exp_odet $expodet \
              # -om_odet $outdir/mosaic-msk.fits \
              # -nmaxodet 500 \
\
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
               -if_coad 0 \
               -crep_coad 0 \
               -cmin_coad 4 \
               -o1_coad $outdir/mosaic-int.fits \
               -o2_coad $outdir/mosaic-cov.fits \
               -o3_coad $outdir/mosaic-unc.fits \
\
# following made for -sc_coad 1 only: \
#               -o4_coad $outdir/mosaic-std.fits \
\
# following for PRF-interp coadd only: \
#               -om_coad $outdir/mosaic-cmsk.fits \
\
# following can be slow (depends on svbgrid) \
#               -snu_coad $outdir/mosaic-snrunc.fits \
\
# following used to compute Slowly Varying Background for -snu_coad; \
 #              -svbgrid 3 \
  #             -gausize $gausize \
   #            -gausigm $gausigm \
\
# following switch is to use modes instead of medians when computing Slowly \
# Varying Background over -svbgrid: \
    #           -modfilt \
\
# following used for -bmatch=1 and -bmeth=0 only: \
     #          -ratmax $ratmax \
\
# following used to compute minimum median bckgnd over "-bgrid x -bgrid" in \
# frame if extended structure detected using -ratmax parameter under \
# -bmatch=1 and -bmeth=0 only \
      #         -bgrid 8 \
\
# target photometric zero-point [mag] to rescale inputs to if tmatch switch \
# below is set; also keyword names storing the input image zero-points and \
# their uncertainties: \
       #        -magzp $magzp \
        #       -magzpk MAGZP \
         #      -magzpuk MAGZPUNC \
\
# if -bmatch 1 => perform background matching using method: \
# bmeth=0 => robust planar fitting; bmeth=1 => generic surface fit of \
# order "-order" to frame pre-binned into -bfgrid x -bfgrid squares and \
# values > mode + clsig*sigma clipped; bmeth=2 => global minimization of \
# offset differences between all frame overlaps \
          #     -bmatch $bmatch \
           #    -bmeth $bmeth \
\
# next 3 params are for -bmeth=1: \
            #   -order 2 \
             #  -bfgrid 9 \
              # -clsig $clsig \
\
# next 4 params are for -bmeth=2: \
       #        -reimg \
       #        -refac 4 \
       #        -edgw 10 \
               -offtol 1000 \
\
# various switches: \
        #       -tmatch \
       #        -odet \
      #         -expodet \
       #        -partition \
       #        -cpmsk \
               -coadd \
        #       -qa \
#               -dbg \
#               -sdbg \
         #      -v \
          #     -sv

