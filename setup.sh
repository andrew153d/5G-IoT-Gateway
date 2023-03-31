# Usr RPI Imager
#Instal Ubuntu Desktop 22.04.1 LTS (64-Bit)
# Write to SD Card
# Install SD card, plug in, and follow prompts to start up the Pi
# Open the command line and enter the following
# sudo apt-get install git
# git clone https://github.com/andrew153d/5G-IoT-Gateway.git
# cd 5G-IoT-Gateway
# chmod +x setup.sh
# ./setup.sh
# You will have to hit enter and say yes to a couple prompts

# -------- install vncserver --------
#https://www.youtube.com/watch?v=3K1hUwxxYek
cd ~/
sudo apt update
sudo apt install lightdm -y
sudo apt install x11vnc -y
sudo mv 5G-IoT-Gateway/utils/x11vnc.service /lib/systemd/system/

systemctl daemon-reload
systemctl enable x11vnc.service
systemctl start x11vnc.service
systemctl status x11vnc.service
# -------- --------


sudo apt-get update && sudo apt-get upgrade -y

sudo apt install ssh -y

# -------- install bladerf images--------
sudo add-apt-repository -y ppa:nuandllc/bladerf
sudo apt-get update


mkdir ~/blade
sudo wget -P ~/blade/ https://www.nuand.com/fx3/bladeRF_fw_latest.img
sudo wget -P ~/blade/ https://www.nuand.com/fpga/hostedxA4-latest.rbf
# -------- --------

# -------- install GNU-radio and dependencies --------
sudo apt-get install -y libusb-1.0-0-dev libusb-1.0-0 git cmake g++ \
   libboost-all-dev libgmp-dev swig python3-numpy python3-matplotlib \
   python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
   libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
   liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
   python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
   libcodec2-dev libgsm1-dev libqt5svg5-dev libpulse-dev pulseaudio alsa-base \
   libasound2 libasound2-dev pybind11-dev libsndfile-dev net-tools -y
   
sudo add-apt-repository ppa:gnuradio/gnuradio-releases -y
sudo apt update
sudo apt install gnuradio -y
   
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
# -------- --------

# -------- install bladerf(doesn't seem to install python bindings)--------
sudo apt-get install -y bladerf libbladerf-dev bladerf-firmware-fx3 -y
sudo apt-get install bladerf-fpga-hostedxa4 -y   
# -------- --------

# -------- install GNU-radio blocks--------
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
# -------- --------


# -------- install bladeRF python bindings--------
# install bladeRF python module from 
# https://github.com/Nuand/bladeRF/tree/master/host#linux-and-osx
# https://github.com/Nuand/bladeRF/wiki/Getting-Started%3A-Linux#building-bladerf-libraries-and-tools-from-source
git clone https://github.com/Nuand/bladeRF.git
cd ~/bladeRF/host/libraries/libbladeRF_bindings/python
sudo python3 setup.py install
cd ~/
# -------- --------

# -------- add GPIO Control --------
# https://ubuntu.com/tutorials/gpio-on-raspberry-pi#3-basic-gpio-example
sudo apt install python3-lgpio -y

# -------- get drivers for waveshare HAT--------
# ---- General tutorial ---- https://www.waveshare.com/wiki/SIM8200EA-M2_5G_HAT
# ---- 5G HAT setup ---- https://www.waveshare.com/wiki/SIM820X_RNDIS_Dial-Up
cd ~/
wget -P ~/ https://www.waveshare.com/w/upload/1/1e/SIM820X_RNDIS.zip
sudo apt-get install python3-pip -y
sudo pip3 install pyserial -y
sudo apt-get install unzip -y
unzip  SIM820X_RNDIS.zip
sudo chmod 777 SIM820X_RNDIS.py
sudo python3 SIM820X_RNDIS.py
# -------- --------


# -------- minicom: used for connection with bladerf
# net-tools: give access to ifconfig
# speedtest-cli: network speed tool --------
sudo apt-get install minicom net-tools speedtest-cli -y
# -------- --------

# -------- tools for web app --------
pip install Flask
pip install flask-wtf
pip install tcp-latency
pip install pydrive
# -------- --------

# -------- setup website autorun --------

cd ~/5G-IoT-Gateway/
chmod +x run.sh
crontab -l | { cat; echo "@reboot ./5G-IoT-Gateway/run.sh"; } | crontab -

# --------------------





sudo apt update

sudo reboot now

