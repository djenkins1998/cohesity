#!/bin/bash
# PATH="$PATH:/home/cohesity/software/crux/bin/allssh.sh"

printf '\n'
echo "#---------------------------------------------------------------------------------------------------------------#"
echo "# Post configuration data collection script                                                                     #"
echo "# Last Updated Aug/01/2023                                                                                      #"
echo "# added -output prettyjson to iris_cli commands                                                                 #"
echo "# I removed the prefix, and timestamps on all files, so they are always the same.                               #"
echo "#                                                                                                               #"
echo "#---------------------------------------------------------------------------------------------------------------#"

# Reset
Color_Off=$'\e[m'       # Text Reset

# Regular Colors
Black=$'\e[0;30m'        # Black
Red=$'\e[0;31m'          # Red
Green=$'\e[0;32m'        # Green
Yellow=$'\e[0;33m'       # Yellow
Blue=$'\e[0;34m'         # Blue
Purple=$'\e[0;35m'       # Purple
Cyan=$'\e[0;36m'         # Cyan
White=$'\e[0;37m'        # White

# Bold
BBlack=$'\e[1;30m'       # Black
BRed=$'\e[1;31m'         # Red
BGreen=$'\e[1;32m'       # Green
BYellow=$'\e[1;33m'      # Yellow
BBlue=$'\e[1;34m'        # Blue
BPurple=$'\e[1;35m'      # Purple
BCyan=$'\e[1;36m'        # Cyan
BWhite=$'\e[1;37m'       # White

#---------------------------------------------------------------------------------------------------------------#
#printf '\n'
#echo "Enter a prefix to append to output files or press ENTER to leave blank: "
#read -e filename
#---------------------------------------------------------------------------------------------------------------#

printf '\n'
echo "Enter Cohesity Cluster IP Address or FQDN (ex: localhost:443 or clusterFQDN): "
read -e url
  while [[ "$url" =~ [^a-zA-Z0-9.:] || -z "$url" ]]
    do
      printf '\n'
      echo "${BRed}Cohesity Cluster IP Address / FQDN cannot be blank or contain special characters!${Color_Off}"
      printf '\n'
      echo "${Yellow}Please enter a valid Cohesity Cluster IP Address or FQDN (ex: localhost:443 or clusterFQDN): ${Color_Off}"
      printf '\n'
      read -e url
    done

printf '\n'
echo "Enter a Cohesity Cluster UI username that is associated with the Admin Role: "
read -e username
  while [[ "$username" =~ [^a-zA-Z0-9.:_] || -z "$username" ]]
    do
      printf '\n'
      echo "${BRed}Cohesity Cluster UI username cannot be blank or contain special characters!${Color_Off}"
      printf '\n'
      echo "${Yellow}Please enter a valid Cohesity Cluster UI username that is associated with the Admin Role: ${Color_Off}"
      printf '\n'
      read -e username
    done

printf '\n'
echo "Enter the Cohesity Cluster UI username password: "
read -es password
  while [ -z "$password" ]
    do
      printf '\n'
      echo "${BRed}Cohesity Cluster UI username password cannot be blank!${Color_Off}"
      printf '\n'
      echo "${Yellow}Please enter a valid Cohesity Cluster UI username password: ${Color_Off}"
      printf '\n'
      read -es password
    done

printf '\n'
echo "Enter the domain associated with the Cohesity Cluster UI user (ex: LOCAL or your active directory domain): "
read -e domain
  while [[ "$domain" =~ [^a-zA-Z0-9.:] || -z "$domain" ]]
    do
      printf '\n'
      echo "${BRed}Cohesity Cluster UI user domain cannot be blank or contain special characters!${Color_Off}"
      printf '\n'
      echo "${Yellow}Please enter a valid domain associated with the Cohesity Cluster UI user (ex: LOCAL or your active directory domain): ${Color_Off}"
      printf '\n'
      read -e domain
    done

printf '\n'

printf '\n'
echo "Cohesity Cluster Credential validation..."
printf '\n'
while ! token=`curl -X POST -k "https://$url/irisservices/api/v1/public/accessTokens" -H "accept: application/json" -H "content-type: application/json" -d "{ \"domain\": \"$domain\", \"password\": \"$password\", \"username\": \"$username\"}" | cut -d : -f 2 | cut -d, -f1 `
  do
  printf '\n'
  echo "Please enter Cohesity Cluster IP Address or FQDN (ex: localhost:443 or clusterFQDN): "
  read -e url
    while [[ "$url" =~ [^a-zA-Z0-9.:] || -z "$url" ]]
      do
        echo "Cohesity Cluster IP Address / FQDN cannot be blank or contain special characters!"
        echo "Please enter a valid Cohesity Cluster IP Address or FQDN (ex: localhost:443 or clusterFQDN): "
        read -e url
      done

  printf '\n'
  echo "Please enter a Cohesity Cluster UI username that is associated with the Admin Role: "
  read -e username
    while [[ "$username" =~ [^a-zA-Z0-9.:] || -z "$username" ]]
      do
        echo "Cohesity Cluster UI username cannot be blank or contain special characters!"
        echo "Please enter a valid Cohesity Cluster UI username that is associated with the Admin Role: "
  read -e username
      done

  printf '\n'
  echo "Please enter the Cohesity Cluster UI username password: "
  read -es password
    while [ -z "$password" ]
      do
        echo "Cohesity Cluster UI username password cannot be blank!"
        echo "Please enter a valid Cohesity Cluster UI username password: "
  read -es password
      done

  printf '\n'
  echo "Please enter the domain associated with the Cohesity Cluster UI user (ex: LOCAL or your active directory domain): "
  read -e domain
    while [[ "$domain" =~ [^a-zA-Z0-9.:] || -z "$domain" ]]
      do
        echo "Cohesity Cluster UI user domain cannot be blank or contain special characters!"
        echo "Please enter a valid domain associated with the Cohesity Cluster UI user (ex: LOCAL or your active directory domain): "
        read -e domain
      done
done
  printf '\n'

printf '\n'
echo "Cohesity Cluster Credentials verified successfully!"
printf '\n'


#---------------------------------------------------------------------------------------------------------------
# Run CONFIG data gathering commands.
#---------------------------------------------------------------------------------------------------------------

printf '\n'
echo "-------------------"
echo "${BPurple}CONFIG DATA COLLECTION${Color_Off}"
echo "-------------------"
echo " "
printf '\n'
echo "Making clusterinfo/CONFIG subdirectory to save all logs to..."
  mkdir clusterinfo 2> /dev/null
  mkdir clusterinfo/CONFIG 2> /dev/null
    sleep 5

#config_checks=("'ls -ltrGg ~/logs/*FATAL*|tail -4'" "'grep -i LDAP /home/cohesity/data/logs/bridge_exec.INFO'" "'iostat | grep -A 1 avg-cpu'")

printf '\n'
echo "Running CONFIG Data Collection Commands and saving output to CONFIG-Logs folder..."
  sleep 5
printf '\n'

# Run config call which writes the output to the /tmp folder.
# for w in "${config_checks[@]}"
# do
#         source /home/cohesity/software/crux/bin/allssh.sh
#         echo -e "\nCalling $w \n"
#         allssh.sh $w | python -m json.tool >> clusterinfo/CONFIG/$filename-CONFIG-`date +%s`.json
# done

echo -e "${BPurple}\nPulling Cluster_config${Color_Off}"
cluster_config.sh fetch 2> /dev/null
cat /tmp/cluster_config | head -n-2 | tail -n +4 > clusterinfo/CONFIG/CONFIG-CLUSTER_CONFIG.json

echo -e "${BPurple}\nPulling FATAL_logs${Color_Off}"
/home/cohesity/software/crux/bin/allssh.sh 'ls -ltrGg /home/cohesity/data/logs/*FATAL*|tail -4' > clusterinfo/CONFIG/CONFIG-FATALS_logs.txt

echo -e "${BPurple}\nPulling LDAP_errors${Color_Off}"
/home/cohesity/software/crux/bin/allssh.sh 'grep -i LDAP /home/cohesity/data/logs/bridge_exec.INFO' > clusterinfo/CONFIG/CONFIG-LDAP_errors.txt

echo -e "${BPurple}\nPulling IO_stats${Color_Off}"
/home/cohesity/software/crux/bin/allssh.sh 'iostat | grep -A 1 avg-cpu' > clusterinfo/CONFIG/CONFIG-IO_stats.txt

echo -e "${BPurple}\nPulling Cert_validation${Color_Off}"
curl -k -v "https://$url" &> /dev/stdout | tee -a clusterinfo/CONFIG/CONFIG-Cert_val.txt


#---------------------------------------------------------------------------------------------------------------
#Run API data gathering commands.
#---------------------------------------------------------------------------------------------------------------

printf '\n'
echo "-------------------"
echo "${BPurple}API DATA COLLECTION${Color_Off}"
echo "-------------------"
echo " "

echo "Making clusterinfo/API subdirectory to save all logs to..."
  mkdir clusterinfo 2> /dev/null
  mkdir clusterinfo/API 2> /dev/null
#  mkdir clusterinfo/API/$filename-API-certificates 2> /dev/null
    sleep 5

api_checks=(basicClusterInfo, activeDirectory, ldapProvider, domainControllers, antivirusGroups, icapConnectionStatus, infectedFiles, alerts, roles, users, groups, remoteClusters, vaults, viewBoxes, alertNotificationRules, idps, cluster, apps, scheduler, protectionPolicies, views)
api_stats_checks=(storage, viewBoxes, vaults, protectionJobs)
#public/ldapProvider/{id}/status

endTime=$(date +%s%N)
startTime=$(($endTime - 7*86400000000000))

#echo $endTime
#echo $startTime

printf '\n'
echo "Running API Data Collection Commands and saving output to API-Logs folder..."
printf '\n'
echo "${BGreen}This may take a few moments...${Color_Off}"
  sleep 5
printf '\n'

#get token
token=`curl -X POST -k "https://$url/irisservices/api/v1/public/accessTokens" -H "accept: application/json" -H "content-type: application/json" -d "{ \"domain\": \"$domain\", \"password\": \"$password\", \"username\": \"$username\"}" | cut -d : -f 2 | cut -d, -f1 `
echo "The Access Token is" $token

#Loop through each api call and write the output of each call to clusterinfo/API-Logs folder. Piping to json.tool to beautify.

echo -e "\nCalling certificates/webServer"
  curl -X GET -k "https://$url/irisservices/api/v1/public/certificates/webServer" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-certificates.json

echo -e "\nCalling backupjobsummary"
  curl -X GET -k "https://$url/irisservices/api/v1/backupjobssummary?_includeTenantInfo=true&allUnderHierarchy=true&endTimeUsecs=$endTime&onlyReturnJobDescription=false&startTimeUsecs=$startTime&outputFormat=csv" -H "accept: application/json" -H "Authorization: Bearer $token" > clusterinfo/API/API-protectionSummary.csv

echo -e "\nCalling kerberos"
  curl -X GET -k "https://$url/irisservices/api/v2/kerberos-providers" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-kerberos.json

echo -e "\nCalling keystone"
  curl -X GET -k "https://$url/irisservices/api/v2/keystones" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-keystone.json

echo -e "\nCalling views"
  curl -X GET -k "https://$url/irisservices/api/v2/views" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-views.json

echo -e "\nCalling mcmConfig"
  curl -X GET -k "https://$url/irisservices/api/v1/mcm/config" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-mcmConfig.json

echo -e "\nCalling ldap"
  curl -X GET -k "https://$url/irisservices/api/v1/public/tenants" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-ldap.json

echo -e "\nCalling firewall"
  curl -X GET -k "https://$url/irisservices/api/v1/nexus/firewall/list" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-firewall.json

echo -e "\nCalling protection jobs"
  curl -X GET -k "https://$url/irisservices/api/v1/public/protectionJobs?isDeleted=false" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-protectionJobs.json

echo -e "\nCalling stats/vaults/providers"
  curl -X GET -k "https://$url/irisservices/api/v1/public/stats/vaults/providers" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-stats_vaults_providers.json

for x in $(echo ${api_checks[@]} | sed "s/,/ /g")
do
  echo -e "\nCalling $x"
    curl -X GET -k "https://$url/irisservices/api/v1/public/$x" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-$x.json
done

for x in $(echo ${api_stats_checks[@]} | sed "s/,/ /g")
do
    echo -e "\nCalling stats/$x"
      curl -X GET -k "https://$url/irisservices/api/v1/public/stats/$x" -H "accept: application/json" -H "Authorization: Bearer $token" | python -m json.tool > clusterinfo/API/API-stats_$x.json
done


#---------------------------------------------------------------------------------------------------------------
# Run IRIS_CLI data gathering commands.
#---------------------------------------------------------------------------------------------------------------

printf '\n'
echo "-------------------"
echo "${BPurple}IRIS_CLI DATA COLLECTION${Color_Off}"
echo "-------------------"
echo " "

echo "Making clusterinfo/IRIS subdirectory to save all logs to..."
  mkdir clusterinfo 2> /dev/null
  mkdir clusterinfo/IRIS 2> /dev/null
    sleep 5

iris_checks=( "alert ls" "syslog-server list" "user list" "role list" "cluster ls-gflags" "cluster info" "interface list" "vlan list" "cluster get-dns-server" "cluster get-domain-names" "cluster status" "cluster get-etc-hosts" "cluster get-ntp-servers" "disk ls" "kms list" "support-server list")

declare -A iris_filenames

iris_filenames=( [alert ls]=alert [syslog-server list]=syslog [user list]=users [role list]=roles [cluster ls-gflags]=gflags [cluster info]=info [interface list]=interfacelist [vlan list]=vlanList [cluster get-dns-server]=dnsservers [cluster get-domain-names]=domainlist [cluster status]=clusterStatus [cluster get-etc-hosts]=etchosts [cluster get-ntp-servers]=ntpserver [disk ls]=diskls [kms list]=kms [support-server list]=supportServer)

printf '\n'
echo "Running IRIS_CLI Data Collection Commands and saving output to IRIS_CLI-Logs folder..."
  sleep 5
printf '\n'

#Loop through each iris_cli call and write the output of each call to clusterinfo/IRIS_CLI-Logs folder
for y in "${iris_checks[@]}"
do
      d=${iris_filenames[$y]}
        echo -e "\nRunning IRIS command${Purple} $y ${Color_Off}"
        iris_cli -output prettyjson -skip_password_prompt -domain $domain -username $username -password "$password" $y > clusterinfo/IRIS/IRIS-$d.json
 done

#---------------------------------------------------------------------------------------------------------------
# Run CLI data gathering commands.
#---------------------------------------------------------------------------------------------------------------

hostname=`hostname`
product=`product_name.sh`
hostips=`hostips`

 echo -e "\n"
 echo "${BGreen}************${Color_Off}"
 echo "${Green}Hostname: $hostname${Color_Off}"
 echo "${Green}Model: $product${Color_Off}"
 echo "${BGreen}************${Color_Off}"
 echo "${Green}Node IP's: $hostips${Color_Off}"
 echo "${BGreen}************${Color_Off}${Color_Off}"

 printf '\n'
 echo "-------------------"
 echo "${BPurple}CLI DATA CHECKS${Color_Off}"
 echo "-------------------"
 printf '\n'
 echo "Making clusterinfo/cli subdirectory to save all logs..."
 mkdir clusterinfo 2> /dev/null
 mkdir clusterinfo/cli 2> /dev/null
   sleep 3
cli_checks=( "primary_interface_name.sh" "list_all_nic_ports.sh" "list_all_disks.sh" "lsblk" "list_all_cpus.sh" "list_all_dimms.sh" "list_all_fans.sh" "list_all_psus.sh" ) # This throws an error. Fix syntax/format "df -h" "sudo ipmitool fru print"

declare -A cli_filenames
cli_filenames=( [primary_interface_name.sh]=primary_interface_name [list_all_nic_ports.sh]=list_all_nic_ports [list_all_disks.sh]=list_all_disks [lsblk]=lsblk [list_all_cpus.sh]=list_all_cpus [list_all_dimms.sh]=list_all_dimms [list_all_fans.sh]=list_all_fans [list_all_psus.sh]=list_all_psus ) # This throws an error. Fix syntax/format [df -h]=df -h [sudo ipmitool fru print]=fru_print
printf '\n'
  echo "Running CLI Data Check Commands and saving output to clusterinfo/cli folder."
printf '\n'
  echo "${BGreen}This may take a few moments...${Color_Off}"
    sleep 3
printf '\n'

for z in $(echo ${cli_checks[@]} | sed "s/,/ /g")
do
      d=${cli_filenames[$z]}

        echo -e "\nRunning${Purple} $z${Color_Off} on all nodes"
        allssh.sh $z >> clusterinfo/cli/$d-`date +%s`.json
done

for z in $(echo ${cli_checks[@]} | sed "s/,/ /g")
do
      d=${cli_filenames[$z]}

        echo -e "\nRunning${Purple} $z${Color_Off} on all nodes"
        allssh.sh $z >> clusterinfo/cli/$d.json
done

#---------------------------------------------------------------------------------------------------------------
#Create tarball from files
#---------------------------------------------------------------------------------------------------------------
echo "Creating tarball"
  tar czvfP clusterinfo.tar.gz /cohesity_users_home/support/clusterinfo/
printf '\n'
echo "${Cyan}Files have been compressed in /home/support/clusterinfo/clusterinfo.tar.gz. Please SCP this file to your desktop.${Color_Off}"
echo "${yellow}Example: copull clusterID token /home/support/clusterinfo.tar.gz${Color_Off}"
printf '\n'
