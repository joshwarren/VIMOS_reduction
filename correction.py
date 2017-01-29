## ==================================================================
## 		Correcting the fringe-like pattern
## ==================================================================
## warrenj 20160304 Routine based on A&A 541. A82 (2012)
## warrenj 20170127 Ported to python to be applied at the end of the 
##	reduction after Py3D reduction pipeline. Also includes port of 
##	combine_quadrants.pro.

import numpy as np
from astropy.io import fits
from lowess import lowess
from checkcomp import checkcomp
cc = checkcomp()


def correction(galaxy):
	f = fits.open('%s/Data/vimos/cubes/%s.cube.combined.fits' % (cc.base_dir, galaxy))

	ifu = f[0].data
	ifu_uncert = f[1].data
	head = f[0].header

	s = size(ifu)

	##************ Does this need to be for un-wavelength calibrated rss? - or will 
	##	calibrated rss do? And if so - for each obs too? ***************************
	i, id, x, y = np.loadtxt('%s/libraries/IDL/p3d/data/instruments/' % (cc.home_dir)
		'vimos/vimos_positions_rer.dat')

	for OB in range(4):
		
		#med_ifu = np.zeros((s[0], s[1]/2, s[2]/2))
		med_ifu = np.zeros(s)

		## set up array to give number of adjacent cells. 
		n_adjacent = np.ones((s[1],s[2]))*8
		n_adjacent[[0,s[1]],:] = 5
		n_adjacent[:,[0,s[2]]] = 5
		n_adjacent[[0,0,s[1],s[1]],[0,s[2],0,s[2]]] = 3

		for i in range(s[1]):
			for j in range(s[2]):
			if n_adjacent[i,j] == 8: # Middle spaxels
					adjacent_x = [i+1,i+1,i+1,i,i,i-1,i-1,i-1]
					adjacent_y = [j+1,j,j-1,j+1,j-1,j+1,j,j-1]
					med_ifu[:,i,j] = np.median(ifu[:,adjacent_x,adjacent_y], axis=(1,2))
				elif n_adjacent[i,j] == 5: # Edges
					if i == 0: # First column
						adjacent_x = [i+1,i+1,i+1,i,i]
						adjacent_y = [j+1,j,j-1,j+1,j-1]
					elif i == s[1]-1: # Last column
						adjacent_x = [i-1,i-1,i-1,i,i]
						adjacent_y = [j+1,j,j-1,j+1,j-1]
					elif j == 0: # Top row
						adjacent_x = [i+1,i+1,i,i-1,i-1]
						adjacent_y = [j+1,j,j+1,j+1,j]
					elif j == s[2]-1: # Bottom row
						adjacent_x = [i+1,i+1,i,i-1,i-1]
						adjacent_y = [j-1,j,j-1,j-1,j]
					med_ifu[:,i,j] = np.median(ifu[:,adjacent_x,adjacent_y], axis=(1,2))
				else: # Corners
					med_ifu[:,i,j] = np.ones(s[0])
			

		med_ifu[np.where(med_ifu == 0)] = 1
		# l = np.where(med_ifu != 0)

		correction = ifu/med_ifu
		#correction[l] = ifu[l]/med_ifu[l]

		for i in range(s[1]):
			for j in range(s[2]):
		#	lowess2, indgen(s[2]), reform(correction[i,j,*], s[2]), 150, y_new, order=2
			y_new = lowess(indgen(s[2]), reform(correction[i,j,*], s[2]), 150, 2)
			correction[i,j,*]=y_new


		#for i = 0, max(x)-1 do begin
		#    for j = 0, max(y)-1 do begin
		#       CALL_EXTERNAL('~/IDL_Library/fortran/lowess.so', 'lowess_warapper_', $
		#		indgen(s[2]), reform(correction[i,j,*], s[2]), 1, $
		#		150.0/2800.0, 2, y_new, rw, res)
		#    endfor # j
		#endfor # i


		## Finally correct the spectrum
		correction[where(correction eq 0)-1] = 1
		correction[where(correction eq 0)+1] = 1
		correction[where(correction eq 0)] = 1
		ifu = ifu/correction
		ifu_uncert /=correction

		#ifu[where(ifu eq 1)+1] = !VALUES.F_NAN
		#ifu[where(ifu eq 1)-1] = !VALUES.F_NAN
		#ifu[where(ifu eq 1)] = !VALUES.F_NAN


		## Convert back to RSS format
		for i = 0 , s[1]-1 do begin
			rss_data[i,*] = ifu[x[i]-1,y[i]-1,*]
			rss_data_uncert[i,*] = ifu_uncert[x[i]-1,y[i]-1,*]
		endfor # i

		## Clear old files incase file name has changed so future routines are
		## not confused by old files.
		old = FILE_SEARCH(dataset + '/*_darc*')
		if old[0] ne "" then FILE_DELETE, old


		## Writting the fits file
		a = strsplit(files1, '/', /extract)
		file = strmid(a[-1],0 , strlen(a[-1])-5)

		f=dataset + '/' + file + '_cor.fits'
		FITS_OPEN,f,fcb, /write

		GET_DATE, dte
		sxaddpar, header, 'DATE', dte # Today's date

		fits_write,fcb,rss_data, header,extver=1 
		fits_write,fcb,rss_data_uncert, header_uncert,extname='ERROR',extver=1

		w = where(finite(ifu), nCOMPLEMENT=count)
		if count ne 0 then message, 'NAN present at end', /continue



	## ************ Includes port of corrections made in combine_quadrants.pro. ****