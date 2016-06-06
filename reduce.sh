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



cd
pargal=*

bias=false
setup=false
lamp=false
reduce=false
skysub=false
cube=false
dar=true


if [ "$bias" = true ] ; then
    for dir in $( ls -d vimos/*/bias ) ; do
        cd $dir
        mkdir ../temp/
        night=$( find VIMOS_SPEC_BIAS*.fits | awk -F'_' '$3 ~ /BIAS/ {print $3}' | head -n1 | sed s/BIAS// )
#        Py3D vimos createBIAS $night
        cp BIAS* ../temp/
        cd
    done
fi


for dir in $( ls -d vimos/$pargal/[1-3]/ ) ; do
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
            mkdir ../../$gal
            cp $gal"_"$num.fobj.fits ../../$gal"_"$night"_"$num.fobj.fits
        fi
        if [ "$skysub" = true ] ; then
            echo $gal"_"$num.fobj.fits
            Py3D rss splitFibers $gal"_"$num.fobj.fits $gal"_"$num"_"Q1.fits,$gal"_"$num"_"Q2.fits,$gal"_"$num"_"Q3.fits,$gal"_"$num"_"Q4.fits QD1,QD2,QD3,QD4
            for Q in $( seq 1 4 ) ; do
                 Py3D rss constructSkySpec  $gal"_"$num"_"Q$Q.fits SKY_Q$Q"_"$num.fits nsky=60
                 Py3D rss subtractSkySpec $gal"_"$num"_"Q$Q.fits $gal"_"$num"_"skys_Q$Q.fits SKY_Q$Q"_"$num.fits
            done
        fi
        if [ "$cube" = true ] ; then
            Py3D rss mergeRSS $gal"_"$num"_"skys_Q1.fits,$gal"_"$num"_"skys_Q2.fits,$gal"_"$num"_"skys_Q3.fits,$gal"_"$num"_"skys_Q4.fits $gal"_"$num.sobj.fits mergeHdr=1
            Py3D rss createCube $gal"_"$num.sobj.fits $gal"_"$num.sobj.cube.fits mode='drizzle' resolution=0.67
        fi
        if [ "$dar" = true ] ; then
            Py3D cube measureDARPeak $gal"_"$num.sobj.cube.fits DAR_$gal"_"$num coadd=20  steps=20 fibers=1400 figure_out=$gal"_"$num"_"DAR_X.png
        fi



    done

    cd
done
