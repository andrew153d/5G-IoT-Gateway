# Usr RPI Imager
#Instal Ubuntu Desktop 22.04.1 LTS (64-Bit)
# Write to SD Card
# Install SC card, plug in, and follow prompts to start up the Pi
# Open the command line and enter the following
# sudo apt-get install git
# git clone httos://github.com/andrew153d/Rpi-bladeRF-GNUradio.git
# cd Rpi-bladeRF-GNUradio
# chmod +x setup.sh
# ./setup.sh
# You will have to hit enter and say yes to a couple prompts


sudo apt-get update && sudo apt-get upgrade -y

sudo add-apt-repository ppa:nuandllc/bladerf
sudo apt-get update


mkdir ~/blade
sudo wget -P ~/blade/ https://www.nuand.com/fx3/bladeRF_fw_latest.img
sudo wget -P ~/blade/ https://www.nuand.com/fpga/hostedxA4-latest.rbf



sudo apt-get install -y libusb-1.0-0-dev libusb-1.0-0 git cmake g++ \
   libboost-all-dev libgmp-dev swig python3-numpy python3-matplotlib \
   python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
   libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
   liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
   python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
   libcodec2-dev libgsm1-dev libqt5svg5-dev libpulse-dev pulseaudio alsa-base \
   libasound2 libasound2-dev pybind11-dev libsndfile-dev
   
sudo add-apt-repository ppa:gnuradio/gnuradio-releases -y
sudo apt update
sudo apt install gnuradio -y
   
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

sudo apt-get install -y bladerf libbladerf-dev bladerf-firmware-fx3
sudo apt-get install bladerf-fpga-hostedxa4    

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
sudo make install && sudo ldconfig

sudo apt update

