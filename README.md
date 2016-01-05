# docker-garby

![Dinotrux character Garby](http://www.dreamworkstv.com/wp-content/uploads/2015/05/DTX-character-GARBY.jpg "Dinotrux character Garby")

Just another Docker garbage collection script.

## Configuration options
`logFile=""` Write to console.  
`logFile="./docker-garby.log"` Write to a logfile, will be appended with `-$(date +%Y%m%d)`.  
`logFile="syslog"` Write to syslog.  
`maxSecondsOld=3600` How old a container has to be in seconds before removing it.

## Example

### Shell
```sh
$ sh docker-garby.sh
$ sudo journalctl SYSLOG_IDENTIFIER=docker-garby -r
-- Logs begin at Mon 2015-11-23 21:26:07 CET, end at Tue 2015-11-24 16:40:14 CET. --
Nov 24 16:39:32 lab01 docker-garby[3709]: Image [] (2c49029b02e501a7a70e74adcd8b71478a5c3652a56037cd52815f101fae46b2) unused.
Nov 24 16:39:32 lab01 docker-garby[3701]: Image [] (179c93e1cbd3918023c7cb65b4d665782292efb5e806c108fa1293538abc4b69) removed.
Nov 24 16:39:06 lab01 docker-garby[3693]: Image [] (179c93e1cbd3918023c7cb65b4d665782292efb5e806c108fa1293538abc4b69) unused.
Nov 24 16:39:05 lab01 docker-garby[3646]: Container /cass01 (5d488e9b74df) removed.
Nov 24 16:39:03 lab01 docker-garby[3639]: Container /cass01 (5d488e9b74df) used image [cassandra:latest].
Nov 24 16:39:03 lab01 docker-garby[3636]: Container /cass01 (5d488e9b74df) finished 65648 seconds ago.
Nov 24 16:39:03 lab01 docker-garby[3601]: Container /naughty_brahmagupta (b44fb1687291) removed.
Nov 24 16:39:02 lab01 docker-garby[3594]: Container /naughty_brahmagupta (b44fb1687291) used image [].
Nov 24 16:39:02 lab01 docker-garby[3591]: Container /naughty_brahmagupta (b44fb1687291) finished 71230 seconds ago.
Nov 24 16:39:02 lab01 docker-garby[3556]: Container /sleepy_raman (0eaf21670e43) removed.
Nov 24 16:39:02 lab01 docker-garby[3549]: Container /sleepy_raman (0eaf21670e43) used image [].
Nov 24 16:39:02 lab01 docker-garby[3546]: Container /sleepy_raman (0eaf21670e43) finished 71185 seconds ago.
Nov 24 16:39:01 lab01 docker-garby[3510]: Container /backstabbing_morse (195e00cafdbf) removed.
Nov 24 16:39:01 lab01 docker-garby[3503]: Container /backstabbing_morse (195e00cafdbf) used image [].
Nov 24 16:39:01 lab01 docker-garby[3500]: Container /backstabbing_morse (195e00cafdbf) finished 71127 seconds ago.
```

### Docker
```sh
$ docker run -v /var/run/docker.sock:/var/run/docker.sock konstruktoid/docker-garby
[20160105001725] Image [alpine:3.2] (sha256:1bb4fa2ed6b70e380252e6aeec4eed41ba0886ffbb570b9dc4350d81043043c2) unused.
[20160105001725] ERR: Image [alpine:3.2] (sha256:1bb4fa2ed6b70e380252e6aeec4eed41ba0886ffbb570b9dc4350d81043043c2) was not removed.
[20160105001725] Image [garby03:latest] (sha256:6c940d8fd8304efa956ccc3a735b53585a63498e06f6219d7f8501b376045e72) unused.
[20160105001725] Image [garby03:latest] (sha256:6c940d8fd8304efa956ccc3a735b53585a63498e06f6219d7f8501b376045e72) removed.
[20160105001725] Image [] (sha256:9553ccd2bfd8b7d4dc7a7bf8fb154acb17782cfd6422d9c2e833360eacb53f68) unused.
[20160105001725] Image [] (sha256:9553ccd2bfd8b7d4dc7a7bf8fb154acb17782cfd6422d9c2e833360eacb53f68) removed.
[20160105001725] Image [busybox:latest] (sha256:d9551b4026f0e2950ddb557cc640871710bf88476ca938b71499305647231b82) unused.
[20160105001725] Image [busybox:latest] (sha256:d9551b4026f0e2950ddb557cc640871710bf88476ca938b71499305647231b82) removed.
```

## Tested Docker versions
`Docker version 1.10.0-dev, build 194e695, experimental`  
`Docker version 1.9.0, build 76d6bc9`  
`Docker version 1.8.2-fc22, build f1db8f2/1.8.2`  
