;; warrenj 20150217 Routine to use p3d_cexposure.pro to combine the
;; two extracted science exposures in each OB.
;;
;; warrenj 2015 Altered to combine all exposures from all three OBs,
;; not just the 2 exposures from a single OB.

pro combine_exposures, galaxy



	dataset = '/Data/vimosindi/' + galaxy +'-' + '[1-3]/combined'
FILE_MKDIR, '/Data/vimosindi/reduced/' + galaxy + '/combined_exposures'



	files = FILE_SEARCH(dataset + '/*_darc.fits')
	parfile = '/Data/idl_libraries/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = '/Data/vimosindi/reduced/' + galaxy + '/combined_exposures'
	userparfile = '/Data/vimosindi/user_p3d.dat'



;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH('/Data/vimosindi/reduced/' + galaxy + $
	'/combined_exposures/*_cexp.fits')
FILE_DELETE, old


	p3d_cexposure, files, parfile, pixrange = 40, $
		userparfile=userparfile, opath=opath, $
		logfile=opath + '/dred.log', verbose = 0, /quiet





return
end
