#!/bin/sh

logFile="syslog"
maxSecondsOld=3600

containerRemoval(){
  for con in $(docker ps -qa); do
    # yeah, all this 'docker inspect' stuff should probably be done just once
    containerDead=$(docker inspect -f '{{.State.Dead}}' "$con")
    containerFinished=$(docker inspect -f '{{.State.FinishedAt}}' "$con")
    containerImage=$(docker inspect -f '{{.Image}}' "$con")
    containerName=$(docker inspect -f '{{.Name}}' "$con")
    containerRunningState=$(docker inspect -f '{{.State.Running}}' "$con")
    containerStatus=$(docker inspect -f '{{.State.Status}}' "$con")
    diffOutput=$(timeDiff "$containerFinished")
    imageName=$(docker inspect -f '{{.RepoTags}}' "$containerImage")
    echo "$containerImage" >> "$usedImagesLog"

    if [ "$containerStatus" = "created" -a "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) is in 'created' state."
    fi

    if [ "$containerDead" = "true" -a "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) is in 'dead' state."
    fi

    if [ "$diffOutput" -gt $maxSecondsOld -a "$containerRunningState" = "false" ]; then
      logAllThings "Container $containerName ($con) finished $diffOutput seconds ago."
      logAllThings "Container $containerName ($con) used image $imageName."
      docker rm "$con" 2>/dev/null 1>&2

      if [ "$?" -eq 0 ]; then
        logAllThings "Container $containerName ($con) removed."
        else
        logAllThings "ERR: Container $containerName ($con) was not removed."
      fi
    fi

  done
}

defineTmpFiles(){
  if [ -z "$TMP" ]; then
    export TMP='/tmp'
  fi
  allContainersLog=$(mktemp -p "${TMPDIR:-$TMP}" allContainers.XXXX)
  allImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" allImages.XXXX)
  allImagesTmpLog=$(mktemp -p "${TMPDIR:-$TMP}" allImagesTmp.XXXX)
  removeImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" removeImages.XXXX)
  usedImagesLog=$(mktemp -p "${TMPDIR:-$TMP}" usedImages.XXXX)
  usedImagesTmpLog=$(mktemp -p "${TMPDIR:-$TMP}" usedImagesTmp.XXXX)
}

gatherBasicInfo(){
  allContainers=$(docker ps --no-trunc -qa)
  allImages=$(docker images --no-trunc -q)

  echo "$allContainers" > "$allContainersLog"
  echo "$allImages" > "$allImagesLog"

  if test -e "$usedImagesLog"; then
    rm "$usedImagesLog"
  fi

  touch "$usedImagesLog"
}

imageRemoval(){
  sort "$allImagesLog" | uniq > "$allImagesTmpLog"
  sort "$usedImagesLog" | uniq > "$usedImagesTmpLog"
  comm -23 "$allImagesTmpLog" "$usedImagesTmpLog" > "$removeImagesLog"

  while read line
  do
    imageName=$(docker inspect -f '{{.RepoTags}}' "$line")
    logAllThings "Image $imageName ($line) unused."
    docker rmi -f "$line" 2>/dev/null 1>&2

    if [ "$?" -eq 0 ]; then
      logAllThings "Image $imageName ($line) removed."
      else
      logAllThings "ERR: Image $imageName ($line) was not removed."
    fi
    done < "$removeImagesLog"
}

logAllThings(){
  logDate=$(date +%Y%m%d)
  logDateEntry=$(date +%Y%m%d%H%M%S)
  if [ "$logFile" = "syslog" ]; then
    logger -i -t 'docker-garby' -p 'user.info' "$1"
    elif [ -z "$logFile" ]; then
    echo "[$logDateEntry] $1"
    else
    echo "[$logDateEntry] $1" >> "$logFile-$logDate"
  fi
}

removeTmpFiles(){
  rm "$allContainersLog"
  rm "$allImagesLog"
  rm "$allImagesTmpLog"
  rm "$removeImagesLog"
  rm "$usedImagesLog"
  rm "$usedImagesTmpLog"
}

timeDiff(){
  dateEpoch=$(date +%s)
  convertToEpoch=$(date -d "$1" +%s)

  if [ "$convertToEpoch" -lt 0 ]; then
    # this is negative, which means no exit state"
    containerEpoch="$dateEpoch"
    else
    containerEpoch="$convertToEpoch"
  fi

  timeDiffSeconds="$((dateEpoch - containerEpoch))"

  echo "$timeDiffSeconds"
}

defineTmpFiles
gatherBasicInfo
containerRemoval
imageRemoval
removeTmpFiles
