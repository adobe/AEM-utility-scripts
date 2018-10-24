#!/bin/bash

#Copyright 2018 Adobe. All rights reserved.
#This file is licensed to you under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License. You may obtain a copy
#of the License at http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software distributed under
#the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
#OF ANY KIND, either express or implied. See the License for the specific language
#governing permissions and limitations under the License.


echo "Welcome. This script will help you dump all users and groups from your AEM instance."
echo ""
echo "Please input the requested details or hit enter to accept the [default value]."
echo ""
read -p "Please input the AEM host in the form http(s)://hostname:port [http://localhost:4502]:" HOST
HOST=${HOST:-"http://localhost:4502"}
read -p "Please input the user to connect to AEM [admin]:" USER
USER=${USER:-"admin"}
read -s -p "Please input the password (it will not be displayed) [admin]:" PASSWORD
PASSWORD=${PASSWORD:-"admin"}
echo ""
echo "The users and groups will be dumped to the files all_users.txt and all_groups.txt respectively."

#Index var
I=0
PAGE_SIZE=10

while
    INITIAL_USER=$(( I * PAGE_SIZE ))

    REQUEST="$(curl -s --fail -u "${USER}":"${PASSWORD}" -w "HTTP_STATUS_CODE:%{http_code}" ${HOST}/bin/security/authorizables.json?ml=0\&start=${INITIAL_USER}\&limit=${PAGE_SIZE}\&_charset_=utf-8\&filter=\&hideGroups=true)"

    HTTP_STATUS_CODE=$(echo "$REQUEST" | sed -e 's/.*HTTP_STATUS_CODE\://')
    echo "HTTP_STATUS_CODE is $HTTP_STATUS_CODE"
    HTTP_BODY=$(echo "$REQUEST" | sed -e 's/HTTP_STATUS_CODE\:.*//g')
    [ "$HTTP_STATUS_CODE" == '200' ]
do
    if [ $I -eq 0 ]; then
        echo "$HTTP_BODY" | jq '.authorizables[].principal' | tr -d '"' > all_users.txt
    else
        echo "$HTTP_BODY" | jq '.authorizables[].principal' | tr -d '"' >> all_users.txt
    fi
    (( I++ ));
done

I=0

while
    INITIAL_GROUP=$(( I * PAGE_SIZE ))

    REQUEST="$(curl -s --fail -u "${USER}":"${PASSWORD}" -w "HTTP_STATUS_CODE:%{http_code}" ${HOST}/bin/security/authorizables.json?ml=0\&start=${INITIAL_GROUP}\&limit=${PAGE_SIZE}\&_charset_=utf-8\&filter=\&hideUsers=true)"

    HTTP_STATUS_CODE=$(echo "$REQUEST" | sed -e 's/.*HTTP_STATUS_CODE\://')
    #echo "HTTP_STATUS_CODE is $HTTP_STATUS_CODE"
    HTTP_BODY=$(echo "$REQUEST" | sed -e 's/HTTP_STATUS_CODE\:.*//g')
    [ "$HTTP_STATUS_CODE" == '200' ]
do
    if [ $I -eq 0 ]; then
        echo "$HTTP_BODY" | jq '.authorizables[].principal' | tr -d '"' > all_groups.txt
    else
        echo "$HTTP_BODY" | jq '.authorizables[].principal' | tr -d '"' >> all_groups.txt
    fi
    (( I++ ));
done


