;; warrenj 20150211 Routine to a flat field fits file.
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure. 




pro create_mflat, galaxy, OB, quadrant


;for quadrant = 1, 4 do begin

	str_quadrant = STRTRIM(STRING(quadrant),2)
        str_OB = STRTRIM(STRING(OB),2)
	dataset = '/Data/vimosindi/' + galaxy +'-' + str_OB + '/Q' + $
		str_quadrant
	
	files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
	

	ffiles = [files[2], files[3], files[4]]
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	mbias = FILE_SEARCH('/Data/vimosindi/' + galaxy +'-' + str_OB + $
		'/Bias/Q' + str_quadrant + '/*mbias' + str_quadrant + $
		'.fits') 
	tracemask  = FILE_SEARCH(dataset + '/*_trace' + str_quadrant + $
		'.fits') 
	dispmark = FILE_SEARCH(dataset + '/*_dmask' + str_quadrant + $
		'.fits')
	opath = dataset	
	userparfile = '/Data/vimosindi/user_p3d.dat' 
	detector = quadrant - 1
	
	p3d_cflatf, ffiles, parfile, masterbias=mbias, tracemask=tracemask, $
		dispmask = dispmask, userparfile=userparfile, opath=opath, $
		detector=detector, logfile=opath + '/dred.log', /crclean, $
		verbose = 0, /quiet


;endfor


return
end
