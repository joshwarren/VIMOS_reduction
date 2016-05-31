#!/bin/bash
cd
bias=false
lamp=true



if [ "$bias" = true ] ; then
    for dir in $( ls -d */[1-3]/bias ) ; do
        cd $dir
        mkdir ../temp/
        night=$( find VIMOS_SPEC_BIAS*.fits | awk -F'_' '$3 ~ /BIAS/ {print $3}' | head -n1 | sed s/BIAS// )
        Py3D vimos createBIAS $night
        cp BIAS* ../temp/
        cp ../../../feige110/ratio* ../temp/
        cd ../../../
    done
fi



if [ "$lamp" = true ] ; then
    for dir in $( ls -d vimos/*/[1-3]/ ) ; do
        cd $dir
#        Py3D vimos renameFiles 2012
        gzip VIMOS_IFU_OBS*
        night=$( find VIMOS_IFU_LAMP*.fits | awk -F'_' '$3 ~ /LAMP/ {print $3}' | head -n1 | sed s/LAMP// )
        numbers=$( find VIMOS_IFU_OBS*.fits.gz | awk -F'_' '// {print $4}' | sort -u )

        cp VIMOS_IFU_* temp/
        cd temp
        Py3D vimos combineLAMP $night
        Py3D vimos reduceCalibHR $night wave_start=4000 wave_end=5340 wave_disp=0.7 setup=blue master_trace=0 fiberflat=0 fiberflat_wave=1
        for num in $numbers ;  do
            gal=$( readheader VIMOS_IFU_OBS$night"_"$num"_"A.2.fits.gz | awk -F'OBJECT' '{print $2}' | awk -F\' '{print $2}' )
            Py3D vimos reduceObjectHR $night $gal"_"$num $num wave_start=4000 wave_end=5340 wave_disp=0.7 res_fwhm=2.5 setup=blue fiberflat=1 telluric_cor=0
            mkdir ../../$gal
#            cp $gal"_"$num.fobj.fits ../../$gal"_"$night"_"$num.fobj.fits
        done

        cd
    done
fi



function readheader {
PYTHON_ARG="$1" python - <<END
import os
import pyfits
file = os.environ['PYTHON_ARG']
galaxy_data, header = pyfits.getdata(file, 0, header=True)
print header
END
}





