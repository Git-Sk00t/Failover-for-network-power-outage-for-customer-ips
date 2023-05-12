#!/bin/bash
scriptPath=${0%/*}

#This is where we store the real time addresses for customers
mydomain="domain we use"
gdapikey="password"

function ct () 
{
    customer1main="IP 1"
    customer1backup="IP 2"
    dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "link to dns entry"`
    customer1gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`

    customer2main="IP 3"
    customer2backup="IP 4"
    dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "link to dns entry"`
    customer2gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`

    customer3main="IP 5"
    customer3backup="IP 6"
    dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "link to dns entry"`
    customer3gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
}

ct

echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
#This reads a file we will have stored on the system filled with customerips, ping them, and report back the ones that are down and store them in a text file
cat /home/test/customerips | while read output
do
    ping -c 3 -w 1 "$output" &> /dev/null
    if [ $? -eq 1 ]; then
    echo "$output"
    fi
done > /home/test/doc.txt

#This will send out an email to whatever addresses we like with an attached list of all down customers
cat /home/test/doc.txt | while read x; do echo $x ; done

echo -e "Attached is a list of all down customers:

\nPlease remote in to the system to input your response" | mail -s "Status Report for Systems" recipents -A /home/test/doc.txt -r return address
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "| Please reply 1 to failover only affected customers | Please reply 2 to failover all customers | Please reply 3 to change all customers back | Please reply 4 to ignore |"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

#This function runs the user input (ui)
function ui () 
{
    read command
    #This command will read the list of affected customers and then update those customers based on the list
    if [ "$command" == "1" ]; then
        cat /home/test/doc.txt | while read affected
        do
            if [ "$affected" == "$customer1main" ]; then
                curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer1backup}\"}]"
            fi
            
            if [ "$affected" == "$customer2main" ]; then
                curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer1backup}\"}]"
            fi
            
            if [ "$affected" == "$customer3main" ]; then
                curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer1backup}\"}]"
            fi
        done
    fi

    #This command will update ALL customer IPs to the backup IP
    if [ "$command" == "2" ]; then
        cat /home/test/Documents/backupips | while read all
        do
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer1backup}\"}]"
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer2backup}\"}]"
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer3backup}\"}]"
        done
    fi

    #This command will change all customer IP's back to main
    if [ "$command" == "3" ]; then
        ct
          if [ "$customer1gdip" != "$customer1main" ];then 
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer1main}\"}]"
          fi
          if [ "$customer2gdip" != "$customer2main" ];then
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer2main}\"}]"
          fi  
          if [ "$customer3gdip" != "$customer3main" ];then
            curl -s -X PUT "link to dns entry" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${customer3main}\"}]"
          fi
    fi

    #This command will ignore the request and simply stop the script in its tracks and wait to rerun
    if [ "$command" == "4" ]; then
        exit
    fi
    
    #Error checking
    if [ "$command" != "1" ] && [ "$command" != "2" ] && [ "$command" != "3" ] && [ "$command" != "4" ];then
        echo "Your input was incorrect"
        ui
    fi
}
ui

#This part is all commented out as it is a feature I am going to pitch to the team, I just thought it was neat so I made it. But if they don't like it I can delete it out.
#This command is for mail back commands, it will make the script hang here until it gets a reply to the inbox
#echo /home/test/Documents/Mailing/INBOX | entr -p sh -c 'kill -s INT "$PPID"'

# This is the function for email. Call the "message" function to use this after uncommenting

# function message () {
    cat /home/test/Documents/Mailing/INBOX | grep -w -e "$option1" -e "$option2" -e "$option3" -e "$option4" | while read testing; do
    
    if [ "$option1" = "$testing" ]; then
        echo "| Option 1 |"
    fi

    if [ "$option2" = "$testing" ]; then
        echo "| Option 2 |"
    fi

    if [ "$option3" = "$testing" ]; then
        echo "| Option 3 |"
    fi

    if [ "$option4" = "$testing" ]; then
        echo "| Option 4 |"
    fi
    done
# }