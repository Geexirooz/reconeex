#!/bin/bash

#####################
#Defining the varibles
#####################
TARGET=$1
TABLE_NAME=$2
DATABASE_NAME='bugbounty'
DATE=$(date +'%Y-%m-%d %H:%M:%S')
QUERY_CMD="sudo mysql -D $DATABASE_NAME -e"
SUBDOMAINS_FILENAME='domains.txt'
SUBFINDER_FILENAME='subfinder.out'
DYNAMIC_DNS_BRUTE_FILENAME='shuffledns_brute_dynamic.out'
STATIC_DNS_BRUTE_FILENAME='shuffledns_brute_static.out'
SHUFFLEDNS_RESOLVERS_FILENAME=$SHUFFLEDNS_RESOLVERS
MASS_DNS_PATH=$MASS_DNS


#####################
#create the database if it does not exist (This does its job at the first run)
#####################
$QUERY_CMD "CREATE  TABLE IF NOT EXISTS \`$DATABASE_NAME\`.\`$TABLE_NAME\` (\`subdomain\` VARCHAR(255), \`resolved\` BOOL DEFAULT FALSE, \`resolved_time\` DATETIME, \`ip\` VARCHAR(255), \`subfinder\` BOOL DEFAULT FALSE, \`subfinder_time\` DATETIME, \`dns_brute\` BOOL DEFAULT FALSE, \`dns_brute_time\` DATETIME, \`cert_search\` BOOL DEFAULT FALSE, \`cert_search_time\` DATETIME, PRIMARY KEY (\`subdomain\`) ) ENGINE = InnoDB;"

#####################
#This creates the file which contains all subdomains found by any tools (This does its job at the first run)
#####################
if [ ! -f "$SUBDOMAINS_FILENAME" ]; then
    touch $SUBDOMAINS_FILENAME
fi

#####################
#Subfinder runs HERE
#####################
run_subfinder(){
  echo [INFO] Running subfinder...
  subfinder -silent -d $1 -all -o $SUBFINDER_FILENAME > /dev/null
}
run_subfinder $TARGET

#####################
#This section writes all subdomains found by subfinder in the database
#####################
echo [INFO] Writing Subfinder results to the database...
for i in $(cat $SUBFINDER_FILENAME | anew $SUBDOMAINS_FILENAME);do

  #check if the subdomain already exists in the database
  RESULT=`$QUERY_CMD "SELECT * FROM $TABLE_NAME WHERE subdomain='$i';"`

  #if it does not exist -> create its record in the database
  if [ -z "$RESULT" ]   #if $RESULT is empty
  then
    $QUERY_CMD "INSERT INTO \`$TABLE_NAME\` (\`subdomain\`, \`subfinder\`, \`subfinder_time\`) VALUES ('$i', TRUE, '$DATE');"
  fi

done


#####################
#This part creates a static wordlist using AssetNote's public wordlists 
#PLUS 
#all permutations of 4-char words generated by Crunch
#####################
wlist_static_dns(){
        echo [INFO] Starting static DNS bruteforce attack...

        echo [INFO] Downloading \'best-dns-wordlist.txt\' wordlist from AssetNotes...
        curl -s https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt -o /tmp/best-dns-wordlist.txt_$TARGET

        echo [INFO] Downloading \'2m-subdomains.txt\' wordlist from AssetNotes...
        curl -s https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt -o /tmp/2m-subdomains.txt_$TARGET

        echo [INFO] Creating \'4-chars-wlist.txt\' wordlist using Crunch...
        crunch 1 4 abcdefghijklmnopqrstuvwxyz1234567890 -o /tmp/4-chars-wlist.txt_$TARGET &> /dev/null

        echo [INFO] Merging all wordlists into one...
        cat /tmp/best-dns-wordlist.txt_$TARGET /tmp/2m-subdomains.txt_$TARGET /tmp/4-chars-wlist.txt_$TARGET | sort -u > dns-static-wlist.txt
        echo [INFO] There are `wc -l dns-static-wlist.txt` words in the merged wordlist

        echo [INFO] Removing the the merged wordlists...
        rm -f /tmp/4-chars-wlist.txt_$TARGET /tmp/2m-subdomains.txt_$TARGET /tmp/best-dns-wordlist.txt_$TARGET
}

#####################
#This executes a static DNS bruteforce using the hereinabove created wordlist
#####################
dns_brute_force_static(){

    wlist_static_dns

    echo [INFO] Running Shuffledns \(static-bruteforce\) using the merged wordlist...
    shuffledns -silent -w dns-static-wlist.txt -d $1 -r $SHUFFLEDNS_RESOLVERS_FILENAME -m $MASS_DNS_PATH -o $STATIC_DNS_BRUTE_FILENAME > /dev/null
    echo [INFO] Shuffledns finished!
}

dns_brute_force_static $TARGET


#####################
#This section is commented out because dynamic DNS bruteforce might not be reasonable at any targets
#Sometimes you need to filter subfinder's output in order not to create a huge wordlist for your dynamic bruteforce
#So you can uncomment this part based on your needs
#####################

#####################
#This part creates a target's specific wordlist to execute a dynamic DNS bruteforce
#It uses altDNS and DNSgen and subfinder's output to generate the wordlist
#####################
#wlist_dynamic_dns(){
#    echo [INFO] Starting dynamic DNS bruteforce attack...
#
#    echo [INFO] Downloading DNSgen wordlist...
#    curl -s https://raw.githubusercontent.com/ProjectAnte/dnsgen/master/dnsgen/words.txt -o /tmp/dnsgen-words.txt_$TARGET
#
#    echo [INFO] Downloading altDNS wordlist...
#    curl -s https://raw.githubusercontent.com/infosec-au/altdns/master/words.txt -o /tmp/altdns-words.txt_$TARGET
#
#    echo [INFO] Merging the wordlists...
#    cat /tmp/altdns-words.txt /tmp/dnsgen-words.txt | sort -u > /tmp/words-merged.txt_$TARGET
#
#    echo [INFO] Removing the merged wordlists...
#    rm -rf /tmp/altdns-words.txt_$TARGET /tmp/dnsgen-words.txt_$TARGET
#
#    echo [INFO] Running DNSgen...
#    cat $1 | dnsgen -w /tmp/words-merged.txt_$TARGET - > /tmp/dynamic-dnsgen.txt_$TARGET
#
#    echo [INFO] Running altDNS...
#    altdns -i $1 -w /tmp/words-merged.txt_$TARGET -o /tmp/dynamic-altdns.txt_$TARGET
#
#    echo [INFO] Merging the dynamic wordlists...
#    cat /tmp/dynamic-altdns.txt_$TARGET /tmp/dynamic-dnsgen.txt_$TARGET | sort -u > dns-dynamic-wlist.txt
#    echo [INFO] There are `wc -l dns-dynamic-wlist.txt` words in the merged wordlist
#
#    echo [INFO] Removing the merged wordlists...
#    rm -rf /tmp/dynamic-dnsgen.txt_$TARGET /tmp/dynamic-altdns.txt_$TARGET /tmp/words-merged.txt_$TARGET
#}

#####################
#This executes a dynamic DNS bruteforce
#####################
#dns_brute_force_dynamic(){
#    wlist_dynamic_dns $SUBDOMAINS_FILENAME
#
#    echo [INFO] Running Shuffledns \(dynamic-bruteforce\) using the merged wordlist...
#    shuffledns -silent -l dns-dynamic-wlist.txt -d $1 -r $SHUFFLEDNS_RESOLVERS_FILENAME -m $MASS_DNS_PATH -o $DYNAMIC_DNS_BRUTE_FILENAME > /dev/null
#    echo [INFO] Shuffledns finished!
#}
#
#dns_brute_force_dynamic $TARGET


#####################
#This part write all subdomains found by above dns bruteforce attacks (dynamic+static)
#It specifies that the subdomain is found by DNS bruteforce attack (also put in the time that it was found)
#####################
echo [INFO] Writing DNS bruteforce results to the database...
for i in $(cat $DYNAMIC_DNS_BRUTE_FILENAME $STATIC_DNS_BRUTE_FILENAME | anew $SUBDOMAINS_FILENAME); do

  #Check if subdomain exists
  RESULT=`$QUERY_CMD "SELECT * FROM $TABLE_NAME WHERE subdomain='$i';"`

  if [ -z "$RESULT" ]   #if $RESULT is empty
  then
    $QUERY_CMD "INSERT INTO \`$TABLE_NAME\` (\`subdomain\`, \`dns_brute\`, \`dns_brute_time\`) VALUES ('$i', TRUE, '$DATE');"
  fi
  echo $i

done

#####################
#This part tries to resolve all subdomains existing in the $SUBDOMAINS_FILENAME file 
#It also puts in the time of resolution
#It can as well update a subdomain which was not resolved at the previous runs if it gets resolved at this run
#####################
echo [INFO] Resolving domains and writing the DNS records to the database...
for i in $(cat $SUBDOMAINS_FILENAME | dnsx -silent);do

  #To check if the subdomain is already resolved, if so it does not touch it
  RESULT=`$QUERY_CMD "SELECT * FROM $TABLE_NAME WHERE subdomain='$i' AND resolved=TRUE;"`

  if [ -z "$RESULT" ]   #if $RESULT is empty
  then
    $QUERY_CMD "UPDATE $TABLE_NAME SET \`resolved\`=TRUE, \`resolved_time\`='$DATE' WHERE \`subdomain\`='$i';"
  fi

done

echo [INFO] Reconeex ran successfully...!
