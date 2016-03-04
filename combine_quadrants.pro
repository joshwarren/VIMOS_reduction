;; warrenj 20160301 Created new routine to combine the quadrants
;; myself. This add a constant amount to quadrants 1, 3 and 4 to
;; minimise the change between adjasent spaxels at quadrant edges.


pro find_edge, Q1, Q2, Q3, Q4, d41=d41, d43=d43, d21=d21, d23=d23
;; Edge spaxels:
y1 = total(Q1[60:79,*],2)
y2 = total(Q2[-20:-1,*],2)
y3 = total(Q3[-20:-1,*],2)
y4 = total(Q4[60:79,*],2)

a = [19,20]
b = []
for i =0,9 do b = [b, a+40*i]
c = [0,39]
d = []
for i =0,9 do d = [d, c+40*i]
x1 = total(Q1[b,*],2)
x2 = total(Q2[d,*],2)
x3 = total(Q3[d,*],2)
x4 = total(Q4[b,*],2)

d41 = total(y4-y1)
d43 = total(x4-x3)
d21 = total(x2-x1)
d23 = total(y2-y3)
return
end


pro combine_quadrants, galaxy, OB, method
str_OB = STRTRIM(STRING(OB),2)
dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB
if method eq "telluric" then begin
    files = FILE_SEARCH(dataset + '/Q?/calibrated/*fluxcal*.fits')
endif else if method eq "nofcdgoodnorm" then begin
    files = FILE_SEARCH(dataset + '/Q?/*_crcl_oextr?.fits')
endif

FILE_MKDIR, dataset + '/combined'

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
old = FILE_SEARCH(dataset + '/combined/*')
if old[0] ne "" then FILE_DELETE, old

opath = dataset  + '/combined'





;obs=0
for obs = 0,1 do begin
;; select files
if obs eq 0 then files1 = [files[0], files[2], files[4], files[6]]
if obs eq 1 then files1 = [files[1], files[3], files[5], files[7]]

;; Image 1
FITS_READ, files1[0], Q1, header1
Q1_uncert = MRDFITS(files1[0], 2, header1_uncert, /SILENT)

FITS_READ, files1[1], Q2, header2
Q2_uncert = MRDFITS(files1[1], 2, header2_uncert, /SILENT)

FITS_READ, files1[2], Q3, header3
Q3_uncert = MRDFITS(files1[2], 2, header3_uncert, /SILENT)

FITS_READ, files1[3], Q4, header4
Q4_uncert = MRDFITS(files1[3], 2, header4_uncert, /SILENT)

PA1 = read_hdr(header1, 'HIERARCH ESO ADA POSANG')
if PA1 ne 0 then message, "Image at PA: " + string(PA1) + " not 0."

s1 = size([Q1,Q2,Q3,Q4])
image1 = make_array([s1[1],s1[2]])
image1_uncert = make_array([s1[1],s1[2]])



find_edge, Q1, Q2, Q3, Q4, d41=d41, d43=d43, d21=d21, d23=d23

c1 = d41/(2*20)
c3 = d43/(2*20)
c2a = c1/2 - d21/(2*20)
c2b = c3/2 - d23/(2*20)
;; consistancy test: Should be very similar (hopefully)
;print, c2, c2b


Q1 += c1/s1[2]
Q2a = Q2 + c2a/s1[2]
Q2b = Q2 + c2b/s1[2]
Q3 += c3/s1[2]

find_edge, Q1, Q2a, Q3, Q4, d41=d41, d43=d43, d21=d21, d23=d23
d_total_a = total([abs(d41), abs(d43), abs(d21), abs(d23)])
find_edge, Q1, Q2b, Q3, Q4, d41=d41, d43=d43, d21=d21, d23=d23
d_total_b = total([abs(d41), abs(d43), abs(d21), abs(d23)])

;; Result is not self consistant, but use the result which minimises d_total
if d_total_a lt d_total_b then Q2 = Q2a else Q2 = Q2b



for i = 0 , 9 do begin
;; Q1
;; even lines
	image1[80*i+s1[1]/2+20:80*(i+1)-41+s1[1]/2,*] = Q1[40*i:40*(i+1)-21,*]
;; odd lines
	image1[80*i+60+s1[1]/2:80*(i+1)-1+s1[1]/2,*] = Reverse(Q1[40*i+20:40*(i+1)-1,*])
;; Q2
;; even lines
	image1[80*i+s1[1]/2:80*(i+1)-61+s1[1]/2,*] = Reverse(Q2[40*i:40*(i+1)-21,*])
;; odd lines
	image1[80*i+40+s1[1]/2:80*(i+1)-21+s1[1]/2,*] = Q2[40*i+20:40*(i+1)-1,*]
;; Q3
;; even lines
	image1[80*i:80*(i+1)-61,*] = Reverse(Q3[40*i:40*(i+1)-21,*])
;; odd lines
	image1[80*i+40:80*(i+1)-21,*] = Q3[40*i+20:40*(i+1)-1,*]
;; Q4
;; even lines
	image1[80*i+20:80*(i+1)-41,*] = Q4[40*i:40*(i+1)-21,*]
;; odd lines
	image1[80*i+60:80*(i+1)-1,*] = Reverse(Q4[40*i+20:40*(i+1)-1,*])


;; Q1 Uncertainties
;; even lines
	image1_uncert[80*i+s1[1]/2+20:80*(i+1)-41+s1[1]/2,*] = Q1_uncert[40*i:40*(i+1)-21,*]
;; odd lines
	image1_uncert[80*i+60+s1[1]/2:80*(i+1)-1+s1[1]/2,*] = Reverse(Q1_uncert[40*i+20:40*(i+1)-1,*])
;; Q2 Uncertainties
;; even lines
	image1_uncert[80*i+s1[1]/2:80*(i+1)-61+s1[1]/2,*] = Reverse(Q2_uncert[40*i:40*(i+1)-21,*])
;; odd lines
	image1_uncert[80*i+40+s1[1]/2:80*(i+1)-21+s1[1]/2,*] = Q2_uncert[40*i+20:40*(i+1)-1,*]
;; Q3 Uncertainties
;; even lines
	image1_uncert[80*i:80*(i+1)-61,*] = Reverse(Q3_uncert[40*i:40*(i+1)-21,*])
;; odd lines
	image1_uncert[80*i+40:80*(i+1)-21,*] = Q3_uncert[40*i+20:40*(i+1)-1,*]
;; Q4 Uncertainties
;; even lines
	image1_uncert[80*i+20:80*(i+1)-41,*] = Q4_uncert[40*i:40*(i+1)-21,*]
;; odd lines
	image1_uncert[80*i+60:80*(i+1)-1,*] = Reverse(Q4_uncert[40*i+20:40*(i+1)-1,*])
endfor; i


a = [indgen(20), indgen(20)+40, indgen(20)+80, indgen(20)+120]
b=reverse(a)
c = [indgen(20)+120, indgen(20)+80, indgen(20)+40, indgen(20)]
;; Q1
image1[s1[1]/2+[a,a+160,a+320,a+480,a+640]+20,*]=image1[s1[1]/2+[b,b+160,b+320,b+480,b+640]+20,*]
;; Q2
image1[s1[1]/2+[a,a+160,a+320,a+480,a+640],*]=image1[s1[1]/2+[c+640,c+480,c+320,c+160,c],*]
;; Q3
; Fine
;; Q4
image1[[a,a+160,a+320,a+480,a+640]+20,*]=reverse(image1[[c,c+160,c+320,c+480,c+640]+20,*])



a = strsplit(files1[0], '/', /extract)
file = strmid(a[-1],0 , strlen(a[-1])-5)

f=dataset + '/combined/' + file + '_vmcmb.fits'
FITS_OPEN,f,fcb, /write



;; Update the header
sxaddpar, header1, 'NAXIS1', s1[1] ; total number of spaxels
GET_DATE, dte
sxaddpar, header1, 'DATE', dte ; Today's date
sxaddpar, header1, 'IMTYPE', 'p3d: combined object image', /savecomment ; changed from 'p3d: extracted science-object image'
sxaddpar, header1, 'POSTAB', 'p3d: remapped data', 'Indicates which fiber-position table is used.' ; Indicates which fiber-position table is used.
sxaddpar, header1, 'COMMENT', 'p3d_cvimos_combine: IMOBXx are the extracted object image filenames.' ; Comment added




fits_write,fcb,image1, header1,extver=1 
fits_write,fcb,image1_uncert, header1_uncert,extname='ERROR',extver=1

endfor ; obs
return
end
