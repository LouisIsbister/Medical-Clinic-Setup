#!/bin/bash

chmod 700 setup-clinic.sh

groupadd clinic_staff
groupadd doctors
groupadd nurses

# give doctors read and execute permissions on the register patient script
chgrp doctors register-patient.sh
chmod 750 register-patient.sh

# allow nurses to run the check medication script
chgrp nurses check-medication.sh
chmod 750 check-medication.sh

# -- add users --

useradd -U drloun -c "Dr Lou Ngevity"
useradd -U drstethosc -c "Dr Stethos Cope"
useradd -U drbeas -c "Dr Bea Shure"
useradd -U philp -c "Phil Paine"

for doctor in drloun drstethosc; do
    usermod -a -G doctors $doctor       # add the doctor to doctors group
    usermod -a -G clinic_staff $doctor # add doctor to staff
done

for nurse in drbeas philp; do
    usermod -a -G nurses $nurse       # add nurse to nurses group
    usermod -a -G clinic_staff $nurse # add nurse to staff group
done

mkdir WellingtonClinic
chgrp clinic_staff WellingtonClinic # set clinic staff to be group owner
chmod 750 WellingtonClinic
cd WellingtonClinic

mkdir patients
chgrp doctors patients # make doctors group owners of patients dir
chmod 770 patients     # give doctors full access to the patients dir

# give nurses sudo access in the sudoers file, redirect the stdout result into /dev/null
echo "%nurses ALL=(ALL) NOPASSWD: /opt/check-medication.sh" | (EDITOR="tee -a" visudo) 1>/dev/null
