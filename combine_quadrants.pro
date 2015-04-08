;; warrenj 20150209
;; Create for the prupose of running the combination routine from p3d
;; which includes renormalising to a telluric line - given in user
;; parmater file.
;; This routine also includes methods to separate observations within
;; an OB.


pro combine_quadrants, galaxy, OB


;galaxy = 'ngc3557'
;OB = '1'

dataset = '/Data/vimosindi/' + Galaxy + '-' + OB
	files = FILE_SEARCH(dataset + '/Q?/calibrated/*fluxcal*.fits')



	files1 = [files[0], files[2], files[4], files[6]]
	files2 = [files[1], files[3], files[5], files[7]]

FILE_MKDIR, dataset + '/combined'

        parfile='/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset  + '/combined'
	userparfile = '/Data/vimosindi/user_p3d.dat'

;	ofilename = Galaxy + '-' + OB + 'combined1'




;print, files[0]
;print, files[1]
;print, files[2]
;print, files[3]
;print, files[4]
;print, files[5]
;print, files[6]
;print, files[7]





	p3d_cvimos_combine, files1, parfile, userparfile=userparfile, $
;	ofilename=ofilename, 
	opath=opath, logfile=opath + '/comb.log', $
	/quiet

		

;	ofilename = Galaxy + '-' + OB + 'combined2'

	p3d_cvimos_combine, files2,  parfile, userparfile=userparfile, $
;	ofilename=ofilename, 
	opath=opath, logfile=opath + '/comb.log', $
	/quiet



return
end
