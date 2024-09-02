#! bin/bash

echo -e "Enter the following information about the patient."
echo -e "First name: \c"
read fname
echo -e "Last name: \c"
read lname
echo -e "Year of birth: \c"
read yob

file="$fname$lname$yob"
reg_date=$(date +%d-%m-%Y)
primary_doc=$(whoami)

# check that the patient is not a staff member of wellington clinic
grep "$fname$lname" /etc/passwd 1>/dev/null
if [ $? = 0 ]; then
    echo "A patient cannot be a user of the system!"
    exit
fi

secondary_docs=""
while [ 1 = 1 ]; do
    echo "Enter secondary doctor below (type 'na' to terminate):"
    echo -e " > \c"
    read name
    if [ "$name" == "na" ]; then
        break
    fi

    IFS=':' read -ra ARR <<< `grep "$name" /etc/passwd`

    # check that the username is asscoated with the doctors group
    groups "${ARR[0]}" | grep "doctors" &>/dev/null

    # if the provided name matches the full name of the doctor
    # and the user is in the doctors group
    if [ "${ARR[4]}" == "$name" -a $? = 0 ]; then
        secondary_docs="${ARR[0]} ${secondary_docs}"
    else
        echo "'${name}' is not a doctor!"
    fi
done

cd WellingtonClinic/patients/

# create the patient file
touch $file
chgrp $primary_doc $file
chmod 660 $file

file_contents="$fname,$lname,$yob,$reg_date,~$primary_doc"
# give the secondary doctors rw- permissions, and add them to the patient file
for sec_doc in $secondary_docs; do
    setfacl -m u:$sec_doc:rw- $file
    file_contents="${file_contents},#${sec_doc}"
done

echo "$file_contents" >> $file
