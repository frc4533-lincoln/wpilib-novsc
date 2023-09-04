#!/bin/sh

# WPILib version
ver='2023.4.3'

# NI version
ni_ver='2023.3.0'

if ! [ -e extract-list.txt ]; then
    rm extract-list.txt
fi

touch extract-list.txt

for lib in wpilibc wpimath wpinet wpiutil hal ntcore wpilibNewCommands; do
    echo "maven/edu/wpi/first/${lib}/${lib}-cpp/${ver}/${lib}-cpp-${ver}-headers.zip" >> extract-list.txt
    echo "maven/edu/wpi/first/${lib}/${lib}-cpp/${ver}/${lib}-cpp-${ver}-linuxathena.zip" >> extract-list.txt
done

for lib in runtime netcomm visa; do
    echo "maven/edu/wpi/first/ni-libraries/${lib}/${ni_ver}/${lib}-${ni_ver}-headers.zip" >> extract-list.txt
    echo "maven/edu/wpi/first/ni-libraries/${lib}/${ni_ver}/${lib}-${ni_ver}-linuxathena.zip" >> extract-list.txt
done
