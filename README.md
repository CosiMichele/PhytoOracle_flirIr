# PhytoOracle's FlirIr Pipeline

#### Outline

Welcome to PhytoOracle's FlirIr pipeline! This pipeline uses the data transformers from the [AgPipeline group](https://github.com/AgPipeline/) to extract thermal data from image files. PhytoOracle's FlirIr was primarely built to process data originating from University of Arizona's gantry system, the world's largest robotic field scanner. The FlirIr pipeline is avaiable for either HPC (High Performance Computing) systems or cloud based systems.

#### Transformers used

FlirIr currently uses 3 different transformers for data conversion:

|Order|Transformer|Process|
|:-:|:-:|:-:|
|1|[cleanmetadata](https://github.com/AgPipeline/moving-transformer-cleanmetadata)|Cleans gantry generated metadata|
|2|[flir2tif](https://github.com/AgPipeline/moving-transformer-flir2tif)|Converts bin compressed files to tif|
|3|[meantemp](https://github.com/AgPipeline/moving-transformer-meantemp)|Extracts temperature from detected biomass|

#### Data overview

PhytoOracle's FlirIr requires a metadata file (`<metadata>.json`) for every compressed image file (`<image>.bin`). These should already be in the same folder when obtaining data from the [CyVerse DataStore](https://cyverse.org/data-store).

#### Setup Guide

Go [here](https://github.com/uacic/PhytoOracle/blob/alpha/HPC_Install.md) to launch on an HPC system (tested on the University of Arizona's HPC system).
Go [here]() instead if using a cloud system with HPC support (tested on CyVerse Atmosphere, soon to be tested on NSF's JetStream).

#### Running on the HPC's interactive node

At this point your worker nodes should already be running and you should be in your FlirIr directory within your interactive node. Download the data that you need using:

```
iget -rKVP /iplant/home/shared/terraref/ua-mac/raw_tars/season_10_yr_2020/flirIrCamera/<day>.tar
```

Replace `<day>` with any day you want to process. Un-tar and move the folder to the FlirIr directory.

```
tar -xvf <day>.tar
mv ./flirIrCamera/<day> ./
```
Then edit your `entrypoint.sh` on line 4 to reflect the `<day>` folder you want to process.

Once everything is edited, run the pipeline with `./entrypoint.sh`.

#### Running on the Cloud with HPC support

Although very similar to the steps above,  to run PhytoOracle on the Cloud with HPC support, there are a few extra steps  you have to carry out for data staging before starting the pipeline with `./entrypoint.sh`.

Using your favouring editing tool do

```bash
/etc/nginx/sites-available/phyto_oracle.conf
```

paste the next snipped and save (changing the highlighted `<fields>`)

```bash
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # SSL configuration
        #
        # listen 443 ssl default_server;
        # listen [::]:443 ssl default_server;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root <PATH/TO/YOUR/PHYTOORACLE/PIPELINE>;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                auth_basic "PhytoOracle Data";
        auth_basic_user_file /etc/apache2/.htpasswd;
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
                autoindex on;
        }
}
```

then from within your Transformer directory do `./nginx_reload.sh`. Input your password if asked.

Open and edit `process_one_set.sh` : 

- delete the `#` on lines 37 and 38
- remove `${HPC_PATH}` on lines 24, 25, 28
