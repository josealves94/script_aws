#!/bin/sh
##################################
# Blocage auto IP sur WAF amazon #
# Date: 2017/02/14               #
# Version: 1.0                   #
##################################

IFS=$'\n'
export AWS_DEFAULT_OUTPUT="text"

# On télécharge le fichier de log httpd sur un des frontaux web
# Il y a 8 serveurs mais on se base sur un seul fichier en partant
# du principe que la charge est également reparti sur les 8 serveurs
# donc les fichiers de logs sont similaires
# Il y a donc en theorie 8 fois plus de connexion pour une IP que dans le fichier de log
# Cela nous permet d'évaluer le nombre de login maximum à partir du quel on bloque l'IP
SRV_LOGS=www-moncoyote-nfs3
MAX_LOGIN=16

# Liste des IPs autorisées (whitelist)
whitelist=("X.X.X.X" "Y.Y.Y.Y")
# Liste des ranges réseaux autorisées (whitelist)
whitelist_range=("X.X.X.X/27" "X.X.X.X/27")
rm -f /root/shop.access_log /root/shop.access_log_* 2> /dev/null
for var in 2 3 4 5
do
        scp www-moncoyote-nfs${var}:/var/log/httpd/shop.access_log /root/shop.access_log_${var}
        tail -n 2000 /root/shop.access_log_${var} >> /root/shop.access_log
        rm -f /root/shop.access_log_${var}
done

get_ip_sorted=$(cat /root/shop.access_log | grep "auth/login" | awk '{print $2}' | tr -d [\",] | sort | uniq -cd | sort -g)

rm /tmp/IP-blacklist 2> /dev/null

for line in $get_ip_sorted ;do
    blacklist="oui"
    count=$(echo $line | awk '{print $1}')
    ip=$(echo $line | awk '{print $2}')

    if (( $count > $MAX_LOGIN )) ; then

        # On compare l'IP avec la liste simple des IP à whitlister, si on trouve on ne bloque pas
        for ipwhit in ${whitelist[@]}; do
            if [ "$ipwhit" == "$ip" ]; then
                blacklist="non"
            fi
        done

        # On compare l'IP avec le tableau des ranges IP, si on trouve on ne bloque pas
        for rangewhit in ${whitelist_range[@]}; do

            for ipwhit_fromrange in $(nmap -sL ${rangewhit} | grep "Nmap scan report" | awk '{print $NF}'); do
                if [ "$ipwhit_fromrange" == "$ip" ]; then
                    blacklist="non"
                fi
            done

        done

#    echo "block IP $count $ip : $blacklist"
        if [ "$blacklist" == "oui" ] ; then
            echo "block IP $ip"
            echo $ip >> /tmp/IP-blacklist
            token=$(aws waf get-change-token)
            aws waf update-ip-set --ip-set-id fff28fa9-5d6e-464c-bab3-7cdcc40ae44f --change-token $token --updates "Action=INSERT,IPSetDescriptor={Type=IPV4,Value=${ip}/32}"
        fi
    fi
done
