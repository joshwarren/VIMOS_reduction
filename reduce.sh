#!/bin/bash


function readheader {
PYTHON_ARG="$1" python - <<END
import os
import pyfits
file = os.environ['PYTHON_ARG']
galaxy_data, header = pyfits.getdata(file, 0, header=True)
print header
END
}


pargal=NGC3100
ob=1

bias=false
setup=false
lamp=true
reduce=false
skysub=false
dar=false
combine=false
cube=false
scp=false

current=$( pwd )
cd

if [ "$bias" = true ] ; then
    for dir in $( ls -d vimos/$pargal/$ob/bias ) ; do
        cd $dir
        mkdir ../temp/
        night=$( find VIMOS_SPEC_BIAS*.fits | awk -F'_' '$3 ~ /BIAS/ {print $3}' | head -n1 | sed s/BIAS// )
#        Py3D vimos createBIAS $night
        cp BIAS* ../temp/
        cd
    done
fi


for dir in $( ls -d vimos/$pargal/$ob/ ) ; do
    cd $dir
    if [ "$setup" = true ] ; then
        Py3D vimos renameFiles 2012
        gzip VIMOS_IFU_OBS*
    fi
    night=$( find VIMOS_IFU_LAMP*.fits | awk -F'_' '$3 ~ /LAMP/ {print $3}' | head -n1 | sed s/LAMP// )
    numbers=$( find VIMOS_IFU_OBS*.fits.gz | awk -F'_' '// {print $4}' | sort -u )

    if [ "$setup" = true ] ; then cp VIMOS_IFU_* temp/ ; fi
    cd temp
    if [ "$lamp" = true ] ; then
        Py3D vimos combineLAMP $night
        Py3D vimos reduceCalibHR $night wave_start=4000 wave_end=5340 wave_disp=0.7 setup=blue master_trace=0 fiberflat=0 fiberflat_wave=1
    fi
    for num in $numbers ;  do
        gal=$( readheader VIMOS_IFU_OBS$night"_"$num"_"A.2.fits.gz | awk -F'OBJECT' '{print $2}' | awk -F\' '{print $2}' | sed 's/ //' | sed 's/ //' )
        if [ "$reduce" = true ] ; then
            Py3D vimos reduceObjectHR $night $gal"_"$num $num wave_start=4000 wave_end=5340 wave_disp=0.7 res_fwhm=2.5 setup=blue fiberflat=1 telluric_cor=0
        fi
        if [ "$skysub" = true ] ; then
            Py3D rss splitFibers $gal"_"$num.fobj.fits $gal"_"$num"_"Q1.fits,$gal"_"$num"_"Q2.fits,$gal"_"$num"_"Q3.fits,$gal"_"$num"_"Q4.fits QD1,QD2,QD3,QD4
            for Q in $( seq 1 4 ) ; do
                 Py3D rss constructSkySpec  $gal"_"$num"_"Q$Q.fits SKY_Q$Q"_"$num.fits nsky=60
                 Py3D rss subtractSkySpec $gal"_"$num"_"Q$Q.fits $gal"_"$num"_"skys_Q$Q.fits SKY_Q$Q"_"$num.fits
            done
            Py3D rss mergeRSS $gal"_"$num"_"skys_Q1.fits,$gal"_"$num"_"skys_Q2.fits,$gal"_"$num"_"skys_Q3.fits,$gal"_"$num"_"skys_Q4.fits $gal"_"$night"_"$num.sobj.fits mergeHdr=1
        fi
        if [ "$dar" = true ] ; then

            Py3D rss createCube $gal"_"$night"_"$num.sobj.fits $gal"_"$night"_"$num.sobj.cube.fits mode='drizzle' resolution=0.67

            Py3D cube measureDARPeak $gal"_"$night"_"$num.sobj.cube.fits DAR_$gal"_"$night"_"$num coadd=20  steps=20 fibers=1600 figure_out=$gal"_"$num"_"DAR_X.png
        fi



    done
    cd ../..
    if [ "$combine" = true ] ; then
        cp $( ls [1-3]/temp/*.sobj.fits ) ./
        cp $( ls [1-3]/temp/*.rss.cent_x.fits ) ./
        cp $( ls [1-3]/temp/*.rss.cent_y.fits ) ./

        numbers=$( ls *.sobj.fits | awk -F'[_.]' '{print $2}' )
        srss=""
        sxdar=""
        sydar=""
	for f in $( ls *.sobj.fits ) ; do
	    srss=$srss","$f
	done
	for f in $( ls *.rss.cent_x.fits ) ; do
	    sxdar=$sxdar","$f
	done
	for f in $( ls *.rss.cent_y.fits ) ; do
	    sydar=$sydar","$f
	done

        srss=$( echo $srss | cut -c 2- )
        sxdar=$( echo $sxdar | cut -c 2- )
        sydar=$( echo $sydar | cut -c 2- )
 
        Py3D rss mergeRSS $srss $gal"_"COMBINED_RSS.fits mergeHdr=0
        Py3D rss mergeRSS $sxdar $gal"_"COMBINED.cent_x.fits mergeHdr=0
        Py3D rss mergeRSS $sydar $gal"_"COMBINED.cent_y.fits mergeHdr=0


       Py3D rss createCube $gal"_"COMBINED_RSS.fits "${gal,,}".cube.combined.fits position_x=$gal"_"COMBINED.cent_x.fits position_y=$gal"_"COMBINED.cent_y.fits ref_pos_wave=5000 mode='drizzle' resolution=0.67 full_field=1
    fi


    if [ "$cube" = true ] ; then
       cp "${gal,,}".cube.combined.fits ../../cubes/
    fi

    if [ "$scp" = true ] ; then
        scp "${gal,,}".cube.combined.fits warrenj@asosx146.nat.physics.ox.ac.uk:/Data/vimos/$gal/
    fi
    cd
done










cd $current