# VIMOS_reduction
Data reduction for VIMOS data

This repo contains two reduction pipelines: One with P3D and one with Py3D
### P3D
This was the first attempt, the result of which is now not used. It was run from the file reduce_VIMOS.pro which called each part of the reduction in turn. Each part is contained within its own file and makes indervidual calls to inderpendant scripts in P3D.

### Py3D
This is called using the bash script reduce.sh. This make similar indervidual calls to each inderpendant python scripts in the Py3D package. This routine also reorders the files from their directory tree as set up for P3D. 
After this, correction.py is used to provide an ad-hoc correction for flexure of VIMOS and the lack of calibration between the quadrants of VIMOS
