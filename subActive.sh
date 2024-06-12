#!/bin/bash

# Define colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 11)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 15)
RESET=$(tput sgr0)  # Reset color

# Function to display script usage
display_usage() {
    echo "SubActive is an active subdomain enumeration bash script that discovers subdomains for websites using various tools."
    echo ""
    echo -e "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help               Display this help message"
    echo "  -d, --domain <name>      Specify a single domain name to enumerate its subdomains"
    echo "  -sL, --subdomains-list   Specify a file containing a list of subdomains"
    echo "  -pw, --wordlist <file>   Specify a wordlist for PureDNS"
    echo "  -vw, --wordlist <file>   Specify a wordlist for VHost"
    echo "  -p, --permuted-list <file> Specify a permutations list"
    echo "  -ip, --ip-addresses <file> Specify a file containing IP addresses"
    echo "  -r, --resolvers <file>   Specify a file containing DNS resolvers"
    echo "  -o, --output <directory> Specify output directory (optional, if not specified, then a directory will be created with the domain name)"
    echo ""
    echo "Example: $0 -d example.com -sL <subdomain_list> -pw <puredns_wordlist> -vw <vhost_wordlist> -p permutations-list.txt -ip ip-addresses.txt -r fresh-resolvers.txt -o /path/to/output"
    exit 1
}

# Function for logging
log() {
    local log_file="recon.log"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$log_file"
    local message="$1"
    local color="$2"
}

# Default variables
domain=""
subdomains_list=""
puredns_wordlist=""
vhost_wordlist=""
permuted_list=""
ip_addresses=""
resolvers=""
output_dir=""
postfix="_subActive"

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_usage
            ;;
        -d|--domain)
            domain="$2"
            shift 2
            ;;
        -sL|--subdomains-list)
            subdomains_list="$2"
            shift 2
            ;;
        -pw|--puredns-wordlist)
            puredns_wordlist="$2"
            shift 2
            ;;
        -vw|--vhost-wordlist)
            vhost_wordlist="$2"
            shift 2
            ;;
        -p|--permuted-list)
            permuted_list="$2"
            shift 2
            ;;
        -ip|--ip-addresses)
            ip_addresses="$2"
            shift 2
            ;;
        -r|--resolvers)
            resolvers="$2"
            shift 2
            ;;
        -o|--output)
            output_dir="$2"
            shift 2
            ;;
        *)
            log "Unknown option: $1" "$RED"
            display_usage
            ;;
    esac
done

# Enable immediate exit on error
set -e

# Validate input parameters
if [ -z "$domain" ]; then
    log "Error: You must specify a domain name." "$RED"
    display_usage
elif [ -z "$subdomains_list" ]; then
    log "Error: You must specify a subdomains list file." "$RED"
    display_usage
elif [ -z "$puredns_wordlist" ]; then
    log "Error: You must specify a wordlist file for PureDNS." "$RED"
    display_usage
elif [ -z "$vhost_wordlist" ]; then
    log "Error: You must specify a wordlist file for VHost." "$RED"
    display_usage
elif [ -z "$permuted_list" ]; then
    log "Error: You must specify a permutations list file." "$RED"
    display_usage
elif [ -z "$ip_addresses" ]; then
    log "Error: You must specify an IP addresses list file." "$RED"
    display_usage
elif [ -z "$resolvers" ]; then
    log "Error: You must specify a DNS resolvers list file." "$RED"
    display_usage
fi

# Create output directory if not provided
if [ -z "$output_dir" ]; then
    output_dir="$domain"
    mkdir -p "$output_dir" || { log "Error: Could not create output directory: $output_dir" "$RED"; exit 1; }
else
    mkdir -p "$output_dir" || { log "Error: Could not create output directory: $output_dir" "$RED"; exit 1; }
fi

COMMON_PORTS_WEB="81,300,591,593,832,981,1010,1311,1099,2082,2095,2096,2480,3000,3128,3333,4243,4567,4711,4712,4993,5000,5104,5108,5280,5281,5601,5800,6543,7000,7001,7396,7474,8000,8001,8008,8014,8042,8060,8069,8080,8081,8083,8088,8090,8091,8095,8118,8123,8172,8181,8222,8243,8280,8281,8333,8337,8443,8500,8834,8880,8888,8983,9000,9001,9043,9060,9080,9090,9091,9200,9443,9502,9800,9981,10000,10250,11371,12443,15672,16080,17778,18091,18092,20720,32000,55440,55672"

# Banner
echo ""
echo "███████╗██╗   ██╗██████╗  █████╗  ██████╗████████╗██╗██╗   ██╗███████╗"
echo "██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██║██║   ██║██╔════╝"
echo "███████╗██║   ██║██████╔╝███████║██║        ██║   ██║██║   ██║█████╗  "
echo "╚════██║██║   ██║██╔══██╗██╔══██║██║        ██║   ██║╚██╗ ██╔╝██╔══╝  "
echo "███████║╚██████╔╝██████╔╝██║  ██║╚██████╗   ██║   ██║ ╚████╔╝ ███████╗"
echo "╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝  ╚═══╝  ╚══════╝"
echo ""

echo ">> ${RED}# Active subdomain discovery${RESET}"
echo -e ">>${YELLOW} # Created with ♥ by @TahirMujawar${RESET}"
echo ""
echo "__________________________♥ Scanning ♥________________________________"
echo ""

# DNS Bruteforcing
echo -e "${WHITE}Performing DNS bruteforcing...${RESET}"
log "Performing DNS bruteforcing"
puredns bruteforce "$puredns_wordlist" "$domain" -r "$resolvers" -w "$output_dir/dns-brute-results$postfix.txt" > /dev/null 2>&1
echo -e "${YELLOW}DNS bruteforcing completed!${RESET}"
log "DNS bruteforcing completed!"

# Generate permutations using Gotator
echo -e "${WHITE}Generating permutations for subdomains...${RESET}"
log "Generating permutations for subdomains"
gotator -sub "$subdomains_list" -perm "$permuted_list" -depth 1 -numbers 10 -mindup -adv -md > "$output_dir/permutations-for-sub$postfix.txt" > /dev/null 2>&1 
echo "Permutation generation completed!"
log "Permutation generation completed"

# Perform DNS resolution using PureDNS
echo -e "${WHITE}Resolving DNS for generated permutations...${RESET}"
log "Resolving DNS for generated permutations"
puredns resolve "$output_dir/permutations-for-sub$postfix" -r "$resolvers" > "$output_dir/resolved-dns-results$postfix.txt" > /dev/null 2>&1 
echo -e "${YELLOW}DNS resolution completed.${RESET}"
log "DNS resolution completed"

# JS/Source code scraping
echo -e "${WHITE}Web probing the subdomains...${RESET}"
log "Web probing the subdomains"
cat "$subdomains_list" | httpx -random-agent -retries 2 -no-color -o "$output_dir/httpx-probed$postfix.txt" > /dev/null 2>&1 
log "Web probing completed"

echo -e "${WHITE}Crawling URLs using Gospider...${RESET}"
log "Crawling URLs using Gospider"
gospider -S "$output_dir/httpx-probed$postfix.txt" -t 100 -d 3 --sitemap --robots -w -r > "$output_dir/gospider$postfix.txt" > /dev/null 2>&1 
echo -e "${WHITE}Cleaning the output...${RESET}"
log "Cleaning the output generated by Gospider"
sed -i '/^.\{2048\}./d' "$output_dir/gospider$postfix.txt" > /dev/null 2>&1
echo -e "${WHITE}Extracting subdomains from URLs...${RESET}"
log "Extracting subdomains from URLs"
cat "$output_dir/gospider$postfix.txt" | grep -Eo 'https?://[^ ]+' | sed 's/]$//' | unfurl -u domains | grep ".$domain$" | sort -u > "$output_dir/scrapped_subs$postfix.txt" > /dev/null 2>&1 
echo -e "${WHITE}Resolving subdomains...${RESET}"
log "Resolving subdomains"
puredns resolve "$output_dir/scrapped_subs$postfix.txt" -r "$resolvers" -w "$output_dir/resolved-subs$postfix.txt" > /dev/null 2>&1 
echo -e "${YELLOW}Scraping completed!${RESET}"
log "Scraping completed"

# Google Analytics 
echo -e "${WHITE}Performing Google Analytics relationships scan...${RESET}"
log "Performing Google Analytics relationships scan"
analyticsrelationships --url "$domain" > "$output_dir/google_analytics$postfix.txt" > /dev/null 2>&1
echo -e "${YELLOW}Google Analytics scan completed!${RESET}"
log "Google Analytics scan completed"

# TSL, CNAME, CSP
echo -e "${WHITE}Finding subdomains using Cero${RESET}"
log "Finding subdomains using Cero"
cero "$domain" | sed 's/^*.//' | grep -e "\." | sort -u > "$output_dir/cero-output$postfix.txt" > /dev/null 2>&1 
log "Finding subdomains using Cero completed"

echo -e "${WHITE}Finding subdomains using CSP${RESET}"
log "Finding subdomains using CSP"
cat "$subdomains_list" | httpx -csp-probe -status-code -retries 2 -no-color | anew "csp_probed$postfix.txt" | cut -d ' ' -f1 | unfurl -u domains | anew -q "$output_dir/csp_subdomains$postfix.txt" > /dev/null 2>&1 

echo -e "${WHITE}Finding subdomains using CNAME${RESET}"
log "Finding subdomains using CNAME"
dnsx -retry 3 -cname -l "$subdomains_list" > "$output_dir/cname-subdomains$postfix.txt" > /dev/null 2>&1  
echo -e "${YELLOW}Completed TCC!${RESET}"
log "TCC completed"

# VHOST
echo -e "${WHITE}Scanning using HostHunter...${RESET}"
log "Scanning using HostHunter"
hosthunter.py "$ip_addresses" > "$output_dir/hosthunter-output$postfix.txt" > /dev/null 2>&1  

echo -e "${WHITE}Bruteforcing using Gobuster...${RESET}"
log "Bruteforcing using Gobuster"
gobuster vhost -u "$domain" -t 50 -w "$vhost_wordlist" -s "200,204,301,302,307,401,403" -o "$output_dir/vhost-brute-output$postfix.txt" > /dev/null 2>&1  
echo -e "${YELLOW}VHOST scan completed!${RESET}"
log "VHOST scan completed"

echo -e "${WHITE}Running Unimap on common ports...${RESET}"
log "Running Unimap on common ports"
sudo unimap --fast-scan -f "$subdomains_list" --ports "$COMMON_PORTS_WEB" -k --url-output > "$output_dir/unimap_commonweb$postfix.txt" > /dev/null 2>&1  

echo -e "${WHITE}Checking web applications running on open ports...${RESET}"
log "Checking web applications running on open ports"
cat "$output_dir/unimap_commonweb$postfix.txt" | httpx -random-agent -status-code -retries 2 -no-color | cut -d ' ' -f1 | tee "$output_dir/probed_common_ports$postfix.txt" > /dev/null 2>&1  
echo -e "${YELLOW}Completed scanning common ports!${RESET}"
log "Scanning common ports completed"

# Web probing
echo -e "${WHITE}Running Unimap on common ports again...${RESET}"
log "Running Unimap on common ports again"
sudo unimap --fast-scan -f "$subdomains_list" --ports "$COMMON_PORTS_WEB" -k --url-output > "$output_dir/unimap_commonweb$postfix.txt" > /dev/null 2>&1  

echo -e "${WHITE}Checking web applications running on open ports...${RESET}"
log "Checking web applications running on open ports"
cat "$output_dir/unimap_commonweb$postfix.txt" | httpx -random-agent -status-code -retries 2 -no-color | cut -d ' ' -f1 | tee "$output_dir/probed_common_ports$postfix.txt" > /dev/null 2>&1  

echo -e "${WHITE}Concatenating all the files into all-subdomains$postfix${RESET}"
log "Concatenating all the files into all-subdomains$postfix"
cat *$postfix.txt | sort -u > "all-subdomains$postfix.txt"
log "All subdomains have been saved into all-subdomains$postfix.txt"

rm *$postfix.txt
log "Deleted all the files generated by tools"

echo -e "${YELLOW}Scan completed!${RESET}"
log "Scan completed"

# Output
if [ -z "$output_dir" ]; then
    echo -e "${GREEN}Output saved to $domain directory${RESET}"
    log "Output saved to $domain directory"
else
    echo -e "${GREEN}Output saved to $output_dir${RESET}"
    log "Output saved to $output_dir directory"
fi
