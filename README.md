# reconeex

Do you want to perform a full automated continuous recon on your target so you will be always a step ahead of your rivals???
Congrats!!! Reconeex does that for you.

### How does it do that?
1. This tool first creates a table in your Bugbounty database which should be already created in your MySQL server. 
2. Then it runs Subfinder to find the subdomains of your target and then writes all the results in the table with the timestamp and the subfinder flags showing that when and how the results are found.
3. Next it performs a static DNS bruteforce using ShuffleDNS and the wordlists called best-dns-wordlist and 2m-subdomains from Assetnote as well as a wordlist containing all permutations of 4-char words.
4. Afterwards it uses the same tool to run a dynamic DNS bruteforce. The wordlists for the attack are generated using altDNS and DNSgen taking advantage of the subdomains which are found so far (This feature is commented out by default because the wordlists might be huge and not efficient to deploy).
5. Subsequently it updates the database with the newly discovered subdomains and stating the timestamp and dns_brute flag.
6. In the end it tries to resolve all subdomains and update the resolved flag in the table with the timestamp to indicate when it was resolved. 
To sum up, this tool can be re-run at a regular interval to be the first person to find a resolveable subdomain or even its existence.

### What does it leave behind?
`domains.txt`: This includes all the subdomains found after reconeex has finished running.

`subfinder.out`: This includes all the subdomains found by Subfinder.

`dns-dynamic-wlist.txt`: This includes all the words used for the DNS dynamic bruteforce attack.

`dns-static-wlist.txt`: This includes all the words used for the DNS static bruteforce attack.

`shuffledns_brute_dynamic.out`: This includes all the subdomains found by the DNS dynamic bruteforce attack.

`shuffledns_brute_static.out`: This includes all the subdomains found by the DNS static bruteforce attack.


## Usage

### command line 
```
# reconeex <TARGET> <TABLE_NAME>
./reconeex asda.com ASDA
```
### Crontab to run the command every 3 hours
```
0 */3 * * * cd /PATH/TO/reconeex/; ./reconeex asda.com ASDA
```
