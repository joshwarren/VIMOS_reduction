;; warrenj 20150217 Routine to use p3d_cexposure.pro to combine the
;; two extracted science exposures in each OB.

pro combine_exposures, galaxy, OB



	dataset = '/Data/vimosindi/' + galaxy +'-' + OB + '/combined'
FILE_MKDIR, dataset + '/combined_exposures'



	files = FILE_SEARCH(dataset + '/*_darc.fits')
	parfile = '/Data/p3d/data/instruments/vimos/bvimos_hr.prm'
	opath = dataset + '/combined_exposures'
	userparfile = '/Data/vimosindi/user_p3d.dat'

	p3d_cexposure, files, parfile, pixrange = 40, $
		userparfile=userparfile, opath=opath, $
		logfile=opath + '/dred.log', verbose = 0, /quiet





return
end
