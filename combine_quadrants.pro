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
y1 = total(ifu[20:39,20,*])
y2 = total(ifu[0:19,20,*])
y3 = total(ifu[0:19,19,*])
y4 = total(ifu[20:39,19,*])

x1 = total(ifu[20,20:39,*])
x2 = total(ifu[19,20:39,*])
x3 = total(ifu[19,0:19,*])
x4 = total(ifu[20,0:19,*])

c1 = (y2/y1)^(1/20)
c3 = (x2/x3)^(1/20)
c4a = (c1*(x1/x4))^(1/20)
c4b = (c3*(y3/y4))^(1/20)

;; Apply constants
Q1 *= c1
Q4a = Q4*c4a
Q4b = Q4*c4b
Q3 *= c3

;; consistance check
y4a = total(Q4a[0:19,0,*])
y4b = total(Q4b[0:19,0,*])
x4a = total(Q4a[19,0:19,*])
x4b = total(Q4b[19,0:19,*])

y1 = total(Q1[*,0,*])
x3 = total(Q3[19,*,*])

da = abs(x4a-x1) + abs(y4a-y3)
db = abs(x4b-x1) + abs(y4b-y3)


ifu[20:39,20:39,*] = Q1
ifu_uncert[20:39,20:39,*] *= c1
;; Apply c2
if da lt db then $
	ifu[20:39,0:19,*]=Q4a else $
	ifu[20:39,0:19,*]=Q4b
if da lt db then $
	ifu_uncert[20:39,0:19,*] *= c4a else $
	ifu_uncert[20:39,0:19,*] *= c4b
ifu[0:19,0:19,*] = Q3
ifu_uncert[0:19,0:19,*] *= c3


;ifu[5,10,*] = make_array(n_elements(ifu[5,10,*]), value=max(ifu))

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
