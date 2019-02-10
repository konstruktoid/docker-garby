#!/bin/sh
# shellcheck disable=2086
# shellcheck disable=2046

dockerPrune=${dockerPrune:=no}
pruneOptions=${pruneOptions}
excludeImages=${excludeImages:="$(pwd)/docker-garby.exclude"}
logFile=${logFile:=syslog}
maxSecondsOld=${maxSecondsOld:=3600}
networkPrune=${networkPrune:=yes}
pullExcluded=${pullExcluded:=yes}

getVersions(){
  serverVersion=$(docker version --format '{{ .Server.Version }}' | sed -e 's/-.*//g' -e 's/\.//g')
  clientVersion=$(docker version --format '{{ .Client.Version }}' | sed -e 's/-.*//g' -e 's/\.//g')
}

containerRemoval(){
  containerCount=$(docker ps --quiet --all | wc -l)

  if [ "$containerCount" -lt 1 ]; then
    logAllThings "No containers found."
    return
  fi

  if [ "$clientVersion" -ge 1130 ] && [ "$dockerPrune" = 'yes' ]; then
    logAllThings "Using docker container prune."
    if [ "$clientVersion" -ge 1704 ]; then
      docker container prune --force $pruneOptions
    else
      docker container prune --force
    fi
    return
  fi

  for con in $(docker ps --quiet --all); do
    # yeah, all this 'docker inspect' stuff should probably be done just once
    containerDead=$(docker inspect --format '{{.State.Dead}}' "$con")
    containerFinished=$(docker inspect --format '{{.State.FinishedAt}}' "$con")
    containerImage=$(docker inspect --format '{{.Image}}' "$con")
    containerName=$(docker inspect --format '{{.Name}}' "$con")
    containerRunningState=$(docker inspect --format '{{.State.Running}}' "$con")
    containerStatus=$(docker inspect --format '{{.State.Status}}' "$con")
    imageName=$(docker inspect --format '{{.RepoTags}}' "$containerImage")
    timeDiffOutput=$(timeDiff "$containerFinished")
    echo "$containerImage" >> "$usedImagesLog"
    remove=0

    if [ "$containerStatus" = "created" ] && [ "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) is in 'created' state."
      remove=1
    fi

    if [ "$containerDead" = "true" ] && [ "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) is in 'dead' state."
      remove=1
    fi

    if [ "$timeDiffOutput" -gt "$maxSecondsOld" ] && [ "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) finished $timeDiffOutput seconds ago."
      remove=1
    fi

    if [ "$remove" = 1 ]; then
      logAllThings "Container $containerName ($con) used image $imageName."

      if docker rm --volumes "$con" 2>/dev/null 1>&2; then
        logAllThings "Container $containerName ($con) removed."
      else
        logAllThings "ERR: Container $containerName ($con) was not removed."
      fi
    fi

  done
}

defineTmpFiles(){
  TMP=${TMPDIR:-$TMP}
  if [ -z "$TMP" ]; then
    export TMP='/tmp'
  fi
  allContainersLog=$(mktemp -p "${TMPDIR:-$TMP}" allContainers.XXXXXX)
  allImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" allImages.XXXXXX)
  allImagesTmpLog=$(mktemp -p "${TMPDIR:-$TMP}" allImagesTmp.XXXXXX)
  removeImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" removeImages.XXXXXX)
  usedImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" usedImages.XXXXXX)
  usedImagesTmpLog=$(mktemp -p "${TMPDIR:-$TMP}" usedImagesTmp.XXXXXX)
}

gatherBasicInfo(){
  allContainers=$(docker ps --no-trunc --quiet --all)
  allImages=$(docker images --no-trunc --quiet)

  echo "$allContainers" > "$allContainersLog"
  echo "$allImages" > "$allImagesLog"

  if test -e "$usedImagesLog"; then
    rm "$usedImagesLog"
  fi

  touch "$usedImagesLog"
}

imageRemoval(){
  imageCount=$(docker images --quiet --all | wc -l)

  if [ "$imageCount" -lt 1 ]; then
    logAllThings "No images found."
    return
  fi

  if [ "$clientVersion" -ge 1130 ] && [ "$dockerPrune" = 'yes' ]; then
    logAllThings "Using docker system prune."
    if [ "$clientVersion" -ge 1704 ]; then
      docker system prune --force $pruneOptions
    else
      docker system prune --force
    fi
    return
  fi

  sort "$allImagesLog" | uniq > "$allImagesTmpLog"
  sort "$usedImagesLog" | uniq > "$usedImagesTmpLog"

  comm -23 "$allImagesTmpLog" "$usedImagesTmpLog" > "$removeImagesLog"

  if [ -f "$excludeImages" ]; then
    grep -v '^#' "$excludeImages" | while read -r exclude; do
      if echo "$exclude" | grep -i '^label:' 2>/dev/null 1>&2; then
        echo "$exclude" | grep -i '^label:' | sed 's/^label://g' | while read -r label; do
          keepLabel=$(docker inspect --format '{{.Id}}{{.ContainerConfig.Labels}}' $(docker images -qa) | grep -i "$label" | sed 's/map\[.*//g')
          labelName=$(docker inspect --format '{{.RepoTags}}' "$keepLabel")
          sed -i "/$keepLabel/d" "$removeImagesLog"
          logAllThings "Image $labelName ($keepLabel) excluded."

          if [ "$pullExcluded" = 'yes' ]; then
            pullLabel=$(echo "$labelName" | sed -e 's/\[//g' -e 's/]//g')
            if docker pull "$pullLabel" 2>/dev/null 1>&2; then
              logAllThings "Image $labelName pulled."
            else
              logAllThings "Image $labelName was not pulled."
            fi
          fi
        done
      fi

      exclude=$(echo "$exclude" | grep -v '^label')
      if [ -n "$exclude" ]; then
        keepImage=$(docker inspect --format '{{.Id}}' "$exclude")
        imageName=$(docker inspect --format '{{.RepoTags}}' "$exclude")
        sed -i "/$keepImage/d" "$removeImagesLog"
        logAllThings "Image $imageName ($keepImage) excluded."

        if [ "$pullExcluded" = 'yes' ]; then
          pullImage=$(echo "$imageName" | sed -e 's/\[//g' -e 's/]//g')
          if docker pull "$pullImage" 2>/dev/null 1>&2; then
            logAllThings "Image $imageName pulled."
          else
            logAllThings "Image $imageName was not pulled."
          fi
        fi
      fi
    done
  fi

  grep -vE '^label|^#' "$removeImagesLog" | while read -r line; do
    imageName=$(docker inspect --format '{{.RepoTags}}' "$line")
    logAllThings "Image $imageName ($line) unused."

    if docker rmi -f "$line" 2>/dev/null 1>&2; then
      logAllThings "Image $imageName ($line) removed."
    else
      logAllThings "ERR: Image $imageName ($line) was not removed."
    fi
  done
}

logAllThings(){
  logDate=$(LC_ALL=C date -u +%Y%m%d)
  logDateEntry=$(LC_ALL=C date -u +%Y%m%d%H%M%S)

  if ! uname -v | grep -i "Darwin Kernel" 2>/dev/null 1>&2; then
    if find /proc/$$/exe -exec ls -l '{}' \; | grep busybox 2>/dev/null 1>&2; then
      echo "[$logDateEntry] $1"
    fi
  fi

  if [ "$logFile" = "syslog" ]; then
    logger -t 'docker-garby' -p 'user.info' "$1"
    elif [ -z "$logFile" ]; then
      echo "[$logDateEntry] $1"
    else
      echo "[$logDateEntry] $1" >> "$logFile-$logDate"
  fi
}

networkRemoval(){
  if [ "$clientVersion" -ge 1130 ] && [ "$networkPrune" = 'yes' ]; then
    logAllThings "Using docker network prune."
    if [ "$clientVersion" -ge 1704 ]; then
      docker network prune --force $pruneOptions
    else
      docker network prune --force
    fi
  fi
}

volumeRemoval(){
  volumeCount=$(docker volume ls --quiet --filter "dangling=true" | wc -l)

  if [ "$volumeCount" -lt 1 ]; then
    logAllThings "No dangling volumes found."
    return
  fi

  for vol in $(docker volume ls --quiet); do
    mountPoint=$(docker volume inspect --format '{{.Mountpoint}}' "$vol")
    logAllThings "Volume $mountPoint unused."
    if docker volume rm "$vol" 2>/dev/null 1>&2; then
      logAllThings "Volume $mountPoint removed."
    else
      logAllThings "ERR: Volume $mountPoint was not removed."
    fi
  done
}

printConfig(){
  logAllThings "clientVersion: $clientVersion"
  logAllThings "dockerPrune: $dockerPrune"
  logAllThings "pruneOptions: $pruneOptions"
  logAllThings "excludeImages: $excludeImages"
  logAllThings "logFile: $logFile"
  logAllThings "maxSecondsOld: $maxSecondsOld"
  logAllThings "pullExcluded: $pullExcluded"
  logAllThings "serverVersion: $serverVersion"
}

removeTmpFiles(){
  rm "$allContainersLog"
  rm "$allImagesLog"
  rm "$allImagesTmpLog"
  rm "$removeImagesLog"
  rm "$usedImagesLog"
  rm "$usedImagesTmpLog"
}

testDocker(){
  if ! docker ps -a 2>/dev/null 1>&2; then
    echo "Is Docker installed?"
    exit 1
  fi
}

timeDiff(){
  containerTime="$(echo "$1" | sed -e 's/ +.*/Z/' -e 's/ /T/')"
  dateEpoch=$(LC_ALL=C date -u +%s)
  convertToEpoch="$(LC_ALL=C date -u -d "$containerTime" +%s)"

  if [ "$convertToEpoch" -lt 0 ]; then
    # this is negative, which means no exit state"
    containerEpoch="$dateEpoch"
  else
    containerEpoch="$convertToEpoch"
  fi

  timeDiffSeconds="$((dateEpoch - containerEpoch))"
  echo "$timeDiffSeconds"
}

testDocker
getVersions
defineTmpFiles
printConfig
gatherBasicInfo
containerRemoval
imageRemoval
volumeRemoval
networkRemoval
removeTmpFiles
