#!/bin/bash

# Função para update
sudo apt update && apt upgrade -y

# Função para instalar o Golang
function install_golang() {
    snap install go --classic
    echo "Finished"
    echo "Checking installation"
    go version
    echo "Verification completed"
    echo "Finished install golang"
}

# Instalação config.txt
apt install dos2unix
dos2unix config.txt

# Instalação das ferramentas Go
echo "Instalando Nuclei"
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
mv ~/go/bin/* /usr/local/bin/
nuclei -ut

echo "Instalando dnsx"
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando alterx"
go install github.com/projectdiscovery/alterx/cmd/alterx@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Subfinder"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
mv ~/go/bin/* /usr/local/bin/
subfinder

echo "Instalando Httpx"
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Naabu"
sudo apt install -y libpcap-dev
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Katana"
go install github.com/projectdiscovery/katana/cmd/katana@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando amass"
go install -v github.com/owasp-amass/amass/v4/...@master
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Waybackurls"
go install github.com/tomnomnom/waybackurls@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Assetfinder"
go install github.com/tomnomnom/assetfinder@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando chaos"
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando ffuf"
go install github.com/ffuf/ffuf@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando gau"
go install github.com/lc/gau/v2/cmd/gau@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando github-subdomains"
go install github.com/gwen001/github-subdomains@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando gitlab-subdomains"
go install github.com/gwen001/gitlab-subdomains@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando cero"
go install github.com/glebarez/cero@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando getJS"
go install github.com/003random/getJS@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando anew"
go install -v github.com/tomnomnom/anew@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Gospider"
go install github.com/jaeles-project/gospider@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando hakrawler"
go install github.com/hakluke/hakrawler@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando cariddi"
go install -v github.com/edoardottt/cariddi/cmd/cariddi@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando gf"
go install -v github.com/tomnomnom/gf@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Gxss"
go install github.com/KathanP19/Gxss@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Airixss"
go install github.com/ferreiraklet/airixss@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Qsreplace"
go install github.com/tomnomnom/qsreplace@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando subjac"
go install -v github.com/haccer/subjack@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando Dalfox"
go install github.com/hahwul/dalfox/v2@latest
mv ~/go/bin/* /usr/local/bin/

echo "Instalando crlfuzz"
GO111MODULE=on go install github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
mv ~/go/bin/* /usr/local/bin/

mkdir /src
cd /src
mkdir github.com
cd github.com
mkdir haccer
cd haccer
mkdir subjack
cd subjack
wget https://raw.githubusercontent.com/haccer/subjack/master/fingerprints.json

# Limpeza e organização
clear
mkdir -p ~/tools ~/.gf ~/wordlists ~/wordlists/payloads
sudo apt-get install jq -y 
cd ~/tools
wget https://github.com/Findomain/Findomain/releases/download/9.0.4/findomain-linux.zip
apt install unzip
unzip findomain-linux.zip
chmod +x findomain
sudo cp findomain /usr/bin/findomain
findomain -h
rm -r findomain-linux.zip

cd ~/tools
git clone https://github.com/1ndianl33t/Gf-Patterns 2> /dev/null
mv ~/tools/Gf-Patterns/*.json ~/.gf
rm -rf ~/Gf-Patterns 2> /dev/null

cd ~/tools
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip3 install -r requirements.txt

echo "Instalando Wordlists & Payloads"
cd ~/wordlists/ && wget https://raw.githubusercontent.com/MrxBug/common-paths-tomnomnom/main/common-paths-tomnomnom
cd ~/wordlists/payloads/ && wget https://raw.githubusercontent.com/MrxBug/lfi-paylouds-small/main/lfi.txt
cd ~/wordlists/ && wget https://raw.githubusercontent.com/lsnakazone/WordList/master/deepmagic.com-top500prefixes.txt
cd ~/wordlists/ && wget https://raw.githubusercontent.com/lsnakazone/WordList/master/deepmagic.com-top50kprefixes.txt
cd ~/wordlists/ && wget https://raw.githubusercontent.com/lsnakazone/WordList/master/subdomains-top1mil-5000.txt
cd ~/wordlists/ && wget https://raw.githubusercontent.com/lsnakazone/WordList/master/subdomains-top1mil-110000.txt

cd /root/nuclei-templates/http/vulnerabilities/generic/ 
wget https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/master/vulnerabilities/generic/open-redirect.yaml

echo "Instalação concluída"
