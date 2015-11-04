# docker-garby

![Dinotrux character Garby](http://www.dreamworkstv.com/wp-content/uploads/2015/05/DTX-character-GARBY.jpg "Dinotrux character Garby")

Just another Docker garbage collection script.

## Configuration options
`logFile="./docker-garby.log"` Logfile, will be appended with `-$(date +%Y%m%d)`.  
`maxSecondsOld=3600` How old a container has to be in seconds before removing it.

## Example
```sh
$ sh docker-garby.sh
$ tail docker-garby.log-20151104
[20151104191316] Image [fedora:21] (db9d08baf815190c5e08d29d2049465d69107bc2fbda60409ba90fc57422d398) unused.
[20151104191317] Image [fedora:21] (db9d08baf815190c5e08d29d2049465d69107bc2fbda60409ba90fc57422d398) removed.
[20151104191317] Image [] (ded7cd95e059788f2586a51c275a4f151653779d6a7f4dad77c2bd34601d94e4) unused.
[20151104191319] Image [] (ded7cd95e059788f2586a51c275a4f151653779d6a7f4dad77c2bd34601d94e4) removed.
[20151104191319] Image [konstruktoid/debian:wheezy] (e7923fc8c179eb134b492fcd2a3fe6e2860d7e4ec63fad319f9af245a0c4f8a1) unused.
[20151104191319] Image [konstruktoid/debian:wheezy] (e7923fc8c179eb134b492fcd2a3fe6e2860d7e4ec63fad319f9af245a0c4f8a1) removed.
[20151104191319] Image [centos:7 centos:latest] (e9fa5d3a0d0e19519e66af2dd8ad6903a7288de0e995b6eafbcb38aebf2b606d) unused.
[20151104191319] ERR: Image [centos:7 centos:latest] (e9fa5d3a0d0e19519e66af2dd8ad6903a7288de0e995b6eafbcb38aebf2b606d) was not removed.
[20151104191319] Image [alpine:2.7] (fda36aee3ed62c8c5ccccd37ebc10008e53fd4e544e8af0c76f1697c00b654b2) unused.
[20151104191320] Image [alpine:2.7] (fda36aee3ed62c8c5ccccd37ebc10008e53fd4e544e8af0c76f1697c00b654b2) removed.
```
