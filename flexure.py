## Routine to plot the model and plot the flexure of VIMOS
from astropy.io import fits
from checkcomp import checkcomp
import matplotlib.pyplot as plt
import numpy as np
cc=checkcomp()

def flexure(gal, plot=False):
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
	if plot: plt.show()
	plt.close('all')

	f,ax=plt.subplots()
	cs = ax.imshow(np.rot90(c_line))
	cbar=plt.colorbar(cs, ax=ax)
	if plot: plt.show()
	plt.close('all')


	f,ax=plt.subplots()
	rss_file = fits.open('%s/Data/vimos/%s/%s_COMBINED_RSS.fits' % (cc.base_dir, gal, gal.upper()))
	rss = rss_file[0].data
	line = np.argmax(rss, axis=1)
	ax.scatter(range(len(line)),line,1)
	if plot: plt.show()
	plt.close('all')


	f,ax=plt.subplots()
	ax.imshow(np.rot90(np.log(rss)))
	if plot: plt.show()
	plt.close('all')


	f,ax=plt.subplots()
	rss_reconstructed = np.zeros((s[0],s[1]*s[2]))
	for i in range(s[1]):
		for j in range(s[2]):
			rss_reconstructed[:,j*s[1]+i] = cube[:,i,j]/np.median(cube[:,i,j])
	ax.imshow(np.sin(np.log(rss_reconstructed[450:550,:])))
	ax.plot([0,s[0]],[50,50])
	if plot: plt.show()
	plt.close('all')



	f,ax=plt.subplots()
	ax.scatter(range(s[1]*s[2]),np.argmax(rss_reconstructed[1400:1450,:], axis=0),1)
	if plot: plt.show()
	plt.close('all')



	fig, ax_array = plt.subplots(1,4)
	fig2, ax_array2 = plt.subplots(1,4)
	fig3, ax_array3 = plt.subplots()
	fig3, ax_array4 = plt.subplots()

	a=1400
	b=50
	#cube[a+20,30,:] = 1000

	for p in range(4):
		i = p%2
		j = np.floor(p/2)
		rss_reconstructed = np.zeros((b,s[1]/2*s[2]/2))
		for k in range(s[1]/2):
			for l in range(s[2]/2):
				rss_reconstructed[:,k*s[1]/2+l] = \
					cube[a:a+b,i*s[1]/2+k, j*s[2]/2+l]/\
					np.median(cube[a:a+b,i*s[1]/2+k, j*s[2]/2+l])
		rss_reconstructed[np.isnan(rss_reconstructed)]=0
		im = ax_array[p].imshow(np.log(np.log(rss_reconstructed[:,:])),cmap='jet',
			origin='lower',extent=(0,400,a,a+b))
		ax_array[p].scatter(range(s[1]/2*s[2]/2),
			np.argmax(rss_reconstructed[:,:], axis=0)+a,1)

		ax_array[p].set_title(p)
		ax_array2[p].set_title(p)

		e = np.argsort(rss_reconstructed[:,:], axis=0).astype(float)
		for g, f in enumerate(e[-1,:]):
			if rss_reconstructed[int(f),g]==0:
				e[-1,g] = np.nan
		ax_array2[p].scatter(range(s[1]/2*s[2]/2),e[-3,:]+a,1,color='y')
		ax_array2[p].scatter(range(s[1]/2*s[2]/2),e[-2,:]+a,1,color='g')
		ax_array2[p].scatter(range(s[1]/2*s[2]/2),e[-1,:]+a,1,color='r')

		if p!=0:
			ax_array[p].get_yaxis().set_visible(False)
			ax_array2[p].get_yaxis().set_visible(False)
#			ax_array3[p].get_yaxis().set_visible(False)

		f = e[-1,:]+a
		ax_array3.hist(f[~np.isnan(f)],histtype='step', bins=b, normed=True, label=str(p))
		ax_array3.legend()

		if p==3:
			g = np.array(np.where((e[-1,:] > 18)*(e[-1,:] <22)))[0]
			ax_array[p].scatter(g,e[-1,g]+a,2)#,marker='*')

			r = g%20
			w = np.floor(g/20)
			ax_array4.scatter(w.astype(int),r.astype(int))


		#ax_array[p].plot([0,s[1]/2*s[2]/2],[25,25])
	#fig.colorbar(im, ax=ax_array.ravel().tolist())

	[ax.set_aspect('auto') for ax in ax_array]
	plt.tight_layout()
	
	fig, ax = plt.subplots()
	ax.plot(cube[:,20,20])
	ax.axvline(a)
	ax.axvline(a+b)

	if plot: plt.show()
	plt.close('all')

# Absorption line
	a = 1260
	b = 80

	fig, ax = plt.subplots()
	ax.plot(cube[a:a+b,20,20])
	if plot: plt.show()
	plt.close('all')

	fig, ax_array = plt.subplots(1,4)
	fig, ax_array2 = plt.subplots()

	for p in range(4):
		i = p%2
		j = np.floor(p/2)
		rss_reconstructed = np.zeros((b,s[1]/2*s[2]/2))
		for k in range(s[1]/2):
			for l in range(s[2]/2):
				rss_reconstructed[:,k*s[1]/2+l] = \
					cube[a:a+b,i*s[1]/2+k, j*s[2]/2+l]/\
					np.median(cube[a:a+b,i*s[1]/2+k, j*s[2]/2+l])
		rss_reconstructed[np.isnan(rss_reconstructed)]=1000000
		
		e = np.argsort(rss_reconstructed[:,:], axis=0).astype(float)
		for g, f in enumerate(e[0,:]):
			if rss_reconstructed[int(f),g]==0:
				e[0,g] = np.nan

		ax_array[p].scatter(range(s[1]/2*s[2]/2),e[2,:]+a,1,color='y')
		ax_array[p].scatter(range(s[1]/2*s[2]/2),e[1,:]+a,1,color='g')
		ax_array[p].scatter(range(s[1]/2*s[2]/2),e[0,:]+a,1,color='r')

		f = e[0,:]+a
		ax_array2.hist(f[~np.isnan(f)],histtype='step', bins=b, normed=True, label=str(p))
		ax_array2.legend()


		ax_array[p].set_title(p)
	plt.show()





	c_line = np.sort(c_line.flatten())
	return c[0].header['HIERARCH CCD1 RA'],c[0].header['HIERARCH CCD1 DEC'], \
		c[0].header['HIERARCH CCD1 ESO TEL ALT'], \
		c[0].header['HIERARCH CCD1 ESO TEL AZ'], np.std(c_line)



##############################################################################

# Use of flexure.py

if __name__ == '__main__':
	galaxies = ['ic1459','ic1531','ic4296',	'ngc0612','ngc1399','ngc3100',
		'ngc7075','pks0718-34','ngc3557','eso443-g024']
	galaxies = ['ngc3557']
	RA=[]
	dec=[]
	spread=[]
	alt=[]
	az=[]
	for i, gal in enumerate(galaxies):
		print gal
		RA_i, dec_i, alt_i, az_i, spread_i = flexure(gal,plot=False)
		RA.append(RA_i)
		dec.append(dec_i)
		alt.append(alt_i)
		az.append(az_i)
		spread.append(spread_i)

	if len(galaxies) > 1:
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