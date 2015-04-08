;; warrenj 20150217 Routine to call p3d_rss2cube.pro to change the
;; final image into a datacube format [x, y, λ]


pro rss2cube, galaxy, OB


	dataset = '/Data/vimosindi/' + galaxy +'-' + OB

FILE_MKDIR, dataset + '/Final'

	files = FILE_SEARCH(dataset + '/combined/combined_exposures/*.fits')
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset + '/Final'
	userparfile = '/Data/vimosindi/user_p3d.dat'


FITS_READ, files[0], templates, header
	wavestart = sxpar(header,'CRVAL2')
	waveend = sxpar(header,'CDELT2')*sxpar(header,'NAXIS2') + $
		sxpar(header,'CRVAL2')

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
