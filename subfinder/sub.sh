#!/bin/bash


SUBFINDER_FILE="subfinder.out"
SUBFINDER_TMP_FILE="geexi.subfinder.tmp.out"
NEW_DOMAINS_FILE="subfinder.out.new"
NEW_DOMAINS_LOGS="subfinder.out.new_logs"
TARGET=$1

if [ -f $SUBFINDER_TMP_FILE ]; then
        rm -f $SUBFINDER_TMP_FILE
fi

subfinder -d $TARGET -all -silent > $SUBFINDER_TMP_FILE

if [ -f $NEW_DOMAINS_FILE ]; then
        echo "----------------------------------------------------------------------------" >> $NEW_DOMAINS_LOGS
        date >> $NEW_DOMAINS_LOGS
        cat $NEW_DOMAINS_FILE >> $NEW_DOMAINS_LOGS && cat $NEW_DOMAINS_FILE >> $SUBFINDER_FILE && rm -f $NEW_DOMAINS_FILE
fi

while IFS= read -r line; do
     grep -q $line $SUBFINDER_FILE || echo $line >> $NEW_DOMAINS_FILE
done < $SUBFINDER_TMP_FILE

rm -f $SUBFINDER_TMP_FILE
