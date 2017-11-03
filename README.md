# docker-debian-perl-mediawiki
Docker image for Perl MediaWiki client libraries

Build image

    docker build -t iperl .

You can pull from

    https://hub.docker.com/r/toniher/debian-perl-mediawiki/


Running image

    docker run -d -v $PWD/scripts:/scripts  -v $PWD/notebooks:/notebooks -p 8888:8888 --name iperl iperl  tail -f /dev/null

    docker exec -ti iperl /bin/bash

Running notebook

    iperl notebook --no-browser --allow-root --ip 0.0.0.0

