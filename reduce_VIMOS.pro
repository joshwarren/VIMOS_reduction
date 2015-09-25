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


;	galaxy = 'ngc3557'
;	galaxy = 'ic1459'
	galaxy = 'ic1531'
;	OB = '2'
;	quadrant = '2'


sort_quadrants, galaxy


;RESOLVE_ROUTINE, ['create_mbias','create_mtrace','create_mdmask', $
;	'create_mflat', 'extract_VIMOS', 'fluxcal', 'combine_quadrants', $
;	'darc', 'combine_exposures', 'rss2cube']





userparfile = '/Data/vimosindi/user_p3d.dat'

readcol, userparfile, uparname, uparvalue, format='a, a', $
    delimiter=' ', /silent, comment=';'

cquadrant_method = "telluric"

i_nofcdgoodnorm = where(uparname eq "nofcdgoodnorm", nofcdgoodnorm)

if nofcdgoodnorm then cquadrant_method = "nofcdgoodnorm"





for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
	print, 'Q' + STRTRIM(STRING(quadrant),2)
	
	print, 'Bias'
	create_mbias, galaxy, OB, quadrant

	print, "Trace"
	create_mtrace, galaxy, OB, quadrant
endfor
endfor


;; isolate the user interaction.
for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
	print, 'Q' + STRTRIM(STRING(quadrant),2)
	
	print, "Wavelength calibration"
	create_mdmask, galaxy, OB, quadrant
endfor
endfor


for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
	print, 'Q' + STRTRIM(STRING(quadrant),2)

	print, "Flat Fielding"
	create_mflat, galaxy, OB, quadrant

	print, "Extract quadrant"
	extract_VIMOS, galaxy, OB, quadrant

if (cquadrant_method eq "telluric") then begin
	print, "Flux calibration"
	fluxcal, galaxy, OB, quadrant
endif

endfor

	print, 'combine quadrants in OB ' + STRTRIM(STRING(OB),2)
	combine_quadrants, galaxy, OB, cquadrant_method

	print, "darc"
	darc, galaxy, OB
endfor
	
	print, 'Combine all exposures'
;; now combines all OBs
	combine_exposures, galaxy

	print, "Create rss"
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

pro sort_quadrants, galaxy

for OB = 1, 3 do begin
    dataset = '/Data/vimosindi/' + galaxy + '-' + $
        STRTRIM(STRING(OB),2); + '/Bias'
    files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
    n_files = n_elements(files)
if files[0] eq "" then n_files = 0

if n_files ne 0 then begin
    for i = 0, n_files-1 do begin
        str_file = strsplit(files[i], '/', /EXTRACT)
        file = str_file[-1]
        FITS_READ, files[i], data_cube, header
        header_entry = header(where(strmatch(header, $
             'HIERARCH ESO DET CHIP1 ID*', /FOLD_CASE) eq 1))

;; ---------================== Move Files ================-----------
        if strmatch(header_entry, '*BRIAN*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q1/' + file
        if strmatch(header_entry, '*Keith*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q2/' + file
        if strmatch(header_entry, '*Tom*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q3/' + file
        if strmatch(header_entry, '*DAVID*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q4/' + file

     endfor
endif
endfor

;; ---------================== Move Bias =================-----------

for OB = 1, 3 do begin
    dataset = '/Data/vimosindi/' + galaxy + '-' + $
        STRTRIM(STRING(OB)+ '/Bias', 2) 
    files = FILE_SEARCH(dataset + '/*[0-9][0-9].[0-9][0-9][0-9].fits')
    n_files = n_elements(files)
if files[0] eq "" then n_files = 0

if n_files ne 0 then begin
    for i = 0, n_files-1 do begin
        str_file = strsplit(files[i], '/', /EXTRACT)
        file = str_file[-1]
        FITS_READ, files[i], data_cube, header
        header_entry = header(where(strmatch(header, $
             'HIERARCH ESO DET CHIP1 ID*', /FOLD_CASE) eq 1))

;; ---------================== Move Files ================-----------
        if strmatch(header_entry, '*BRIAN*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q1/' + file
        if strmatch(header_entry, '*Keith*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q2/' + file
        if strmatch(header_entry, '*Tom*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q3/' + file
        if strmatch(header_entry, '*DAVID*', /FOLD_CASE) then $
            FILE_MOVE, files[i], dataset + '/Q4/' + file

     endfor
endif
endfor


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
