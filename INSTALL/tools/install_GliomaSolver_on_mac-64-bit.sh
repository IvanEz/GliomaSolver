#!/bin/bash
echo "==============================================="
echo "  Installing libraries for the GliomaSolver    "
echo "==============================================="
InstallDir=$(pwd)
SolverDir=$(dirname "${InstallDir}")

echo ">>> Downloading externa libraries   <<<"
echo "--------------------------------------"
cd "${SolverDir}"
wget tdo.sk/~janka/GliomaSolverHome/libs/lib-mac-64-bit/lib.tgz
tar -zxf lib.tgz
cd lib

LIB_BASE=$(pwd)

echo " "
echo "--------------------------------------"
echo ">>> Installing libraries   <<<"
echo "--------------------------------------"
tbb=tbb40_20120613oss
hypre=hypre-2.10.0b

echo " Installing tbb:"
echo "--------------------------------------"
tar -zxf ${tbb}.tgz
cd ${tbb}
make clean
make
cd ../
rm ${tbb}.tgz

echo "--------------------------------------"
echo " Installing Hypre:"
echo "--------------------------------------"
tar -zxf ${hypre}.tgz
cd ${hypre}/src
make clean
./configure 
make install
cd ../../
rm ${hypre}.tgz

echo "--------------------------------------"
echo " Installing VTK:"
echo "--------------------------------------"
sudo port install vtk5

echo " "
echo "--------------------------------------"
echo ">>>       Creating Makefile       <<<"
echo "--------------------------------------"
cd ../makefile
UserName=$(hostname -s)
cp tools.make/make.mac make.${UserName}
cp tools.make/Makefile .
cp tools.make/setup_mac.sh setup_${UserName}.sh

sed -i 's|_USER_LIB_BASE_|'"${LIB_BASE}"'|g' make.${UserName}
sed -i 's|_USER_NAME_|'"${UserName}"'|g' Makefile
sed -i 's|_USER_LIB_BASE_|'"${LIB_BASE}"'|g' setup_${UserName}.sh

source setup_${UserName}.sh

echo "  "
echo "==============================================="
echo ">>>     The Installation is completed       <<<"
echo "==============================================="
echo " "
echo "Please update your .bashrc or similar file to include path to the installed libraries."
echo " To do so, put the text between the following dashed lines into your .bashrc file:"
echo "---------------------------------------"
cat setup_${UserName}.sh
echo "---------------------------------------"
echo "To compile the GliomaSolver do"
echo "make clean && make -j 4"
echo "==============================================="
