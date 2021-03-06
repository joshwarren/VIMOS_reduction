;; warrenj 20150323 Routine to reduce the spectrum of Feige 110




pro fluxcalstar, num_quadrant

	quadrant = STRTRIM(STRING(num_quadrant),2)


	userparfile='/Data/vimosindi/user_p3d.dat'
	detector = num_quadrant - 1
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'

	dataset = '/Data/vimosindi/Feige110/Take2/'



;;=========================== Bias ============================
	bfiles = FILE_SEARCH(dataset + 'Bias/Q' + quadrant + $
		'/*[0-9][0-9].[0-9][0-9][0-9].fits')
	

	opath = dataset + 'Bias/Q' + quadrant


	p3d_cmbias, bfiles, parfile, userparfile = userparfile, $
		opath=opath, detector=detector, logfile=opath+'/dred.log', $
		verbose = 0, /quiet


	mbias = FILE_SEARCH(dataset + 'Bias/Q' + quadrant + '/*mbias' + $
		quadrant + '.fits')

;;=========================== Trace ============================
	files = FILE_SEARCH(dataset + 'Flats/Q' + quadrant + $
		'/*[0-9][0-9].[0-9][0-9][0-9].fits')
	
	ffiles = [files[0], files[1], files[2]]
	opath = dataset + 'Flats/Q' + quadrant


	p3d_ctrace, ffiles, parfile, masterbias = mbias, $
		userparfile = userparfile, opath=opath, detector=detector, $
		logfile=opath+'/dred.log', /crclean, verbose = 0, /quiet

	tracemask  = FILE_SEARCH(dataset + 'Flats/Q' + quadrant + $
		'/*_trace' + quadrant + '.fits')

;;======================= Dispersion Mask ======================


	dfiles = files[3]


	p3d_cdmask, dfiles, parfile, masterbias=mbias, tracemask=tracemask, $
		userparfile=userparfile, $ ;arclinelist = arclinelist, $
		opath=opath, detector=detector, logfile=opath + '/dred.log', $
		verbose = 0, /quiet


	dispmask = FILE_SEARCH(dataset + 'Flats/Q' + quadrant + $
		'/*_dmask' + quadrant + '.fits')


;;========================= Flat Field =============================
	
	ffiles = [files[0], files[1], files[2]]


	p3d_cflatf, ffiles, parfile, masterbias=mbias, tracemask=tracemask, $
		dispmask = dispmask, userparfile=userparfile, opath=opath, $
		detector=detector, logfile=opath + '/dred.log', /crclean, $
		verbose = 0, /quiet


	flatfield = FILE_SEARCH(dataset + 'Flats/Q' + quadrant + '/*_flatf' $
		+ quadrant + '.fits')


;;========================== Extract Image ============================


	objectfiles = FILE_SEARCH(dataset + 'Q' + quadrant + $
		'/*_[0-9][0-9].[0-9][0-9][0-9].fits')

	opath = dataset + 'Q' + quadrant

	p3d_cobjex, objectfiles[num_quadrant - 1], parfile, masterbias=mbias, $
		tracemask=tracemask, dispmask = dispmask, $
		flatfield=flatfield, $; skyalign = skyalign, $
		userparfile=userparfile, opath=opath, detector=detector, $
		logfile=opath + '/dred.log', /crclean, verbose = 0, /quiet



	reducedstarfiles = FILE_SEARCH(dataset + 'Q' + quadrant + $
		'/*_crcl_oextr' + quadrant  + '.fits')


;;====================== Sensitivity Function =====================

;
;	ssfile_cal = dataset + 'FrancescoData/feige110.fits'
;	extinctionfile = dataset + 'FrancescoData/extinction_table.fits'
;	opath = dataset + 'Q' + quadrant + '/fluxcal'
;
;
;	p3d_fluxsens, reducedstarfiles, parfile, ssfile_cal=ssfile_cal, $
;		extinctionfile=extinctionfile, /psplot, detector = detector, $
;		waveunit = 'angstrom', fluxunit = 'erg/cm/cm/s/A*10**-16', $
;		userparfile=userparfile, opath=opath, $
;		logfile=opath + '/dred.log', /verbose, /quiet 
;
;
;






return

end
