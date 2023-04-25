
if [ "$1" = "Waveshare" ] || [ "$1" = "Sixfab" ]; then
   echo "Configuring HAT for $1"
else
   echo "Invalid HAT manufacturer"
   exit 1
fi

if [ "$2" = "xa4" ] || [ "$2" = "xa9" ]; then
   echo "Configuring bladeRF for $2"
else
   echo "Invalid bladeRF configuration"
   exit 1
fi

# -------- install vncserver --------
#https://www.youtube.com/watch?v=3K1hUwxxYek
cd ~/
sudo apt update
sudo apt install lightdm -y
sudo apt install x11vnc -y
sudo cp 5G-IoT-Gateway/utils/x11vnc.service /lib/systemd/system/

systemctl daemon-reload
systemctl enable x11vnc.service
systemctl start x11vnc.service
systemctl status x11vnc.service
# -------- --------


sudo apt update && sudo apt upgrade -y

sudo apt install ssh -y

# -------- install bladerf images--------
sudo add-apt-repository -y ppa:nuandllc/bladerf
sudo apt update

mkdir ~/blade

sudo wget -P ~/blade/ https://www.nuand.com/fx3/bladeRF_fw_latest.img

if [ "$2" = "xa4" ]; then
   sudo wget -P ~/blade/ https://www.nuand.com/fpga/hostedxA4-latest.rbf
elif [ "$2" = "xa9" ]; then
   sudo wget -P ~/blade/ https://www.nuand.com/fpga/hostedxA9-latest.rbf
fi

# -------- --------

# -------- install GNU-radio and dependencies --------
sudo apt install -y libusb-1.0-0-dev libusb-1.0-0 git cmake g++ \
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
sudo apt install -y bladerf libbladerf-dev bladerf-firmware-fx3 -y
if [ "$2" = "xa4" ]; then
   sudo apt install bladerf-fpga-hostedxa4 -y 
elif [ "$2" = "xa9" ]; then
   sudo apt install bladerf-fpga-hostedxa9 -y 
fi
  
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

sudo apt update
# -------- --------


# -------- install bladeRF python bindings--------
# install bladeRF python module from 
# https://github.com/Nuand/bladeRF/tree/master/host#linux-and-osx
# https://github.com/Nuand/bladeRF/wiki/Getting-Started%3A-Linux#building-bladerf-libraries-and-tools-from-source
cd ~/
git clone https://github.com/Nuand/bladeRF.git
#cd bladeRF
#mkdir host/build
#cd host/build
#cmake ../
#make -j4
#sudo make install && sudo ldconfig
cd ~/bladeRF/host/libraries/libbladeRF_bindings/python
sudo python3 setup.py install
cd ~/
# -------- --------

# -------- add GPIO Control --------
# https://ubuntu.com/tutorials/gpio-on-raspberry-pi#3-basic-gpio-example
sudo apt install python3-lgpio -y

if [ "$1" = "Waveshare" ]; then
   cp ~/5G-IoT-Gateway/utils/StartNetwork_Waveshare.py ~/StartNewtork.py
elif [ "$2" = "Sixfab" ]; then
   cp ~/5G-IoT-Gateway/utils/StartNetwork_Waveshare.py ~/StartNewtork.py
fi


# -------- minicom: used for connection with bladerf
# net-tools: give access to ifconfig
# speedtest-cli: network speed tool --------
sudo apt install minicom net-tools speedtest-cli -y
# -------- --------

# -------- tools for web app --------
sudo apt install python3-pip -y
pip install Flask
pip install flask-wtf
pip install pandas
pip install tcp-latency
pip install pydrive
# -------- --------

# -------- install measure_power module--------
cd ~/5G-IoT-Gateway/measure_power/
pip install .
# -------- --------

# -------- setup website autorun --------
mkdir ~/.config/autostart
cp ~/5G-IoT-Gateway/utils/Webserver.desktop ~/.config/autostart/
chmod +x ~/.config/autostart/Webserver.desktop
# -------- --------


sudo apt update

sudo reboot now

