;; ==================================================================
;; 			Reduction of VIMOS data
;; ==================================================================
;; Process to call and run all of p3d for the reduction of VISMOS data
;;
;; warrenj 20150324
;; Edited to loop quadrants here rather than in indervidual
;; procedures. This is better as it gives more control within this
;; procedure. 
;; warrenj 20160314 Added correction to fringe-like routine


pro run_reduction
COMPILE_OPT idl2, HIDDEN

	galaxy = 'ngc3557'
	galaxy = 'ic1459'
;	galaxy = 'ic1531'
;	galaxy = 'ic4296'
;	galaxy = 'ngc0612'
	galaxy = 'ngc1399'
;	galaxy = 'ngc3100'
;	galaxy = 'ngc7075'
	galaxy = 'pks0718-34'
;	galaxy = 'eso443-g024'
;	OB = '2'
;	quadrant = '2'





galaxies = ['ngc3557','ic1531','ic4296','ngc0612']

galaxies = ['ngc3557', 'ic1459', 'ic1531', 'ic4296', 'ngc0612', 'ngc1399', 'ngc3100', 'ngc7075', 'pks0718-34', 'eso443-g024']

for i = 0, n_elements(galaxies)-1 do begin
galaxy = galaxies[i]

wav_cal = 'n'
inject = 'n'
start = 10
bin = 'y'
;; num: starting point
;; 0: All
;; 1: Bias, skip sort quadrents
;; 2: Trace
;; 3: Wavelength calibration
;; 4: Flat fielding
;; 5: Extract
;; 6: Flux calibration
;; 7: Combine quadrants
;; 8: Diffractive atmospheric corrections and fringe corrections
;; 9: Combine exposures and injection
;; 10: Make cube format

print, galaxy
if start le 0 then begin
	print, "Sorting quadrants"
	sort_quadrants, galaxy
endif

;RESOLVE_ROUTINE, ['create_mbias','create_mtrace','create_mdmask', $
;	'create_mflat', 'extract_VIMOS', 'fluxcal', 'combine_quadrants', $
;	'darc', 'combine_exposures', 'rss2cube']





userparfile = '/Data/vimosindi/user_p3d.dat'

readcol, userparfile, uparname, uparvalue, format='a, a', $
    delimiter=' ', /silent, comment=';'

;+
;cquadrant_method = "telluric"
;i_nofcdgoodnorm = where(uparname eq "nofcdgoodnorm", nofcdgoodnorm)
;if nofcdgoodnorm then cquadrant_method = "nofcdgoodnorm"
;-

;cquadrant_method = "nofcdgoodnorm"
cquadrant_method = "telluric"



if start le 2 then begin
for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
	print, 'Q' + STRTRIM(STRING(quadrant),2)

if start le 1 then begin	
	print, 'Bias'
	create_mbias, galaxy, OB, quadrant
endif
	print, "Trace"
	create_mtrace, galaxy, OB, quadrant 
endfor
endfor
endif 

;; isolate the user interaction.
if start le 3 and wav_cal eq 'y' then begin
for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
	print, 'Q' + STRTRIM(STRING(quadrant),2)

	print, "Wavelength calibration"
	create_mdmask, galaxy, OB, quadrant
endfor
endfor
endif

if start le 8 then begin
for OB = 1, 3 do begin
	print, 'OB: ' + STRTRIM(STRING(OB),2)

for quadrant = 1, 4 do begin
if start le 6 then print, 'Q' + STRTRIM(STRING(quadrant),2)

if start le 4 then begin	
	print, "Flat Fielding"
	create_mflat, galaxy, OB, quadrant
endif
if start le 5 then begin	
	print, "Extract quadrant"
	extract_VIMOS, galaxy, OB, quadrant
endif

if start le 6 then begin	
if (cquadrant_method eq "telluric") then begin
	print, "Flux calibration"
	fluxcal, galaxy, OB, quadrant
endif
endif

endfor

if start le 7 then begin	
	print, 'Combine quadrants in OB ' + STRTRIM(STRING(OB),2)
	combine_quadrants, galaxy, OB, cquadrant_method
endif

;; Not sure if this should be before or after darc...
	print, "Fringe-like correction"
	correction, galaxy, OB

;	print, "darc"
;	darc, galaxy, OB
	print, ""
endfor
endif


if start le 9 then begin	
	print, 'Combine all exposures'
	combine_exposures, galaxy
	
	if inject eq 'y' then insert, galaxy
endif

	print, "Create cube format"
	rss2cube, galaxy



;if bin eq 'y' then begin
;	print, "Binning and finding templates"
;	full_analysis, galaxy=galaxy
;endif
print, ""

CLOSE, /All

endfor ;  galaxy


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
FILE_MKDIR, dataset + '/Q1'
FILE_MKDIR, dataset + '/Q2'
FILE_MKDIR, dataset + '/Q3'
FILE_MKDIR, dataset + '/Q4'

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
