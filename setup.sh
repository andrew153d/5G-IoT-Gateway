
Ubuntu 22.04 LTS
sudo add-apt-repository ppa:nuandllc/bladerf
sudo apt-get update
sudo apt-get install -y bladerf libbladerf-dev bladerf-firmware-fx3
sudo apt-get install bladerf-fpga-hostedxa4    

sudo apt-get install gnuradio

sudo apt-get install -y libusb-1.0-0-dev libusb-1.0-0 git cmake g++ \
   libboost-all-dev libgmp-dev swig python3-numpy python3-matplotlib \
   python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
   libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
   liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
   python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
   libcodec2-dev libgsm1-dev libqt5svg5-dev libpulse-dev pulseaudio alsa-base \
   libasound2 libasound2-dev pybind11-dev libsndfile-dev
   
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
gnuradio-companion

mkdir ~/gr

cd ~/gr
git clone git://git.osmocom.org/gr-iqbal
cd gr-iqbal
git submodule update --init --recursive
mkdir build && cd build
cmake ..
make -j$(nproc) 
sudo make install && sudo ldconfig

cd ~/gr
git clone https://github.com/Nuand/gr-osmosdr -b dev-gr-3.9
cd gr-osmosdr
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install && sudo ldconfig

cd ~/gr
git clone https://github.com/Nuand/gr-bladeRF.git
cd gr-bladeRF
mkdir build
cd build
cmake ..
make -j4
sudo make install




#!/bin/bash
#
# Script to compile and install BladeRF & GNURadio 3.7 + CubicSDR + GQRX + URH + Soapy Modules
# 
# Testing and working on Ubuntu 18.04 LTS
# 
# Linux ubuntu 5.3.0-46-generic #38~18.04.1-Ubuntu SMP x86_64 GNU/Linux
#
# Run as:
# sudo  ./install-gnuradio-bladerf-ubuntu18.sh
# 

# Make source directory
mkdir -p $HOME/src

export BLADE="$HOME/blade"
mkdir -p $BLADE

# BladeRF Dependencies
sudo apt install -y libusb-1.0-0-dev libusb-1.0-0 build-essential cmake libncurses5-dev libtecla1 libtecla-dev pkg-config git wget doxygen help2man pandoc

# BladeRF Build and Installation
cd ~/src
git clone https://github.com/Nuand/bladeRF.git ./bladeRF
cd bladeRF
cd host/
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../
make && sudo make install && sudo ldconfig

# BladeRF Firmware and FPGA
cd $BLADE
wget https://www.nuand.com/fx3/bladeRF_fw_latest.img
wget https://www.nuand.com/fpga/hostedxA4-latest.rbf

cd $HOME

# Gnu Radio 3.7 Dependencies
# https://wiki.gnuradio.org/index.php/UbuntuInstall#Bionic_Beaver_.2818.04.29
sudo apt install cmake git g++ libboost-all-dev python-dev python-mako python-numpy python-wxgtk3.0 python-sphinx python-cheetah swig libzmq3-dev libfftw3-dev libgsl-dev libcppunit-dev doxygen libcomedi-dev libqt4-opengl-dev python-qt4 libqwt-dev libsdl1.2-dev libusb-1.0-0-dev python-gtk2 python-lxml pkg-config python-sip-dev

# Gnu Radio 3.8 Dependencies
# https://wiki.gnuradio.org/index.php/UbuntuInstall#Bionic_Beaver_.2818.04.29
# sudo apt -y install git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins python3-zmq python3-scipy python3-six python-six python-mako python3-lxml python-lxml python-numpy python3-numpy python3-pip

# GNU Radio Install (WORKING)
sudo -H pip3 install PyBOMBS
pybombs auto-config
pybombs recipes add-defaults

# gnuradio 3.7 + GQRX setup
pybombs prefix init ~/gnuradio -R gnuradio-stable
pybombs config -P gr-iqbal gitbranch gr3.7
pybombs config -P gr-osmosdr gitbranch gr3.7
pybombs refetch gr-iqbal gr-osmosdr

# gnuradio 3.8 + GQRX setup
# pybombs prefix init ~/gnuradio -R gnuradio-default
#sudo apt remove -y cmake
#sudo snap install cmake --classic

# Install GNURADIO + GQRX
pybombs -p gnuradio install gr-iqbal gr-osmosdr gqrx

# SoapySDR - CubicSDR dependency
cd ~/src
sudo apt -y install freeglut3 freeglut3-dev
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
mkdir build
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j4
sudo make install
sudo ldconfig
SoapySDRUtil --info #test SoapySDR install

# Liquid DSP - CubicSDR dependency
cd ~/src
git clone https://github.com/jgaeddert/liquid-dsp
cd liquid-dsp
./bootstrap.sh
CFLAGS="-march=native -O3" ./configure --enable-fftoverride
make -j4
sudo make install
sudo ldconfig

# Widgets - CubicSDR dependency
cd ~/src
sudo apt -y install libgtk2.0-dev
wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.3/wxWidgets-3.1.3.tar.bz2
tar -xvjf wxWidgets-3.1.3.tar.bz2
cd wxWidgets-3.1.3/
mkdir -p ~/src/wxWidgets-staticlib
./autogen.sh
./configure --with-opengl --disable-shared --enable-monolithic --with-libjpeg --with-libtiff --with-libpng --with-zlib --disable-sdltest --enable-unicode --enable-display --enable-propgrid --disable-webkit --disable-webview --disable-webviewwebkit --prefix=`echo ~/src/wxWidgets-staticlib` CXXFLAGS="-std=c++0x"
make -j4 && make install

# Cubic SDR
cd ~/src
git clone https://github.com/cjcliffe/CubicSDR.git
cd CubicSDR
mkdir build
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DOpenGL_GL_PREFERENCE=GLVND -DwxWidgets_CONFIG_EXECUTABLE=~/src/wxWidgets-staticlib/bin/wx-config
make
sudo make install

# Soapy Blade RF Module
cd ~/src
git clone https://github.com/pothosware/SoapyBladeRF.git
cd SoapyBladeRF
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig
SoapySDRUtil --probe="driver=bladerf"

# Soapy RTL SDR Module
cd ~/src
sudo apt -y install librtlsdr-dev
git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
sudo make install
sudo ldconfig
SoapySDRUtil --info


# URH
cd $HOME
sudo apt -y install python3-numpy python3-psutil python3-pyqt5 g++ libpython3-dev python3-pip cython3
sudo pip3 install urh
