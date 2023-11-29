#!/bin/bash

# Set the path to the snippets folder
WATCHER_PATH='snippets'

# Set the Slack webhook
SLACK_WEBHOOK='https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'

file_contains(){
    # Get the content of the URL
    FILE_CONTENT=$(curl -sl $WATCHER_URL)
    
    # Check if $WATCHER_CONTAINS contains the string "null" and is therefore empty or not set
    if [[ $WATCHER_CONTAINS == "null" ]]; then
        exit 0
    fi
    # Check if $WATCHER_CONTAINS contains the string $WATCHER_CONTAINS and if not call the Slack webhook
    if [[ $FILE_CONTENT == *"$WATCHER_CONTAINS"* ]]; then
      echo "String found - nice!"
    else
      echo "String not found - not nice!"
      curl -X POST -H 'Content-type: application/json' --data '{"text":"String not found - not nice!"}' $SLACK_WEBHOOK
    fi
  }

# Find all files in the snippets folder
find $WATCHER_PATH -type f -print0 | while IFS= read -r -d '' file; do
  
  # Check if the file contains the string "WATCHER_URL" and is therefore a watcher file
  head -n 1 "$file" | grep 'WATCHER_URL' || continue >> /dev/null
  
  # Get the JSON from the first line of the file
  HEAD=$(head -n 1 "$file")
  JSON=$(sed "s/# //g" <<< "$HEAD")
  
  # Get the values from the JSON
  WATCHER_URL=$(echo $JSON | jq -r '.WATCHER_URL')
  WATCHER_HASH=$(echo $JSON | jq -r '.WATCHER_HASH')
  WATCHER_CONTAINS=$(echo $JSON | jq -r '.WATCHER_CONTAINS')   
  
  # Get the hash of the URL
  EVAL_HASH="curl -sl $WATCHER_URL | md5sum | cut -d ' ' -f 1"    
  CALLED_HASH="$(eval $EVAL_HASH)"
    
  # Check if the hashes are equal
  if [ "$WATCHER_HASH" == "$CALLED_HASH" ]; then
      echo "Both strings are equal."
  else
      echo "Strings are not equal."
      file_contains
  fi
    
      
done
