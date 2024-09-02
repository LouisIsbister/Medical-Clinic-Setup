#! /bin/bash

echo -e "Enter the first name of the patient: \c"
read fname
echo -e "Enter the patients surname: \c"
read lname
echo -e "Enter the patients year of birth: \c"
read bday

patient_file="WellingtonClinic/patients/${fname}${lname}${bday}"

if [ -f $patient_file ]
then
    line_count=1

    while IFS="," read -ra BUFFER
    do
        # 1 is the patient details line
        # 2 is always empty
        # * is all other lines, i.e. the medication prescribed
        case $line_count in
            1 ) echo -e "Patient\t\tPrimary Doctor\tSecondary Doctors(s)"
                doctor_str=""
                len=$(expr ${#BUFFER[@]} - 1)
                # read all the primary and secondary doctors
                for i in $(seq 4 $len); do
                    doc_uname="${BUFFER[$i]:1}" # get the doctors name and remove the prefix ~ or #

                    # read the information of a doctor into an array, splitting on :
                    IFS=':' read -ra ARR <<< $(grep "$doc_uname" /etc/passwd)
                    doctor_str="${doctor_str}\t${ARR[4]}" # ARR[4] retrieves the comment in passwd file
                done
                echo -e "${BUFFER[0]} ${BUFFER[1]}$doctor_str\n"
                ;;
            2 ) echo -e "Date of Visit\tAttended Doctor\tMedication\tDosage"
                ;;
            * ) IFS=':' read -ra ARR <<< $(grep "${BUFFER[1]}" /etc/passwd) # get the doctors name/info
                echo -e "${BUFFER[0]}\t${ARR[4]}\t${BUFFER[3]}\t${BUFFER[4]}"
                ;;
        esac
        line_count=$(expr $line_count + 1)
    done < $patient_file
else
    echo -e "The file '$patient_file' does not exist.\n"
fi
