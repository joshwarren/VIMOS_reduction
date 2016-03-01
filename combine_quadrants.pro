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


files1 = [files[0], files[2], files[4], files[6]]
files2 = [files[1], files[3], files[5], files[7]]

FILE_MKDIR, dataset + '/combined'

;; Clear old files incase file name has changed so future routines are
;; not confused by old files.
;old = FILE_SEARCH(dataset + '/combined/*')
;if old[0] ne "" then FILE_DELETE, old

opath = dataset  + '/combined'


;; Image 1
FITS_READ, files1[0], Q1_1, header1_1
Q1_1_uncert = MRDFITS(files1[0], 2, /SILENT)

FITS_READ, files1[1], Q2_1, header2_1
Q2_1_uncert = MRDFITS(files1[1], 2, /SILENT)

FITS_READ, files1[2], Q3_1, header3_1
Q3_1_uncert = MRDFITS(files1[2], 2, /SILENT)

FITS_READ, files1[3], Q4_1, header4_1
Q4_1_uncert = MRDFITS(files1[3], 2, /SILENT)

;; Image 2
FITS_READ, files2[0], Q1_2, header1_2
Q1_2_uncert = MRDFITS(files2[0], 2, /SILENT)

FITS_READ, files2[1], Q2_2, header2_2
Q2_2_uncert = MRDFITS(files2[1], 2, /SILENT)

FITS_READ, files2[2], Q3_2, header3_2
Q3_2_uncert = MRDFITS(files2[2], 2, /SILENT)

FITS_READ, files2[3], Q4_2, header4_2
Q4_2_uncert = MRDFITS(files2[3], 2, /SILENT)


PA1 = read_hdr(header1_1, 'HIERARCH ESO ADA POSANG')
PA2 = read_hdr(header1_2, 'HIERARCH ESO ADA POSANG')

s1 = size([Q1_1,Q2_1,Q3_1,Q4_1])
image1 = make_array([s1[1],s1[2]])
s2 = size([Q1_2,Q2_2,Q3_2,Q4_2])
image2 = make_array([s2[1],s2[2]])

for i = 0 , 9 do begin
;; Q1
;; even lines
	image1[80*i+s1[1]/2+20:80*(i+1)-41+s1[1]/2,*] = Q1_1[40*i:40*(i+1)-21,*]
;; odd lines
	image1[80*i+60+s1[1]/2:80*(i+1)-1+s1[1]/2,*] = Reverse(Q1_1[40*i+20:40*(i+1)-1,*])




;; Q2
;; even lines
;	image1[80*i+20+s1[1]/2:80*(i+1)-41+s1[1]/2,*] = Reverse(Q2_1[40*i:40*(i+1)-21,*])
;; odd lines
;	image1[80*i+60+s1[1]/2:80*(i+1)-1+s1[1]/2,*] = Q2_1[40*i+20:40*(i+1)-1,*]
endfor; i

;for i = 0 , 19 do begin
;	image1[40*i+s1[1]/2:40*(i+1)-21+s1[1]/2,*]=Q3_1[20*i:20*(i+1)-1,*]
;	image1[40*i+20+s1[1]/2:40*(i+1)-1+s1[1]/2,*]=Q4_1[20*i:20*(i+1)-1,*]
;endfor; i


for i =0 ,4 do begin
;; Q1
	image1[s1[1]/2+i*160:160*(i+1)-1+s1[1]/2,*]=reverse(image1[160*i+s1[1]/2:160*(i+1)-1+s1[1]/2,*])
;	image1[s1[1]/2+20+i*160:160*(i+1)-121+s1[1]/2,*]=reverse(image1[160*i+s1[1]/2+100:160*(i+1)-41+s1[1]/2,*])

;	image1[160*i+s1[1]/2+100:160*(i+1)-41+s1[1]/2,*]=reverse(image1[s1[1]/2+20+i*160:160*(i+1)-121+s1[1]/2,*])




;; Q2
;	image1[s1[1]/2+i*160:160*(i+1)-1+s1[1]/2,*]=reverse(image1[160*i+s1[1]/2:160*(i+1)-1+s1[1]/2,*])

endfor



image1[s1[1]/2:s1[1]/2+1,*] = make_array([2,n_elements(image1[s1[1]/2,*])],value=1e-16)
































image_uncer=make_array([s1[1],s1[2]], value=10e-17)


f=file_search('/Data/vimosindi/ngc1399-1/combined/*_oextr1_vmcmb.fits')
fits_read, f[0], check, header
f='/Data/vimosindi/ngc1399-2/combined/test_vmcmb.fits'
FITS_OPEN,f,fcb, /write
fits_write,fcb,image1, header,extver=1 
fits_write,fcb,image_uncert, header,extname='ERROR',extver=1
return
end
