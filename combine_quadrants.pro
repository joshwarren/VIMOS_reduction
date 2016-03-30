;; warrenj 20160301 Created new routine to combine the quadrants
;; myself. This add a constant amount to quadrants 1, 3 and 4 to
;; minimise the change between adjasent spaxels at quadrant edges.


pro combine_quadrants, galaxy, OB, method
str_OB = STRTRIM(STRING(OB),2)
dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB
if method eq "telluric" then begin
    files = FILE_SEARCH(dataset + '/Q?/calibrated/*fluxcal*.fits')
endif else if method eq "nofcdgoodnorm" then begin
    files = FILE_SEARCH(dataset + '/Q?/*_crcl_oextr?.fits')
endif

FILE_MKDIR, dataset + '/combined/'

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH(dataset + '/combined/*')
if old[0] ne "" then FILE_DELETE, old

opath = dataset  + '/combined/'

ifu = make_array([40,40,2800])
ifu_uncert = make_array([40,40,2800])


;obs=0
for obs = 0,1 do begin
;; select files
if obs eq 0 then files1 = [files[0], files[2], files[4], files[6]]
if obs eq 1 then files1 = [files[1], files[3], files[5], files[7]]

for q = 0, 3 do begin
    FITS_READ, files1[q], rss, header1
    rss_uncert = MRDFITS(files1[q], 2, header1_uncert, /SILENT)

    fiber_pos_file='/Volumes/Data/idl_libraries/p3d/data/instruments/vimos/vimos_positions_q' + STRTRIM(STRING(q+1),2) + 'b.dat'
    READCOL, fiber_pos_file, i, id, x, y, /SILENT, COMMENT=';'
    s = size(rss)
    for i=0, s[1]-1 do begin
        ifu[x[i]-1,y[i]-1,*] = rss[i,*]
        ifu_uncert[x[i]-1,y[i]-1,*] = rss_uncert[i,*]
    endfor ; i
endfor ; q

;; Position angle check
PA1 = read_hdr(header1, 'HIERARCH ESO ADA POSANG')
if PA1 ne 0 then message, "Image at PA: " + string(PA1) + " not 0."

Q1 = ifu[20:39,20:39,*]
Q2 = ifu[0:19,20:39,*]
Q3 = ifu[0:19,0:19,*]
Q4 = ifu[20:39,0:19,*]

;; Finding constants c1, c2 and c3
y1 = total(ifu[20:39,20,*],3)
y2 = total(ifu[0:19,20,*],3)
y3 = total(ifu[0:19,19,*],3)
y4 = total(ifu[20:39,19,*],3)

x1 = total(ifu[20,20:39,*],3)
x2 = total(ifu[19,20:39,*],3)
x3 = total(ifu[19,0:19,*],3)
x4 = total(ifu[20,0:19,*],3)

d41 = total(y4-y1)
d43 = total(x4-x3)
d21 = total(x2-x1)
d23 = total(y2-y3)

c1 = d41/(2*20)
c3 = d43/(2*20)
c2a = c1/2 - d21/(2*20)
c2b = c3/2 - d23/(2*20)

;; Apply constants
Q1[where(Q1 ne 0)] += c1/s[2]
Q2a = Q2
Q2b = Q2
Q2a[where(Q2 ne 0)] = Q2[where(Q2 ne 0)] + c2a/s[2]
Q2b[where(Q2 ne 0)] = Q2[where(Q2 ne 0)] + c2b/s[2]
Q3[where(Q3 ne 0)] += c3/s[2]

;; consistance check
y2a = total(Q2a[0:19,0,*],3)
y2b = total(Q2b[0:19,0,*],3)
x2a = total(Q2a[19,0:19,*],3)
x2b = total(Q2b[19,0:19,*],3)

d21a = total(x2a-x1)
d21b = total(x2b-x1)
d23a = total(y2a-y3)
d23b = total(y2b-y3)
d_total_a = total([abs(d41), abs(d43), abs(d21), abs(d23)])
d_total_b = total([abs(d41), abs(d43), abs(d21), abs(d23)])

ifu[20:39,20:39,*] = Q1
;; Apply c2
if d_total_a lt d_total_b then $
	ifu[0:19,20:39,*]=Q2a else $
	ifu[0:19,20:39,*]=Q2b
ifu[0:19,0:19,*] = Q3






;; Convert back to RSS format
fiber_pos_file='/Volumes/Data/idl_libraries/p3d/data/instruments/vimos/vimos_positions_rer.dat'
READCOL, fiber_pos_file, i, id, x, y, /SILENT, COMMENT=';'

rss_data_complete = MAKE_ARRAY([s[1]*4,s[2]], /FLOAT)
rss_data_uncert_complete = MAKE_ARRAY([s[1]*4,s[2]], /FLOAT)

for i = 0 , s[1]*4-1 do begin
    rss_data_complete[i,*] = ifu[x[i]-1,y[i]-1,*]
    rss_data_uncert_complete[i,*] = ifu_uncert[x[i]-1,y[i]-1,*]
endfor ; i



a = strsplit(files1[0], '/', /extract)
file = strmid(a[-1],0 , strlen(a[-1])-5)

f = opath + file + '_vmcmb.fits'
FITS_OPEN,f,fcb, /write



;; Update the header
sxaddpar, header1, 'NAXIS1', 40*40 ; total number of spaxels
GET_DATE, dte
sxaddpar, header1, 'DATE', dte ; Today's date
sxaddpar, header1, 'IMTYPE', 'p3d: combined object image', /savecomment ; changed from 'p3d: extracted science-object image'
sxaddpar, header1, 'POSTAB', 'p3d: remapped data', 'Indicates which fiber-position table is used.' ; Indicates which fiber-position table is used.
sxaddpar, header1, 'COMMENT', 'p3d_cvimos_combine: IMOBXx are the extracted object image filenames.' ; Comment added




fits_write,fcb,rss_data_complete, header1,extver=1 
fits_write,fcb,rss_data_uncert_complete, header1_uncert,extname='ERROR',extver=1

endfor ; obs
return
end
