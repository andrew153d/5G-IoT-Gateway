 echo "Searching for 5G modem"
until lsusb | grep -q "Qualcomm"; do echo -n "." && sleep 1; done;
echo "\nFound 5G Modem Over USB"

echo "searching for ttyUSB2"
until ls /dev |grep -q "ttyUSB2"; do echo -n "." && sleep 1; done;
echo "\nFound ttyUSB2"

read -p "Press enter when the green light is blinking"

sudo python3 ~/SIM820X_RNDIS.py



echo "Connnecting to Mobile Network"
sleep 25
until ifconfig usb0 | grep -q "inet "; do echo -n "." && sleep 1; done
echo "\nConnected to Mobile Network"


sudo nmcli d wifi hotspot ifname wlan0 ssid Gateway password password

echo "The website can be accessed by connecting to the hotspot and going to the following address"

cd ~/5G-IoT-Gateway/website/
python3 website.py



