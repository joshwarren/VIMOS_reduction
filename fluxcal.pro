;; warrenj 20150204
;; Created for the purpose of running the flux calibrations using the
;; sensitivity function created from Feige 110.
;;
;; warrenj 20150209 
;; Edited with for loop to process all quadrants at once.
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure.   


pro fluxcal, galaxy, OB, quadrant



;for quadrant = 1, 4 do begin


	str_quadrant = STRTRIM(STRING(quadrant),2)
        str_OB = STRTRIM(STRING(OB),2)



	dataset='/Data/vimosindi/' + galaxy + '-' + str_OB + '/Q' + $
		str_quadrant
	FILE_MKDIR, dataset + '/calibrated'


	filename=FILE_SEARCH(dataset + '/*_crcl_oextr' + str_quadrant + $
		'.fits')
        parfile='/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
        findSensFunc=FILE_SEARCH('/Data/vimosindi/Feige110/Take2/Q' + $
		str_quadrant + '/fluxcal/*_fluxsens.fits')
;	findSensFunc = FILE_SEARCH('/Data/vimosindi/Feige110/test.fits')
        sensfunc = findSensFunc[0]
	extinctionfile='/Data/vimosindi/Feige110/Take2/FrancescoData/' + $
		'extinction_table.fits'
        opath=dataset + '/calibrated' 
        userparfile='/Data/vimosindi/user_p3d.dat' ; If you use this file







	p3d_fluxcal, filename, parfile, sensfunc=sensfunc, $
		extinctionfile=extinctionfile, detector = quadrant -1, $
		userparfile=userparfile, opath=opath, $
		logfile=opath + '/dred.log', verbose = 0, /quiet
;endfor




return
end


; CALLING SEQUENCE:
;         p3d_fluxcal, filename, parfile, out, dout, dfilename=, sensfunc=, $
;             extinctionfile=, airmass=, exptime=, ext_waveunit=, detector=, $
;             /compress, /savee3d, postable=, userparfile=, ofilename=, $
;             opath=, opfx=, /gui, /subroutine, logfile=, loglevel=, $
;             /allinone, cmdline=, stawid=, topwid=, logunit=, verbose=, $
;             /quiet, error=, /debug, /help
