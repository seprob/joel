#!/bin/bash

while getopts :u:p:s:h argument; do
  case $argument in
      u)
         user_name=$OPTARG
         ;;
      p)
         user_password=$OPTARG
         ;;
      s)
         server_address=$OPTARG
         ;;
      h)
         echo "[*] Syntax: \"$0 -u user_name -p user_password -s server_address\"."
         exit 0
         ;;
      \?)
         echo "[!] Unknown option! Syntax: \"$0 -u user_name -p user_password -s server_address\"."
         exit 1
         ;;
   esac
done

shift $((OPTIND-1)) # Tell getopts to shift to the next argument.

# Check if user name and user password are set.
if [ -n "$user_name" ] && [ -n "$user_password" ]
then
   keyspaces=$(cqlsh -e "DESCRIBE KEYSPACES" -u $user_name -p $user_password $server_address)
else
   keyspaces=$(cqlsh -e "DESCRIBE KEYSPACES" $server_address)
fi

echo "[*] Keyspaces list:"
for keyspace in $keyspaces
do
   # Skip system keyspaces.
   if [ "$keyspace" != "system" ] &&
   [ "$keyspace" != "system_auth" ] &&
   [ "$keyspace" != "system_distributed" ] &&
   [ "$keyspace" != "system_schema" ] &&
   [ "$keyspace" != "system_traces" ]
   then
      echo "[*] - \"$keyspace\""
   fi
done

read -r -p "[?] Do you want to truncate these keyspaces? Answer \"y\" lub \"n\": " response

case $response in
   y)
      # For every keyspace.
      for keyspace in $keyspaces
      do
         # Skip system keyspaces.
         if [ "$keyspace" != "system" ] &&
         [ "$keyspace" != "system_auth" ] &&
         [ "$keyspace" != "system_distributed" ] &&
         [ "$keyspace" != "system_schema" ] &&
         [ "$keyspace" != "system_traces" ]
         then
            echo "[*] Working on keyspace: \"$keyspace\"."

            # Check if user name and user password are set.
            if [ -n "$user_name" ] && [ -n "$user_password" ]
            then
               tables=$(cqlsh -e "DESCRIBE KEYSPACE $keyspace" -u $user_name -p $user_password $server_address)
            else
               tables=$(cqlsh -e "DESCRIBE KEYSPACE $keyspace" $server_address)
            fi

            for line in $tables
            do
               if [[ $line == *"$keyspace"* ]] && [[ $line == *"."* ]]
               then
                  echo "[*] Truncating the table: \"$line\"."

                  # Check if user name and user password are set.
                  if [ -n "$user_name" ] && [ -n "$user_password" ]
                  then
                     cqlsh -e "CONSISTENCY ALL" -u $user_name -p $user_password $server_address &> /dev/null
                     cqlsh -e "TRUNCATE $line" -u $user_name -p $user_password $server_address
                  else
                     cqlsh -e "CONSISTENCY ALL" $server_address &> /dev/null
                     cqlsh -e "TRUNCATE $line" $server_address
                  fi
               fi
            done
         fi
      done
      ;;
   *)
      exit 0
      ;;
esac