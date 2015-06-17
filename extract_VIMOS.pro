;; warrenj 20150211 Routine to extract the data from the images files
;; from VIMOS making use of the master bias, trace, dispersion mask
;; and flat field created in other routines.
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure. 





pro extract_VIMOS, galaxy, OB, quadrant


;for quadrant = 1, 4 do begin

	str_quadrant = STRTRIM(STRING(quadrant),2)
        str_OB = STRTRIM(STRING(OB),2)
	dataset = '/Data/vimosindi/' + galaxy +'-' + str_OB + $
		'/Q' + str_quadrant
	
	files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
	

	objectfiles = [files[0], files[1]]
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	bias = FILE_SEARCH('/Data/vimosindi/' + galaxy +'-' + str_OB + $
		'/Bias/Q' + str_quadrant + '/*mbias' + str_quadrant + $
		'.fits')
	tracemask  = FILE_SEARCH(dataset + '/*_trace' + str_quadrant + $
		'.fits')
	dispmask = FILE_SEARCH(dataset + '/*_dmask' + str_quadrant + $
		'.fits')
	flatfield = FILE_SEARCH(dataset + '/*_flatf' + str_quadrant + $
		'.fits')
	opath = dataset	
	userparfile = '/Data/vimosindi/user_p3d.dat' 
	detector = quadrant - 1


;; warrenj 20150211 Not sure if I need the skyline or not - it is also
;; 	given in the user parameter file and I would rather it was
;; 	only given in one place.  
;	skyalign = 5200 

	p3d_cobjex, objectfiles[0], parfile, masterbias=bias, $
		tracemask=tracemask, dispmask = dispmask, $
		flatfield=flatfield, $; skyalign = skyalign, $
		userparfile=userparfile, opath=opath, detector=detector, $
		logfile=opath + '/dred.log', /crclean, verbose = 0, /quiet

	p3d_cobjex, objectfiles[1], parfile, masterbias=bias, $
		tracemask=tracemask, dispmask = dispmask, $
		flatfield=flatfield, $; skyalign = skyalign, $
		userparfile=userparfile, opath=opath, detector=detector, $
		logfile=opath + '/dred.log', /crclean, verbose = 0, /quiet

;endfor


return
end





; CALLING SEQUENCE:
;         p3d_cobjex, filename, parfile, out, bswout, group=, masterbias=, $
;             tracemask=, dispmask=, flatfield=, bpmask=, crmask=, /biaspx, $
;             /biaspy, /biasox, /biasoy, biasconstant=, /savebiassub, $
;             waveprompt=, /drizzle, resample_startpx=, /originalerrors, $
;             skyalign=, /oneskyoffset, maxskyoffset=, /savee3d, /sbsw, $
;             userparfile=, /exmonitor, /compress, ofilename=, $
;             bsw_ofilename=, opath=, opfx=, detector=, logfile=, loglevel=, $
;             /cinv, recenterval=, recenterlimval=, /nf2f, pcutlow=, $
;             pcuthigh=, /scattlightsubtract, /savefinalflat, /satmask, $
;             crnthreads=, nthreads=, /allinone, /crclean, /nocrmask, $
;             sigclip=, objlim=, ratlim=, crfwhm=, gausskernelsize=, $
;             sigfrac=, growradius=, maxiter=, /imagemethod, /imageclean, $
;             dispmedian=, /writeall, /showcrgui, /nocrc, /noobcheck, $
;             cmdline=, /gui, stawid=, topwid=, logunit=, verbose=, $
;             /quiet, font=, error=, /debug, /help
