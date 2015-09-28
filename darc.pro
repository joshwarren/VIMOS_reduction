;; warrenj 20150217 routine to run p3d_darc.pro: a correction for
;; Differential Atmospheric Refraction (DAR)


pro darc, galaxy, OB

        str_OB = STRTRIM(STRING(OB),2)

	dataset = '/Data/vimosindi/' + galaxy +'-' + str_OB + $
		'/combined'

	files = FILE_SEARCH(dataset + '/VIMOS*vmcmb.fits')
	parfile = '/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset
	userparfile = '/Data/vimosindi/user_p3d.dat'


;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH(dataset + '/*_darc*')
if old ne "" then FILE_DELETE, old


	p3d_darc, files, parfile, /nogui, userparfile=userparfile, $
		opath=opath, logfile=opath + 'dred.log', verbose = 0, /quiet




return
end

; CALLING SEQUENCE:
;         p3d_darc, filename, parfile, out, method=, refwl=, spaxelscale=, $
;             posang=, airmass=, parang=, pressure=, temperature=, $
;             relhumidity=, latitude=, obselevation=, templapserate=, $
;             empiricalfit=, fitx0=, fity0=, ra_offset=, dec_offset=, /nogui, $
;             postable=, deadfibersfile=, /nomask, maskval=, /masklowtr, $
;             /compress, /savee3d, userparfile=, ofilename=, opath=, opfx=, $
;             detector=, nthreads=, logfile=, loglevel=, /cinv, /allinone, $
;             cmdline=, /gui, /subroutine, stawid=, topwid=, $
;             logunit=, verbose=, /quiet, font=, error=, /debug, /help
