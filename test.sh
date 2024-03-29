#!/bin/bash

# Banner
banner(){
cat<<"EOF" 
               ███╗   ███╗██████╗ ██╗  ██╗
               ████╗ ████║██╔══██╗╚██╗██╔╝   
               ██╔████╔██║██████╔╝ ╚███╔╝ 
               ██║╚██╔╝██║██╔══██╗ ██╔██╗ 
               ██║ ╚═╝ ██║██║  ██║██╔╝ ██╗
               ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   
      :::!~!!!!!:.
                  .xUHWH!! !!?M88WHX:.
                .X*#M@$!!  !X!M$$$$$$WWx:.
               :!!!!!!?H! :!$!$$$$$$$$$$8X:
              !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
             :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
             ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
               !:~~~ .:!M"T#$$$$WX??#MRRMMM!
               ~?WuxiW*`   `"#$$$$8!!!!??!!!
             :X- M$$$$       `"T#$T~!8$WUXU~
            :%`  ~#$$$m:        ~!~ ?$$$$$$
          :!`.-   ~T$$$$8xx.  .xWW- ~""##*"               
.....   -~~:<` !    ~?T#$$@@W@*?$$      /`
W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
%"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
:::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
.~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
$R@i.~~ !     :   ~$$$$$B$$en:``
?MXT@Wx.~    :     ~"##*$$$$M~
EOF
echo -e "${BLUE}+ -- --=[Scanner by MRX"
echo -e "${yellow}+ -- --= SEM LOGS SEM CRIME :)"
}
banner
echo -e "${RED} $1 Starting a vulnerability scan."
sleep 4


# Prompting user for domain input
read -p "Enter the domain: " domain

# Checking if the domain is provided
if [ -z "$domain" ]; then
    echo "Error: Domain not provided."
    exit 1
fi

# Create folder for the domain
folder="$domain"
mkdir -p "$folder"

# Running subfinder to find subdomains
echo "Running subfinder..."
subfinder -d "$domain" -o "$folder/subdomains_tmp.txt"

# Running amass to find subdomains
echo "Running amass..."
amass enum -passive -norecursive -d "$domain" -o "$folder/subdomains_tmp.txt"

# Running Findomain
echo "Running Findomain..."
findomain -t $domain -q 2>/dev/null > "$folder/subdomains_tmp.txt"

# Running Assetfinder
echo "Running Assetfinder..."
assetfinder --subs-only $domain > "$folder/subdomains_tmp.txt"

# Running Sublist3r
echo "Running Sublist3r..."
sublist3r -d $domain -v -o "$folder/subdomains_tmp.txt"

# Running jldc 
echo "Running jldc..."
 curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | anew "$folder/subdomains_tmp.txt"

# Running wayback
echo "Running wayback..." 
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | anew "$folder/subdomains_tmp.txt"

# Running crt
echo "Running crt..."
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | sort -u > "$folder/subdomains_tmp.txt"

# Running abuseipdb
echo "Running abuseipdb..."
curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" | grep -E '<li>\w.*</li>' | sed -E 's/<\/?li>//g' | sed -e "s/$/.$domain/" | sort -u > "$folder/subdomains_tmp.txt"

# Running alienvault
echo "Running alienvault..."
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" | jq '.passive_dns[].hostname' 2>/dev/null | grep -o "\w.*$domain"|sort -u > "$folder/subdomains_tmp.txt"

# Running urlscan.io
echo "Running urlscan..."
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" | jq '.results[].page.domain' 2>/dev/null | grep -o "\w.*$domain"|sort -u > "$folder/subdomains_tmp.txt"

# Running RapidDNS
echo "Running RapidDNS..."
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep -v "RapidDNS" | grep -v "<td><a" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | anew "$folder/subdomains_tmp.txt"

# Running Naabu
echo "Running naabu..."
naabu -c 250 -l "$folder/subdomains_tmp.txt" -port "80,443,81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,3000,5000,8080,8000,8081,8888,8069,8009,8001,8070,8088,8002,8060,8091,8086,8010,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,8055,8021,8093,8022,8075,8044,8062,8023,8094,8012,8033,8063,8045,7000,9000,7070,9001,7001,10000,9002,7002,9003,7003,10001,80,443,4443" | anew "$folder/portscan.txt"
echo "Running httprobe Live ports"
cat "$folder/portscan.txt" | httprobe -c 25 > "$folder/liveports.txt"

# Cleaning and sorting subdomains
echo "Cleaning and sorting subdomains..."
sort -u "$folder/subdomains_tmp.txt" > "$folder/subdomains.txt"
rm "$folder/subdomains_tmp.txt"

# Running httpx to find live subdomains
echo "Finding live subdomains..."
cat "$folder/subdomains.txt" | httprobe -c 25 > "$folder/live_subdomains.txt"

# Running gau to find endpoints
echo "Finding endpoints with gau..."
echo "$domain" | gau -t 5 >> "$folder/Endpoints.txt"

# Running katana with -jc flag to find more endpoints
echo "Finding endpoints with katana..."
cat "$folder/live_subdomains.txt" | katana -d10 -jc >> "$folder/Endpoints.txt"

# Removing duplicates using uro
echo "Removing duplicates from Endpoints.txt..."
uro -i "$folder/Endpoints.txt" -o "$folder/Endpoints.txt"

# Using gf xss matcher to find XSS vulnerabilities
echo "Finding XSS vulnerabilities with gf..."
cat "$folder/Endpoints.txt" | gf xss >> "$folder/xss.txt"

# Using Gxss to send payloads to potential XSS endpoints
echo "Sending payloads with Gxss..."
cat "$folder/xss.txt" | Gxss -p khXSS -o "$folder/XSS_Ref.txt"

# Analyzing XSS references with dalfox
echo "Analyzing XSS references with dalfox..."
dalfox file "$folder/XSS_Ref.txt" -o "$folder/Vulnerable_XSS.txt"

echo "Vulnerable XSS endpoints saved in $folder/Vulnerable_XSS.txt"

# nuclei Severity
echo"Running Nuclei Severity..."
cat "$folder/liveports.txt" | nuclei -severity info,low,medium,high,critical -o "$folder/severity.txt"

# nuclei exposures,cves
echo"Running Nuclei exposures,cves..."
cat "$folder/live_subdomains.txt" | nuclei -t exposures/ -t cves/ -o "$folder/ExposuresCves.txt"
