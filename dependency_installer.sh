#!/bin/bash
export MAXPARAMETERS=255

function array_contains_find_index() {
    local n=$#
    local i=0
    local value=${!n}

    for (( i=1; i < n; i++ )) {
        if [ "${!i}" == "${value}" ]; then
            echo "REMOVING $i: ${!i} = ${value}"
            return $i
        fi
    }
    return $MAXPARAMETERS
}

LIST=( $( apt-rdepends $1 | grep -v "^ " ) )
echo ${LIST[*]}
read -n1 -r -p "... Packages that will be downloaded (Continue or CTRL+C) ..."

RESULTS=( $( apt-get download ${LIST[*]} |& cut -d' ' -f 8 ) )
LISTLEN=${#LIST[@]}

while [ ${#RESULTS[@]} -gt 0 ]; do
    for (( i=0; i < $LISTLEN; i++ )); do
        array_contains_find_index ${RESULTS[@]} ${LIST[$i]}
        ret=$?

        if (( $ret != $MAXPARAMETERS )); then
            unset LIST[$i]
        fi
    done

    FULLRESULTS=$( apt-get download ${LIST[*]} 2>&1  )
    RESULTS=( $( echo $FULLRESULTS |& cut -d' ' -f 11 | sed -r "s/'(.*?):(.*$)/\1/g" ) )
done

apt-get download ${LIST[*]}
