#!/usr/bin/env bash

GLOSSARY_FILE=docs/topics/modules/glossary.adoc
JSON_FILE=json/infotips.json

if [ -f $JSON_FILE ]; then rm $JSON_FILE; fi

terms=$(grep '^// term:' $GLOSSARY_FILE | wc -l);

for (( i=1; i<=$terms; i++ )); do
  TERM="$(awk "/^\/\/ term:/ { f = 1; n++ } f && n == $i; /^\/\/ endterm/ { f = 0 }" $GLOSSARY_FILE)"
  UUID=$(echo "$TERM" | sed -e '/^\/\/ term:/!d; s|^// term: \([^,]*\),.*$|\1|')
  L10N=$(echo "$TERM" | sed -e '/^\/\/ term:/!d; s|^// term: \([^,]*\), \(.*\)$|\2|')
  TERM_NAME="$(echo "$TERM" | sed -e '/^.*:: /!d' \
                                 -e 's|^\([^::]*\):: .*$|\1|')"
  TERM_DEFINITION="$(echo "$TERM" | sed -e '/^\/\/ term:/d; /^\/\/ endterm/d' \
                                       -e 's|^[^::]*:: ||')"
  echo -e "${UUID}[term]="$TERM_NAME"\n${UUID}[${L10N}]="$TERM_DEFINITION"" | jo -p >> $JSON_FILE
done

sed -i -e 's/^\}/},/' \
       -e '1i\[' \
       -e '$s/\},/}\n\]/' $JSON_FILE
