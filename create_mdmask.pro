;; warrenj 20150211 A routine to create a master dipersion mask from
;; the arc lamp observations. 
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure. 






pro create_mdmask, galaxy, OB, quadrant


;for quadrant = 1, 4 do begin


	str_quadrant = STRTRIM(STRING(quadrant),2)
        str_OB = STRTRIM(STRING(OB),2)
	dataset = '/Data/vimosindi/' + galaxy +'-' + str_OB + '/Q' + $
		str_quadrant
	
	files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
;FILE_MKDIR, dataset + '/dtest'	

	dfiles = files[5]
	parfile = '/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
	mbias = FILE_SEARCH('/Data/vimosindi/' + galaxy +'-' + $
		str_OB + '/Bias/Q' + str_quadrant + '/*mbias' + $
		str_quadrant + '.fits') 
	tracemask  = FILE_SEARCH(dataset + '/*_trace' + str_quadrant + '.fits')
	opath = dataset	;+ '/dtest'
	userparfile = '/Data/vimosindi/user_p3d.dat' 
	detector = quadrant - 1
;	arclinelist = '/Data/idl_libraries/p3d/data/tables/linelists/vimos_hr-blue.dat'





	p3d_cdmask, dfiles, parfile, masterbias=mbias, tracemask=tracemask, $
		userparfile=userparfile, $ ;arclinelist = arclinelist, $
		opath=opath, detector=detector, logfile=opath + '/dred.log', $
;		/crclean, $
		verbose = 0, /quiet 



;endfor






return
end




; CALLING SEQUENCE:
;         p3d_cdmask, filename, parfile, saved, out, masterbias=, tracemask=, $
;             dispmaskin=, bpmask=, crmask=, /biaspx, /biaspy, /biasox, $
;             /biasoy, biasconstant=, /savebiassub, userparfile=, $
;             arclinefile=, ofilename=, opath=, opfx=, detector=, dbin=, $
;             track=, /exmonitor, /compress, logfile=, loglevel=, /gui, $
;             /cinv, /satmask, crnthreads=, nthreads=, /allinone, 
;
;	/crclean, $
;             /nocrmask, sigclip=, objlim=, ratlim=, crfwhm=, $
;             gausskernelsize=, sigfrac=, growradius=, maxiter=, $
;             /imagemethod, /imageclean, dispmedian=, /writeall, /showcrgui, $
;             /nocrc, 
;		
;	cmdline=, eventwid=, stawid=, topwid=, logunit=, $
;             verbose=, /noobcheck, /quiet, font=, error=, $
;             /debug, /help, _extra=
