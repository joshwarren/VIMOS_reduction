;; warrenj 20150306 Process to create a master bias from the given bais
;; frames.
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure. 


pro create_mbias, galaxy, OB, quadrant

;for quadrant = 1, 4 do begin

	str_quadrant = STRTRIM(STRING(quadrant),2)
	str_OB = STRTRIM(STRING(OB),2)
	dataset = '/Data/vimosindi/' + galaxy +'-' + str_OB + $
		'/bias/Q' + str_quadrant


	bfiles = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
	
	parfile = '/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset
	detector = quadrant - 1
	userparfile='/Data/vimosindi/user_p3d.dat'

;print, files[2] + files[3] + files[4]
	p3d_cmbias, bfiles, parfile, userparfile = userparfile, $
		opath=opath, detector=detector, logfile=opath+'/dred.log', $
		verbose = 0, /quiet

;endfor







	return
end

; CALLING SEQUENCE:
;         p3d_cmbias, filename, parfile, out, /nodialog, userparfile=, $
;             ofilename=, opath=, opfx=, detector=, /compress, nthreads=, $
;             logfile=, loglevel=, cmdline=, /gui, stawid=, topwid=, $
;             logunit=, verbose=, /quiet, error=, /debug, /help
