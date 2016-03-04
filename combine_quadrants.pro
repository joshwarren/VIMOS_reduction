;; warrenj 20160301 Created new routine to combine the quadrants
;; myself. This add a constant amount to quadrants 1, 3 and 4 to
;; minimise the change between adjasent spaxels at quadrant edges.

pro combine_quadrants, galaxy, OB

for obs = 0,1 do begin
str_OB = STRTRIM(STRING(OB),2)
dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB
if method eq "telluric" then begin
    files = FILE_SEARCH(dataset + '/Q?/calibrated/*fluxcal*.fits')
endif else if method eq "nofcdgoodnorm" then begin
    files = FILE_SEARCH(dataset + '/Q?/*_crcl_oextr?.fits')
endif

;; select files
if obs eq 0 then files1 = [files[0], files[2], files[4], files[6]]
if obs eq 1 then files1 = [files[1], files[3], files[5], files[7]]

FILE_MKDIR, dataset + '/combined'

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
;old = FILE_SEARCH(dataset + '/combined/*')
;if old[0] ne "" then FILE_DELETE, old

opath = dataset  + '/combined'


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


c1 = total(y4-y1)/(2*20)
c3 = total(x4-x3)/(2*20)
c2 = c1/2 - total(x2-x1)/(2*20)
c2b = c3/2 - total(y2-y3)/(2*20)
;; consistancy test: Should be very similar (hopefully)
;print, c2, c2b


Q1 += c1/s1[2]
Q2 += c2/s1[2]
Q3 += c3/s1[2]


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


f=file_search('/Data/vimosindi/ngc1399-3/combined/*_oextr1_vmcmb.fits')


a = strsplit(files1[0], '/', /extract)
file = strmid(a[-1],0 , strlen(a[-1])-5)
f=dataset + '/combined/' + file + '_vmcmb.fits'
FITS_OPEN,f,fcb, /write
fits_write,fcb,image1, header1,extver=1 
fits_write,fcb,image1_uncert, header1_uncert,extname='ERROR',extver=1




endfor ; obs
return
end
