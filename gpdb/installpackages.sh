#!/bin/bash
R_HOME=/usr/lib64/R
export PATH=$PATH:$R_HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R_HOME/lib64/R/extlib
input="./rlibs"
DESTINATION="$R_HOME/lib64/R/library/"
while IFS= read -r package
do
  if [ ! -d $DESTINATION/$package ]
then
./installpackages.R $package $DESTINATION
else
  echo "$package installed"
fi
done < "$input"
