## Routine to plot the model and plot the flexure of VIMOS
from astropy.io import fits
from checkcomp import checkcomp
import matplotlib.pyplot as plt
import numpy as np
cc=checkcomp()

def flexure(gal):
	flatfield_dir = '%s/Data/vimos/%s' % (cc.base_dir, gal)
	# fig, ax_array = plt.subplots(2,2)
	# for quadrant in range(1,5):
	# 	f = fits.open('%s/Q%s.fits' %(flatfield_dir,quadrant))
	# 	rss = f[0].data
	# 	line = np.argmax(rss, axis=1)
	# 	ax_array[quadrant%2, np.floor((quadrant-1)/2)].scatter(range(len(line)),line,1)
	# 	ax_array[quadrant%2, np.floor((quadrant-1)/2)].set_title('Q%s' %(quadrant))
	#plt.show()


	reduced_dir = '%s/Data/vimos/cubes' % (cc.base_dir)
	c = fits.open('%s/%s.cube.combined.fits' %(reduced_dir, gal))
	cube = c[0].data[:,:,:]
	s=cube.shape
	c_line = np.argmax(cube, axis=0)

	f,ax=plt.subplots()
	f2,ax2=plt.subplots()


	import matplotlib.cm as cm
	colors = cm.rainbow(np.linspace(0, 1, 40))


	for i,co in zip(range(40),colors):
		if i < s[1]:
			ax.scatter(np.ones(s[2])*i, c_line[i,:], 1, color=co)
			ax2.scatter(range(len(c_line[i,:])), c_line[i,:], 1, color=co)

	f.savefig('x.png')
	f2.savefig('y.png')
	plt.close('all')

	f,ax=plt.subplots()
	cs = ax.imshow(np.rot90(c_line))
	cbar=plt.colorbar(cs, ax=ax)
	#plt.show()
	plt.close('all')

	c_line = np.sort(c_line.flatten())
	return c[0].header['HIERARCH CCD1 RA'],c[0].header['HIERARCH CCD1 DEC'], c[0].header['HIERARCH CCD1 ESO TEL ALT'], c[0].header['HIERARCH CCD1 ESO TEL AZ'], np.std(c_line)#[-value]-c_line[value]



##############################################################################

# Use of flexure.py

if __name__ == '__main__':
	gal = 'ngc3557'
	galaxies = ['ic1459','ic1531','ic4296',	'ngc0612','ngc1399','ngc3100',
		'ngc7075','pks0718-34','ngc3557','eso443-g024']
	RA=[]
	dec=[]
	spread=[]
	alt=[]
	az=[]
	for i, gal in enumerate(galaxies):
		print gal
		RA_i, dec_i, alt_i, az_i, spread_i = flexure(gal)
		RA.append(RA_i)
		dec.append(dec_i)
		alt.append(alt_i)
		az.append(az_i)
		spread.append(spread_i)

	i = np.argsort(RA)
	j = np.argsort(dec)
	k = np.argsort(alt)
	l = np.argsort(az)
	spread=np.array(spread)
	RA=np.array(RA)
	dec=np.array(dec)
	alt=np.array(alt)
	az=np.array(az)

	f,ax=plt.subplots()
	ln1=ax.plot(alt[k], spread[k], 'b', label='alt')
	ax2=ax.twiny()
	ln2=ax2.plot(dec[j], spread[j],'r', label='dec')
	ax3=ax.twiny()
	ln3=ax3.plot(RA[i], spread[i],'g', label='RA')
	ax4=ax.twiny()
	ln4=ax4.plot(az[l],spread[l],'y', label='az')
	lns = ln1+ln2+ln3+ln4
	labs = [l.get_label() for l in lns]
	ax.legend(lns, labs, loc=0)
	f.suptitle('Spread of position of brightest pixel against position')
	plt.show()