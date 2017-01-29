## ==================================================================
## 		Correcting the fringe-like pattern
## ==================================================================
## warrenj 20160304 Routine based on A&A 541. A82 (2012)
## warrenj 20170127 Ported to python to be applied at the end of the 
##	reduction after Py3D reduction pipeline. Also includes port of 
##	combine_quadrants.pro.

import numpy as np
import os
from astropy.io import fits
#from lowess import lowess
from statsmodels.nonparametric.smoothers_lowess import lowess
from checkcomp import checkcomp
cc = checkcomp()


def correction(galaxy):
	f = fits.open('%s/Data/vimos/cubes/%s.cube.combined.fits' % (cc.base_dir, galaxy))

	ifu = f[0].data
	ifu_uncert = f[1].data

	s = ifu.shape
		
	med_ifu = np.zeros(s)

	## set up array to give number of adjacent cells. 
	n_adjacent = np.ones((s[1], s[2]))*8
	n_adjacent[[0, s[1]-1], :] = 5
	n_adjacent[:, [0, s[2] - 1]] = 5
	n_adjacent[[0, 0, s[1] - 1, s[1] - 1], [0, s[2] - 1,0 , s[2] - 1]] = 3

	for i in range(s[1]):
		for j in range(s[2]):
			if n_adjacent[i,j] == 8: # Middle spaxels
				adjacent_x = [i+1,i+1,i+1,i,i,i-1,i-1,i-1]
				adjacent_y = [j+1,j,j-1,j+1,j-1,j+1,j,j-1]
				med_ifu[:,i,j] = np.median(ifu[:,adjacent_x,adjacent_y], axis=(1,))
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
				med_ifu[:,i,j] = np.median(ifu[:,adjacent_x,adjacent_y], axis=(1,))
			else: # Corners
				med_ifu[:,i,j] = np.ones(s[0])
		

	med_ifu[np.where(med_ifu == 0)] = 1

	correction = ifu/med_ifu

	for i in range(s[1]):
		for j in range(s[2]):
			y_new = lowess(correction[:,i,j], np.arange(s[0]), frac=150/s[0], it=2, 
				return_sorted=False)
			# y_new = lowess(np.arange(s[0]), correction[:,i,j], 150/s[0], iter=2)
			correction[:,i,j] = y_new

	## Finally correct the spectrum
	# correction[np.where(correction == 0)-1] = 1
	# correction[np.where(correction == 0)+1] = 1
	# correction[np.where(correction == 0)] = 1
	ifu /= correction
	ifu_uncert /=correction


	## ************ Includes port of corrections made in combine_quadrants.pro. ****

	## Position angle check
	
	Q1 = ifu[:, 20:40, 20:40]
	Q2 = ifu[:, 0:20, 20:40]
	Q3 = ifu[:, 0:20, 0:20]
	Q4 = ifu[:, 20:40, 0:20]

	## Finding constants c1, c2 and c3
	y1 = np.nansum(Q1[:,0,:])
	y2 = np.nansum(Q2[:,19,:])
	y3 = np.nansum(Q3[:,19,:])
	y4 = np.nansum(Q4[:,0,:])

	x1 = np.nansum(Q1[:,:,0])
	x2 = np.nansum(Q2[:,:,0])
	x3 = np.nansum(Q3[:,:,19])
	x4 = np.nansum(Q4[:,:,19])


	c1 = (y2/y1)**(1.0/20)
	c3 = (x2/x3)**(1.0/20)
	c4a = (c1*(x1/x4))**(1.0/20)
	c4b = (c3*(y3/y4))**(1.0/20)

	## Apply constants
	Q1 *= c1
	Q4a = Q4*c4a
	Q4b = Q4*c4b
	Q3 *= c3

	## consistance check
	y4a = np.nansum(Q4a[:,0,:])
	y4b = np.nansum(Q4b[:,0,:])
	x4a = np.nansum(Q4a[:,:,19])
	x4b = np.nansum(Q4b[:,:,19])

	x1 = np.nansum(Q1[:,:,0])
	y3 = np.nansum(Q3[:,19,:])

	da = abs(x4a-x1) + abs(y4a-y3)
	db = abs(x4b-x1) + abs(y4b-y3)

	ifu[:, 20:40, 20:40] = Q1
	ifu_uncert[:, 20:40, 20:40] *= c1
	## Apply c4
	if da <= db:
		ifu[:, 20:40, 0:20]=Q4a
		ifu_uncert[:, 20:40, 0:20] *= c4a
	else:
		ifu[:, 20:40, 0:20]=Q4b
		ifu_uncert[:, 20:40, 0:20] *= c4b
	ifu[:, 0:20, 0:20] = Q3
	ifu_uncert[:, 0:20, 0:20] *= c3



	print np.nanmax(Q1),np.nanmax(Q2),np.nanmax(Q3),np.nanmax(Q4)



	ex0 = fits.PrimaryHDU(ifu, f[0].header)
	ex1 = fits.ImageHDU(ifu_uncert, f[1].header, name='ERROR')
	f_new = fits.HDUList([ex0, ex1, f[2], f[3]])

	corr_fits_file = '%s/Data/vimos/cubes/%s.cube.combined.corr.fits' % (cc.base_dir, galaxy)
	f_new.writeto(corr_fits_file, clobber=True)
	
if __name__ == '__main__':
	correction('ngc3557')