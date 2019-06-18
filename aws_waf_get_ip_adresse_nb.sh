#!/bin/bash
###########################
#
# Auteur:
# Date : 18/06/2019
# Description : sonde centreon pour detecter le nombre d'ip dans le waf amazon
#
#
###########################

#Memo for Nagios outputs
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

AWS=(which aws)
CMD=$(aws waf get-ip-set --ip-set-id fff28fa9-5d6e-464c-bab3-7cdcc40ae44f --output text |sed 1d |wc -l)
if [[ "${CMD}" -gt 9000 ]]; then
echo " CRITICAL - number of ip address in AWS WAF |Nb_ip=$CMD"
exit $STATE_CRITICAL

fi

if [[ "${CMD}" -gt 7000 ]]; then
echo " WARNING - number of ip address in AWS WAF |Nb_ip=$CMD"
exit $STATE_WARNING
fi

if [[ "${CMD}" -lt 7000 ]]; then

echo " OK - number of ip address in AWS WAF |Nb_ip=$CMD"
exit $STATE_OK
fi

echo "UNKNOW - No data was returned by aws WAF"
exit $STATE_UNKNOWN
