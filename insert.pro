;; ==================================================================
;; 			Inject false data into cube
;; ==================================================================
;; Process for the injection of simple false data into the pipeline -
;; for orientation etc.


pro insert, galaxy

dataset = '/Data/vimosindi/reduced/' + galaxy + '/combined_exposures'

files = FILE_SEARCH(dataset + '/*_cexp.fits')

FITS_READ, files[0], rss, header1
rss_uncert = MRDFITS(files[0], 2, header1_uncert, /SILENT)

fiber_pos_file='/Volumes/Data/idl_libraries/p3d/data/instruments/vimos/vimos_positions_rer.dat'
READCOL, fiber_pos_file, i, id, x, y, /SILENT, COMMENT=';'
s = size(rss)
ifu = make_array([40,40,2800])
ifu_uncert = make_array([40,40,2800])

for i=0, s[1]-1 do begin
    ifu[x[i]-1,y[i]-1,*] = rss[i,*]
    ifu_uncert[x[i]-1,y[i]-1,*] = rss_uncert[i,*]
 endfor ; i

; Inject false data
ifu[5,10,*] = MAKE_ARRAY(s[2], value=0.05*max(ifu))


;; Back into rss format
rss_data_complete = MAKE_ARRAY([s[1]*4,s[2]], /FLOAT)
rss_data_uncert_complete = MAKE_ARRAY([s[1]*4,s[2]], /FLOAT)

for i = 0 , s[1]-1 do begin
    rss_data_complete[i,*] = ifu[x[i]-1,y[i]-1,*]
    rss_data_uncert_complete[i,*] = ifu_uncert[x[i]-1,y[i]-1,*]
endfor ; i



a = strsplit(files[0], '/', /extract)
file = strmid(a[-1],0 , strlen(a[-1])-5)

f = dataset +'/'+ file + '_ins.fits'
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


return
end
