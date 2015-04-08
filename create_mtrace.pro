;; warrenj 20150210 Created to create the master trace for the given
;; galaxy and OB.
;;
;; warrenj 20150324
;; Edited to just complete one quadrant: loop is run in
;; reduce_VIMOS. This is better as it gives more control within that
;; procedure. 



pro create_mtrace, galaxy, OB, quadrant

;for quadrant = 1, 4 do begin

	str_quadrant = STRTRIM(STRING(quadrant),2)
	dataset = '/Data/vimosindi/' + galaxy +'-' + OB + '/Q' + str_quadrant


	files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
	
	ffiles = [files[2], files[3], files[4]]
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset
	mbias = FILE_SEARCH('/Data/vimosindi/' + galaxy +'-' + OB + '/Bias/Q' $
		+ str_quadrant + '/*mbias' + str_quadrant + '.fits')
	detector = quadrant - 1
	userparfile='/Data/vimosindi/user_p3d.dat'

;print, files[2] + files[3] + files[4]
	p3d_ctrace, ffiles, parfile, masterbias = mbias, $
		userparfile = userparfile, opath=opath, detector=detector, $
		logfile=opath+'/dred.log', /crclean, verbose = 0, /quiet

;endfor







return
end
; p3d_ctrace,filename,parfile,out,masterbias=,/biaspx,/biaspy, $
;             /biasox,/biasoy,biasconstant=,/savebiassub,userparfile=, $
;             ofilename=,opath=,opfx=,detector=,/exmonitor,crnthreads=, $
;             nthreads=,/compress,logfile=,loglevel=,detsepgrp=,detsepnum=, $
;             /gui,/subroutine,/cinv,/crclean,sigclip=,objlim=,ratlim=, $
;             crfwhm=,gausskernelsize=,sigfrac=,growradius=,maxiter=, $
;             /imagemethod,/imageclean,dispmedian=,/writeall,/showcrgui, $
;             /nocrc,/allinone,cmdline=,stawid=,topwid=,logunit=,verbose=, $
;             /quiet,font=,error=,/debug,/help
