;; warrenj 20150217 Routine to call p3d_rss2cube.pro to change the
;; final image into a datacube format [x, y, λ]
;;
;; warrenj 20150520 Altered to fit with the changes to
;; combine_exposures routine. 



pro rss2cube, galaxy


	dataset = '/Data/vimosindi/reduced/' + galaxy + '/combined_exposures'
FILE_MKDIR, '/Data/vimosindi/reduced/' + galaxy + '/cube'

	files = FILE_SEARCH(dataset + '/*_ins.fits', count=c)
	if c eq 0 then files = FILE_SEARCH(dataset + '/*.fits')
	parfile = '/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = '/Data/vimosindi/reduced/' + galaxy + '/cube'
	userparfile = '/Data/vimosindi/user_p3d.dat'


FITS_READ, files[0], templates, header
	wavestart = sxpar(header,'CRVAL2')
	waveend = sxpar(header,'CDELT2')*sxpar(header,'NAXIS2') + $
		sxpar(header,'CRVAL2')

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH('/Data/vimosindi/reduced/' + galaxy + $
	'/cube/*_cube.fits')
if old[0] ne "" then FILE_DELETE, old



	p3d_rss2cube, files, parfile, wavestart = wavestart, $
		waveend = waveend, userparfile=userparfile, opath=opath, $
		logfile=opath + '/dred.log', $;allinone = 0, $
		verbose = 0, /quiet



return 
end



; CALLING SEQUENCE:
;         p3d_rss2cube, filename, parfile, out, dout, pixstart=, pixend=, $
;             wavestart=, waveend=, postable=, rightascension=, declination=, $
;             ra_offset=, dec_offset=, spaxelscale=, detector=, /compress, $
;             userparfile=, ofilename=, opath=, opfx=, logfile=, loglevel=, $
;             /allinone, cmdline=, /gui, /subroutine, stawid=, $
;             topwid=, logunit=, verbose=, /quiet, error=, /debug, /help
