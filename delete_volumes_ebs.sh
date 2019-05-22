#!/bin/bash
#############
#
# Auteur : José Alves
# Date : 02/10/2017
# Description :Lister puis supprimer des volumes ebs inutilisées
#
#####################

echo "Nombre de volumes disponibles à supprimer : "
aws ec2 describe-volumes  | grep available | awk '{print $9}' |wc -l

# ancienne commande ne fonctionne plus depuis le 06/08/2018 suite aux modifs côté AWS
#for volumes in `aws ec2 describe-volumes  | grep available | awk '{print $9}' | grep vol| tr '\n' ' '`
for volumes in `aws ec2 describe-volumes --filters Name=status,Values=available |grep VolumeId | awk '{print $4}'`
do
        echo $volumes
 # supprimer les volumes available non-utilisés
aws ec2 delete-volume --volume-id $volumes

done

# supprimer des volumes -- ATTENTION  ci-dessous non testé en prod --
#aws ec2 delete-volume $(aws ec2 describe-volumes  | grep available | awk '{print $9}' | tr '\n' ' ')
