;; warrenj 20150204
;; Created for the purpose of running the flux calibrations using the
;; sensitivity function created from Feige 110.
pro fluxcal

galaxy = 'ngc3557'
OB = '1'
quadrant = '4'

dataset='/Data/vimosindi/' + galaxy + '-' + OB + '/Q' + quadrant



FILE_MKDIR, dataset + '/calibrated'

filename=FILE_SEARCH(dataset + '/*_crcl_oextr' + quadrant + '.fits')
         parfile='/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
         sensfunc='/Data/vimosindi/Feige110/Take2/Q' + quadrant + '/*_crcl_oextr' + quadrant + '_fluxsens.fits'
         extinctionfile='/Data/vimosindi/Feige110/Take2/FrancescoData/extinction_table.fits'
         opath=dataset + '/calibrated/' 
;		opfx='testthiscal2'
		quiet='1'
         userparfile='/Data/vimosindi/user_p3d.dat' ; If you use this file
	p3d_fluxcal, filename, parfile, sensfunc=sensfunc, $
             extinctionfile=extinctionfile, quiet=quiet, $
	     userparfile=userparfile, opfx=opfx, opath=opath, $
	     logfile=opath + 'dred.log', /verbose


return
end


