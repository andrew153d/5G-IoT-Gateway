
if [ "$1" = "--noModem" ]; then
    cp ~/5G-IoT-Gateway/utils/StartNetwork_Waveshare.py ~/StartNewtork.py
else
    echo "Searching for 5G modem"
    until lsusb | grep -q "Qualcomm"; do echo -n "." && sleep 1; done;
    echo "."
    echo "Found 5G Modem Over USB"

    echo "searching for ttyUSB2"
    until ls /dev |grep -q "ttyUSB2"; do echo -n "." && sleep 1; done;
    echo "."
    echo "Found ttyUSB2"

    read -p "Press enter when the green light is blinking"

    sudo python3 ~/StartNetwork.py

    echo "Connnecting to Mobile Network"
    sleep 25
    until ifconfig usb0 | grep -q "inet "; do echo -n "." && sleep 1; done
    echo "."
    echo "Connected to Mobile Network"
fi

sudo nmcli d wifi hotspot ifname wlan0 ssid Gateway password password

echo "The website can be accessed by one of these ip addresses at :5000"
ifconfig | grep "inet "

cd ~/5G-IoT-Gateway/website/
python3 website.py



