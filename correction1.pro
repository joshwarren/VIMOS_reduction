;; ==================================================================
;; 		Correcting the fringe-like pattern
;; ==================================================================
;; warrenj 20160304 Routine based on A&A 541. A82 (2012)

pro correction1, galaxy, OB
str_OB = STRTRIM(STRING(OB),2)
dataset = '/Data/vimosindi/' + Galaxy + '-' + str_OB + '/combined'

files = FILE_SEARCH(dataset + '/*vmcmb.fits')


obs=0
;for obs = 0,1 do begin

if obs eq 0 then files1 = files[0]
if obs eq 1 then files1 = files[1]

FITS_READ, files1, rss_data, header
rss_data_uncert = MRDFITS(files1, 2, header, /SILENT)


fiber_pos_file='/Volumes/Data/idl_libraries/p3d/data/instruments/vimos/vimos_positions_rer.dat'

READCOL, fiber_pos_file, i, id, x, y, /SILENT


























































































;endfor ; obs

return
end
