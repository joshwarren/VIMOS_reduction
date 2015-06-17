;; ==================================================================
;; 			Reduction of VIMOS data
;; ==================================================================
;; Process to call and run all of p3d for the reduction of VISMOS data
;;
;; warrenj 20150324
;; Edited to loop quadrants here rather than in indervidual
;; procedures. This is better as it gives more control within this
;; procedure. 


pro run_reduction


	galaxy = 'ngc3557'
;	OB = '2'
	quadrant = '4'



RESOLVE_ROUTINE, ['create_mbias','create_mtrace','create_mdmask', $
	'create_mflat', 'extract_VIMOS', 'fluxcal', 'combine_quadrants', $
	'darc', 'combine_exposures', 'rss2cube']


for OB = 1, 3 do begin
;for quadrant = 1, 4 do begin

	create_mbias, galaxy, OB, quadrant

	create_mtrace, galaxy, OB, quadrant

	create_mdmask, galaxy, OB, quadrant

	create_mflat, galaxy, OB, quadrant

	extract_VIMOS, galaxy, OB, quadrant

	fluxcal, galaxy, OB, quadrant
;endfor

	combine_quadrants, galaxy, OB

	darc, galaxy, OB
endfor

;; now combines all OBs
	combine_exposures, galaxy

	rss2cube, galaxy



	return
end





;; ==================================================================
;; 		Sorting quadrants into subdirectories
;; ==================================================================
;; warrenj 20150306 routine to sort out quadrants using the fits file
;; header: 
;; Q1 = BRIAN
;; Q2 = Keith
;; Q3 = Tom
;; Q4 = DAVID

pro sort_quadrants



;RESOLVE_ROUTINE, ['headfits']
	galaxy = 'ngc3557'
	OB = '1'

	dataset = '/Data/vimosindi/' + galaxy + '-' + OB

files = FILE_SEARCH(dataset + '/Q1/*[0-9][0-9].[0-9][0-9][0-9].fits')







;for i = 0, 23 do begin

	hdr = headfits(files[0])
	header = 'DET CHIP1 ID'
	headerArray = hdr[where(strmatch(hdr, '*' + header + '*') EQ 1)]
	result = STRSPLIT(headerArray, '=/',/extract)
	print, headerArray
	print, result[1]

;; NB: string(39B) is an apostrophe 
if (result[1] EQ ' ' + string(39B) + 'BRIAN   ' + string(39B) + ' ') THEN BEGIN
 print, 'BRIAN'
endif


;endfor


return

end










;; ===================================================================
;;			Reduce standard star
;; ===================================================================
;; Routine to produce the image of the standard star (Feige 110) ready
;; to create the sensitivity function.
pro reduce_star

RESOLVE_ROUTINE, ('fluxcalstar')

num_quadrant = 2


	fluxcalstar, num_quadrant


return

end
