Summary:        R statistics language 
License:        GPLv2        
Name:           R
Version:        %{r_ver}
Release:        1 
Group:          Development/Tools
Prefix:         /temp
AutoReq:        no
AutoProv:       no
BuildArch:      %{buildarch} 
Provides:       R = %{r_ver}, /bin/sh

%description
The R module provides the R statistics language.

%install
mkdir -p %{buildroot}/temp/ext/R-%{r_ver}
cp -RL %{r_dir}/*  %{buildroot}/temp/ext/R-%{r_ver}

%post
sed -i "s|export R_HOME=\$GPHOME/ext/R-3.3.3||g" $GPHOME/greenplum_path.sh
sed -i "s|export LD_LIBRARY_PATH=\$GPHOME/ext/R-3.3.3/lib:\$GPHOME/ext/R-3.3.3/extlib:\$LD_LIBRARY_PATH||g" $GPHOME/greenplum_path.sh
sed -i "s|export PATH=\$GPHOME/ext/R-3.3.3/bin:\$PATH||g" $GPHOME/greenplum_path.sh
echo "export R_HOME=\$GPHOME/ext/R-%{r_ver}" >> $GPHOME/greenplum_path.sh
echo "export LD_LIBRARY_PATH=\$GPHOME/ext/R-%{r_ver}/lib:\$GPHOME/ext/R-%{r_ver}/extlib:\$LD_LIBRARY_PATH" >> $GPHOME/greenplum_path.sh
echo "export PATH=\$GPHOME/ext/R-%{r_ver}/bin:\$PATH" >> $GPHOME/greenplum_path.sh

%postun
sed -i".bk" "s|export R_HOME=\$GPHOME/ext/R-%{r_ver}||g" $GPHOME/greenplum_path.sh
sed -i".bk" "s|export LD_LIBRARY_PATH=\$GPHOME/ext/R-%{r_ver}/lib:\$GPHOME/ext/R-%{r_ver}/extlib:\$LD_LIBRARY_PATH||g" $GPHOME/greenplum_path.sh
sed -i".bk" "s|export PATH=\$GPHOME/ext/R-%{r_ver}/bin:\$PATH||g" $GPHOME/greenplum_path.sh
rm -rf $GPHOME/greenplum_path.sh.bk

%files
/temp

