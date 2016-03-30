;; ==================================================================
;; 		Correcting the fringe-like pattern
;; ==================================================================
;; warrenj 20160304 Routine based on A&A 541. A82 (2012)

pro correction, galaxy, OB
str_OB = STRTRIM(STRING(OB),2)
dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB + '/combined'

files = FILE_SEARCH(dataset + '/*vmcmb.fits')


obs=0
for obs = 0,1 do begin

if obs eq 0 then files1 = files[0]
if obs eq 1 then files1 = files[1]

FITS_READ, files1, rss_data, header
rss_data_uncert = MRDFITS(files1, 2, header_uncert, /SILENT)

s = size(rss_data)

fiber_pos_file='/Volumes/Data/idl_libraries/p3d/data/instruments/vimos/vimos_positions_rer.dat'
READCOL, fiber_pos_file, i, id, x, y, /SILENT, COMMENT=';'

ifu = MAKE_ARRAY([max(x), max(y), s[2]])
ifu_uncert = MAKE_ARRAY([max(x), max(y), s[2]])
med_ifu = MAKE_ARRAY([max(x), max(y), s[2]])

;; Converting RSS to cube format
for i = 0 , s[1]-1 do begin
   ifu[x[i]-1,y[i]-1,*] = rss_data[i,*]
   ifu_uncert[x[i]-1,y[i]-1,*] = rss_data_uncert[i,*]
endfor ; i

;; set up array to give number of adjacent cells. 
n_adjacent = MAKE_ARRAY(max(x), max(y), value=8)
n_adjacent[[0,max(x)],*] = 5
n_adjacent[*,[0,max(y)]] = 5
n_adjacent[[0,0,max(x),max(x)],[0,max(y),0,max(y)]] = 3

for i = 0, max(x)-1 do begin
    for j = 0, max(y)-1 do begin
	if n_adjacent[i,j] eq 8 then begin
	    adjacent_x = [i+1,i+1,i+1,i,i,i-1,i-1,i-1]
	    adjacent_y = [j+1,j,j-1,j+1,j-1,j+1,j,j-1]
	    med_ifu[i,j,*] = median(median(ifu[adjacent_x,adjacent_y,*],dimension=2),dimension=1)
        endif else if n_adjacent[i,j] eq 5 then begin
	    if i eq 0 then begin
		adjacent_x = [i+1,i+1,i+1,i,i]
		adjacent_y = [j+1,j,j-1,j+1,j-1]
            endif else if i eq max(x)-1 then begin
 		adjacent_x = [i-1,i-1,i-1,i,i]
		adjacent_y = [j+1,j,j-1,j+1,j-1]
            endif else if j eq 0 then begin
		adjacent_x = [i+1,i+1,i,i-1,i-1]
		adjacent_y = [j+1,j,j+1,j+1,j]
            endif else if j eq max(y)-1 then begin
		adjacent_x = [i+1,i+1,i,i-1,i-1]
		adjacent_y = [j-1,j,j-1,j-1,j]
            endif 
	    med_ifu[i,j,*] = median(median(ifu[adjacent_x,adjacent_y,*],dimension=2),dimension=1)
        endif else begin
	    med_ifu[i,j,*] = MAKE_ARRAY(s[2], value=1.0)
        endelse
    endfor ; j
endfor ; i

;med_ifu[where(med_ifu eq 0)] = 1
l = where(med_ifu ne 0)

correction = ifu
correction[l] = ifu[l]/med_ifu[l]

for i = 0, max(x)-1 do begin
    for j = 0, max(y)-1 do begin
	lowess2, indgen(s[2]), reform(correction[i,j,*], s[2]), 150, y_new, order=2
;       CALL_EXTERNAL('~/IDL_Library/fortran/lowess.so', 'lowess_warapper_', $
;		indgen(s[2]), reform(correction[i,j,*], s[2]), 1, $
;		150.0/2800.0, 2, y_new, rw, res)

	correction[i,j,*]=y_new
;        correction[i,j,*] = lowess(indgen(s[2]), reform(correction[i,j,*], s[2]), 150, 2)
    endfor ; j
endfor ; i




;; Finally correct the spectrum
correction[where(correction eq 0)-1] = 1
correction[where(correction eq 0)+1] = 1
correction[where(correction eq 0)] = 1
ifu = ifu/correction
ifu_uncert /=correction

;ifu[where(ifu eq 1)+1] = !VALUES.F_NAN
;ifu[where(ifu eq 1)-1] = !VALUES.F_NAN
;ifu[where(ifu eq 1)] = !VALUES.F_NAN


;; Convert back to RSS format
for i = 0 , s[1]-1 do begin
    rss_data[i,*] = ifu[x[i]-1,y[i]-1,*]
    rss_data_uncert[i,*] = ifu_uncert[x[i]-1,y[i]-1,*]
endfor ; i

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH(dataset + '/*_darc*')
if old[0] ne "" then FILE_DELETE, old


;; Writting the fits file
a = strsplit(files1, '/', /extract)
file = strmid(a[-1],0 , strlen(a[-1])-5)

f=dataset + '/' + file + '_cor.fits'
FITS_OPEN,f,fcb, /write

GET_DATE, dte
sxaddpar, header, 'DATE', dte ; Today's date

fits_write,fcb,rss_data, header,extver=1 
fits_write,fcb,rss_data_uncert, header_uncert,extname='ERROR',extver=1

w = where(finite(ifu), nCOMPLEMENT=count)
if count ne 0 then message, 'NAN present at end', /continue

endfor ; obs

return
end
