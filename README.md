# reconeex

Do you want to perform a full automated continuous recon on your target so you will be always a step ahead of your rivals???
Congrats!!! Reconeex does that for you.

### How does it do that?
1. This tool first creates a table in your Bugbounty database which should be already existing in your MySQL server. 
2. Then it runs [Subfinder](https://github.com/projectdiscovery/subfinder) to find the subdomains of your target and then writes all the results in the table with the `subfinder_time` and the `subfinder` fields showing that when and how the results are found.
3. Next it performs a static DNS bruteforce using [ShuffleDNS](https://github.com/projectdiscovery/shuffledns) and the wordlists called [best-dns-wordlist](https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt) and [2m-subdomains](https://wordlists-cdn.assetnote.io/data/manual/2m-subdomains.txt) from [Assetnote](https://assetnote.io/) as well as a wordlist containing all permutations of 4-char words.
4. Afterwards it uses the same tool to run a dynamic DNS bruteforce. The wordlists for the attack are generated using [altDNS](https://github.com/infosec-au/altdns) and [DNSgen](https://github.com/ProjectAnte/dnsgen) taking advantage of the subdomains which are found so far (This feature is commented out by default because the wordlists might be huge and not efficient to deploy).
5. Subsequently it updates the database with the newly discovered subdomains and stating the timestamp and `dns_brute` flag.
6. In the end it tries to resolve all subdomains and update the `resolved` flag in the table with the timestamp to indicate when it was resolved. 
To sum up, this tool can be re-run at a regular interval to be the first person to find a resolveable subdomain or even its existence.

### What does it leave behind?
`domains.txt`: This includes all the subdomains found after reconeex has finished running.

`subfinder.out`: This includes all the subdomains found by Subfinder.

`dns-dynamic-wlist.txt`: This includes all the words used for the DNS dynamic bruteforce attack.

`dns-static-wlist.txt`: This includes all the words used for the DNS static bruteforce attack.

`shuffledns_brute_dynamic.out`: This includes all the subdomains found by the DNS dynamic bruteforce attack.

`shuffledns_brute_static.out`: This includes all the subdomains found by the DNS static bruteforce attack.

### What are required Environment Variables?
`SHUFFLEDNS_RESOLVERS`: This should be the path to the resolvers you want ShuffleDNS to use

`MASS_DNS`: This should be the path to MassDNS


## Usage

### command line 
```
# Set EVs
export SHUFFLEDNS_RESOLVERS='/path/to/resolvers'
export MASS_DNS='path/to/massdns'

# Make the script executable
chmod u+x reconeex

# reconeex <TARGET> <TABLE_NAME>
./reconeex asda.com ASDA
```
### Crontab to run the command every 3 hours
```
0 */3 * * * cd /PATH/TO/reconeex/; ./reconeex asda.com ASDA
```
### Database results sample using the following command
`sudo mysql -D bugbounty -e 'select * from asda limit 40;'` 
```
+----------------------------------------+----------+---------------------+------+-----------+---------------------+-----------+---------------------+-------------+------------------+
| subdomain                              | resolved | resolved_time       | ip   | subfinder | subfinder_time      | dns_brute | dns_brute_time      | cert_search | cert_search_time |
+----------------------------------------+----------+---------------------+------+-----------+---------------------+-----------+---------------------+-------------+------------------+
| 10130158.email.cards.asda.com          |        0 | NULL                | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| 6309965.mobile.asda.com                |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| academy.asda.com                       |        0 | NULL                | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ad.asda.com                            |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| admanager-groceries-qa.asda.com        |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| admanager-groceries.asda.com           |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| admin.onlinedoctor.asda.com            |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| advised-life-insurance.asda.com        |        0 | NULL                | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| advised-life.asda.com                  |        0 | NULL                | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| affiliates.asda.com                    |        1 | 2023-06-06 10:24:46 | NULL |         0 | NULL                |         1 | 2023-06-06 10:24:46 |           0 | NULL             |
| aislespy.asda.com                      |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| aislespyblog.asda.com                  |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-scus-groceries-qa.asda.com       |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-scus-nonprod.asda.com            |        1 | 2023-06-06 10:24:46 | NULL |         0 | NULL                |         1 | 2023-06-06 10:24:46 |           0 | NULL             |
| ak-az-scus-www-qa.asda.com             |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-scus.asda.com                    |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-uks-stage.asda.com               |        1 | 2023-06-06 10:24:46 | NULL |         0 | NULL                |         1 | 2023-06-06 10:24:46 |           0 | NULL             |
| ak-az-uks.asda.com                     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-ukw-stage.asda.com               |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-ukw.asda.com                     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-az-wus-nonprod.asda.com             |        1 | 2023-06-06 10:24:46 | NULL |         0 | NULL                |         1 | 2023-06-06 10:24:46 |           0 | NULL             |
| ak-az-wus.asda.com                     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-cdc-f5-groceries-stage.asda.com     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-cdc-f5-groceries.asda.com           |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-cdc-f5-www-stage.asda.com           |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-cdc-f5-www.asda.com                 |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-bot-groceries-stage.asda.com    |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-bot-groceries.asda.com          |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-f5-bot-groceries-stage.asda.com |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-f5-bot-groceries.asda.com       |        1 | 2023-06-06 10:24:46 | NULL |         0 | NULL                |         1 | 2023-06-06 10:24:46 |           0 | NULL             |
| ak-dal-f5-groceries-stage.asda.com     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-f5-groceries.asda.com           |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-f5-image-groceries.asda.com     |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-groceries-qa4.asda.com          |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-groceries-stage.asda.com        |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dal-groceries.asda.com              |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dfw-f5-bot-groceries-qa.asda.com    |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dfw-f5-bot-groceries-stage.asda.com |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dfw-f5-bot-groceries.asda.com       |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
| ak-dfw-f5-groceries-it2.asda.com       |        1 | 2023-06-06 10:24:46 | NULL |         1 | 2023-06-06 10:24:46 |         0 | NULL                |           0 | NULL             |
+----------------------------------------+----------+---------------------+------+-----------+---------------------+-----------+---------------------+-------------+------------------+
```
