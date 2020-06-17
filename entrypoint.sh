#!/bin/bash

# Phase 1
python3 gen_files_list.py 0218_45 > raw_data_files.json
python3 gen_bundles_list.py raw_data_files.json bundle_list.json 5
mkdir -p bundle/
python3 split_bundle_list.py  bundle_list.json bundle/
/home/u12/cosi/cctools-7.1.5-x86_64-centos7/bin/jx2json main_wf_phase1.jx -a bundle_list.json > main_workflow_phase1.json

# -a advertise to catalog server
/home/u12/cosi/cctools-7.1.5-x86_64-centos7/bin/makeflow -T wq --json main_workflow_phase1.json -a -N phyto_oracle-atmo -p 9123 -dall -o dall.log --disable-cache $@

# Phase 2
mv *_plotclip.tar plotclip_out/
cd plotclip_out/
for f in *.tar.gz; do tar -xvf "$f"; done

#mkdir -p plotclip_out/

#tar -xvf plotclip_out.tar

module load singularity
#singularity run -B $(pwd):/mnt --pwd /mnt/ docker://emmanuelgonzalez/plotclip_shp:latest --sensor FlirIrCamera --shape season10_multi_latlon_geno.geojson flir2tif_out/
#singularity run -B $(pwd):/mnt --pwd /mnt/ docker://cosimichele/po_meantemp:latest -g season10_multi_latlon_geno.geojson plotclip_out/

# Remove headers
#for i in `ls meantemp_out`
#do sed -i '1d' meantemp_out/${i}/meantemp_geostreams.csv
#done

# Concatenate all files
#for i in `ls meantemp_out`
#do cat meantemp_out/${i}/meantemp_geostreams.csv >> t0.csv
#done

# Edit Phas 2 output
#cut -d ',' -f3,4,5,6,7 t0.csv > t1.csv
#awk -F, '{print $4,$5,$1,$2,$3}' OFS=, t1.csv > t2.csv
#sed 's/^.\{9\}//' t2.csv > meantemp.csv
#sed -i '1 i\Plot, Temperature, Latitute, Longitude, Time' meantemp.csv

# Cleanup 
#rm -r t*
#mkdir meantemp_intermediate/ && chmod 755 meantemp_intermediate/
#mv meantemp_out/* meantemp_intermediate/
#mv meantemp_intermediate/ meantemp_out/
#mv meantemp.csv meantemp_out/
