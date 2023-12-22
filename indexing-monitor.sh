#!/bin/bash
#

[[ $1 != "" ]] && MEDIA_TYPE="$1" || MEDIA_TYPE="music"
OUTPUT="FIRST"
LAST_OUTPUT="UNSET"

echo "Tracking indexing on $MEDIA_TYPE.."

while [ "$LAST_OUTPUT" != "$OUTPUT" ]
do
  LAST_OUTPUT=$OUTPUT
  OUTPUT=$(sudo psql mediaserver postgres --command="SELECT COUNT(*) AS count FROM $MEDIA_TYPE;")
  if [ "$LAST_OUTPUT" != "$OUTPUT" ]
  then
    echo
    echo "Current Total:"
    echo $OUTPUT
    echo
    echo "Indexing status analysing..."
    declare -i i=1
    while [ $i -le 5 ]
    do
      LAST_FILE_OUTPUT=$FILE_OUTPUT
      FILE_OUTPUT=$(sudo psql mediaserver postgres --command="SELECT * FROM $MEDIA_TYPE WHERE id = (SELECT MAX (id) FROM $MEDIA_TYPE)" | grep volume)
      if [ "$FILE_OUTPUT" != "$LAST_FILE_OUTPUT" ]
      then
        echo
        echo "Last indexed file ($i):"
        echo $FILE_OUTPUT
        sleep 4
      else
        sleep 1
        echo -n "-"
      fi
      ((i++))
    done
    echo
    echo "--------------------------------"
  fi
  sleep 4
done
echo
echo "Indexing has completed or stalled"
echo
echo "--------------------------------"
