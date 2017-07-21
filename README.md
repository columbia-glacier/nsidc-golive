Global Land Ice Velocity Extraction from Landsat 8 (GoLIVE)
=======================

### Data

For each time interval, the following variables are provided as GeoTIFF:

  * `data/YYYYMMDD_YYYYMMDD_vx.tif`: Velocity in x (m/day)
  * `data/YYYYMMDD_YYYYMMDD_vy.tif`: Velocity in y (m/day)
  * `data/YYYYMMDD_YYYYMMDD_corr.tif`: Peak correlation value
  * `data/YYYYMMDD_YYYYMMDD_dcorr.tif`: Difference between primary and secondary correlation peaks ("del_corr")

Where `YYYYMMDD_YYYYMMDD` is the start and end dates, respectively, in format `YYYYMMDD`. The files are referenced to WGS84 UTM Zone 6N (EPSG:32606).

### Citations

> Scambos, T., M. Fahnestock, T. Moon, A. Gardner, and M. Klinger (2016). Global Land Ice Velocity Extraction from Landsat 8 (GoLIVE), Version 1. Boulder, Colorado USA. NSIDC: National Snow and Ice Data Center. doi:[10.7265/N5ZP442B](http://dx.doi.org/10.7265/N5ZP442B)

> Fahnestock, M., T. Scambos, T. Moon, A. Gardner, T. Haran, and M. Klinger (2015). Rapid large-area mapping of ice flow using Landsat 8. Remote Sensing of the Environment, 185:84-94. doi:[10.1016/j.rse.2015.11.023](http://dx.doi.org/10.1016/j.rse.2015.11.023)

### Sources

[Global Land Ice Velocity Extraction from Landsat 8 (GoLIVE), Version 1](https://nsidc.org/data/NSIDC-0710/)
