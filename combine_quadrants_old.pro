;; warrenj 20150209
;; Create for the prupose of running the combination routine from p3d
;; which includes renormalising to a telluric line - given in user
;; parmater file.
;; This routine also includes methods to separate observations within
;; an OB.


pro combine_quadrants_old, galaxy, OB, method


;galaxy = 'ngc3557'
;OB = '1'
        str_OB = STRTRIM(STRING(OB),2)

	dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB


if method eq "telluric" then begin
    files = FILE_SEARCH(dataset + '/Q?/calibrated/*fluxcal*.fits')
endif else if method eq "nofcdgoodnorm" then begin
    files = FILE_SEARCH(dataset + '/Q?/*_crcl_oextr?.fits')
endif


	files1 = [files[0], files[2], files[4], files[6]]
	files2 = [files[1], files[3], files[5], files[7]]

FILE_MKDIR, dataset + '/combined'

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH(dataset + '/combined/*')
if old[0] ne "" then FILE_DELETE, old

        parfile='/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
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

f=file_search('/Data/vimosindi/ngc1399-2/combined/*_oextr1_vmcmb.fits')	
fits_read, f[0], check, header	
print, header

return
end
