#!/bin/bash

# Função para instalar o Golang
function install_golang() {
 echo "run as sudo"
 echo "Download golang start"
 wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
 echo "Download golang Fineshed"
 echo "Start descompact"
 rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
 echo "Fineshed descompact"
 echo "Add /usr/local/go/bin to the PATH environment variable"
 export PATH=$PATH:/usr/local/go/bin
 echo "Finished"
 echo "Checking installation"
 go version
 echo "Verification completed"
 echo "Finished install golang"
}

# Instalação das ferramentas Go
echo "Instalando Nuclei"
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
mv /root/go/bin/* /usr/bin/
nuclei -up

echo "Instalando Subfinder"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Httpx"
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Naabu"
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Katana"
go install github.com/projectdiscovery/katana/cmd/katana@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando amass"
go install -v github.com/owasp-amass/amass/v4/...@master
mv /root/go/bin/* /usr/bin/

echo "Instalando Waybackurls"
go install github.com/tomnomnom/waybackurls@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Assetfinder"
go install github.com/tomnomnom/assetfinder@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando chaos"
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando ffuf"
go install github.com/ffuf/ffuf@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando gau"
go install github.com/lc/gau/v2/cmd/gau@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando github-subdomains"
go install github.com/gwen001/github-subdomains@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando gitlab-subdomains"
go install github.com/gwen001/gitlab-subdomains@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando cero"
go install github.com/glebarez/cero@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando getJS"
go install github.com/003random/getJS@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando anew"
go install -v github.com/tomnomnom/anew@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Gospider"
go install github.com/jaeles-project/gospider@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando hakrawler"
go install github.com/hakluke/hakrawler@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando cariddi"
go install -v github.com/edoardottt/cariddi/cmd/cariddi@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando gf"
go install -v github.com/tomnomnom/gf@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Gxss"
go install github.com/KathanP19/Gxss@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Airixss"
go install github.com/ferreiraklet/airixss@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Qsreplace"
go install github.com/tomnomnom/qsreplace@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando subjac"
go install -v github.com/haccer/subjack@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando Dalfox"
go install github.com/hahwul/dalfox/v2@latest
mv /root/go/bin/* /usr/bin/

echo "Instalando crlfuzz"
GO111MODULE=on go install github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
mv /root/go/bin/* /usr/bin/

# Limpeza e organização
clear
cd
mkdir -p ~/tools
mkdir -p ~/.gf
mkdir -p ~/wordlists
mkdir -p ~/wordlists/payloads/

echo "Instalando ferramentas Python"
pip3 install uro

echo "Clonando Sublist3r"
cd && git clone https://github.com/aboul3la/Sublist3r.git ~/tools/Sublist3r && cd ~/tools/Sublist3r && sudo pip3 install -r requirements.txt 2> /dev/null

echo "Clonando SQLMap"
cd && git clone https://github.com/sqlmapproject/sqlmap.git ~/tools/sqlmap/ 2> /dev/null

echo "Baixando findomain"
cd ~/tools/ && wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux && chmod +x findomain-linux && mv findomain-linux /usr/bin/findomain 2> /dev/null

cp -r ~/go/src/github.com/tomnomnom/gf/examples ~/.gf/
echo 'source ~/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc

git clone https://github.com/1ndianl33t/Gf-Patterns 2> /dev/null
mv ~/Gf-Patterns/*.json ~/.gf/
rm -rf ~/Gf-Patterns 2> /dev/null

echo "Instalando Wordlists & Payloads"
cd ~/wordlists/ && wget https://raw.githubusercontent.com/MrxBug/common-paths-tomnomnom/main/common-paths-tomnomnom
cd ~/wordlists/payloads/ && wget https://raw.githubusercontent.com/MrxBug/lfi-paylouds-small/main/lfi.txt

echo "Instalação concluída"
