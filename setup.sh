#!/bin/bash

chmod 700 setup.sh

# -- add the groups and users --
groupadd teaching_staff
groupadd lecturers
groupadd tutors
groupadd students

# add the lecturers
for lecturer in arman mohammad
do
    # useradd -U $lecturer
    usermod -a -G lecturers $lecturer
    usermod -a -G teaching_staff $lecturer
done

# add the tutors
for tutor in ilona esther immaculata
do
    # useradd -U $tutor
    usermod -a -G tutors $tutor
    usermod -a -G teaching_staff $tutor
done

# add the student users
student_count=93  # number of students starts at 0, hence theres 94 students
for student_num in $(seq 0 $student_count)
do
    name="student0"
    if [ $student_num -lt 10 ]; then
        name="${name}0"
    fi
    name="$name$student_num"

    # useradd -U $name
    usermod -a -G students $name
done

# -- setup directiories --

mkdir cybr371
chmod 700 cybr371
# only give teachers and students access to cybr371
setfacl -m g:teaching_staff:r-x cybr371
setfacl -m g:students:r-x cybr371

cd cybr371

touch grades.xlsx
chgrp teaching_staff grades.xlsx # change the group ownership to include lecturers and tutors
chmod 660 grades.xlsx

# create the assessment directories with Qs and As
for dir_name in lab1 lab2 lab3 lab4 lab5 assignment1 assignment2 midterm finaltest
do
    mkdir $dir_name # create assessment directory
    chmod 775 $dir_name # give lecturers full privileges, and students and tutors read execute

    cd $dir_name

    touch questions.pdf
    chgrp lecturers questions.pdf
    chmod 664 questions.pdf # set read write for lectuers, and read for everyone else

    touch solutions.pdf
    chgrp lecturers solutions.pdf
    chmod 660 solutions.pdf # only allow lecturers to read and write
    setfacl -m g:tutors:r-- solutions.pdf # allow the tutors to read the solutions

    # create student directories for each assessment
    student_num=0
    while [ $student_num -le $student_count ]
    do
        name="student0"
        if [ $student_num -lt 10 ]; then
            name="${name}0"
        fi
        name="$name$student_num"

        mkdir $name
        chgrp $name $name # set the group owner to be the students default group
        chmod 770 $name   # only the student can write and access their directory

        # allow lecturers and tutors to enter the students directory
        setfacl -m g:teaching_staff:r-x $name

        student_num=`expr $student_num + 1`
    done

    cd .. # return to cybr371 directory
done
