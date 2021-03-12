# ADSBx-Pi-Feeder-Image
ADSBexchange Pi feeder image release change log

## v1.0.9  March 12th 2021

* Prometheus 1.9.2 replaced 2.xx due to compression cycle memory issues
* Added graphs1090, tar1090, sudo apt update && upgrade
* Fixed adsb-exchange naming on services for consistent service names
* Update script created to update services from ADSBx git repos.
* Supports tar1090 update from git installer
* Supports grapsh1090 upate from git installer

### Updated systemd services:

* adsbexchange-feed.service
* adsbexchange-mlat.service
* adsbexchange-978.service    
* adsbexchange-978-convert.service
* adsbexchange-stats.service
* adsbexchange-go.service                        
* adsbexchange-first-run.service  



