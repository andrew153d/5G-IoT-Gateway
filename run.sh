branch="main"
# Change directory to the local repository
cd ~/5G-IoT-Gateway
# Check if the local branch is behind the remote branch
git fetch origin $branch
if [ $(git rev-parse HEAD) != $(git rev-parse origin/$branch) ]; then
    echo "Software out of date, "git pull" to update"
else
    echo "Software up to date"
fi

if [ "$1" = "--noModem" ]; then
    echo "Starting without Modem"
else
    echo "Searching for 5G modem"
    until lsusb | grep -q "Qualcomm"; do echo -n "." && sleep 1; done;
    echo "."
    echo "Found 5G Modem Over USB"

    echo "searching for ttyUSB2"
    until ls /dev |grep -q "ttyUSB2"; do echo -n "." && sleep 1; done;
    echo "."
    echo "Found ttyUSB2"

    sudo python3 ~/StartNetwork.py

    echo "Connnecting to Mobile Network"
    sleep 25
    until ifconfig usb0 | grep -q "inet "; do echo -n "." && sleep 1; done
    echo "."
    echo "Connected to Mobile Network"
fi

echo "waiting for DNS"
until ping -c 2 google.com | grep -q "bytes"; do echo -n "." && sleep 1; done;
echo "."
echo "Found DNS"

sudo nmcli d wifi hotspot ifname wlan0 ssid Gateway password password




echo "The website can be accessed by one of these ip addresses at :5000"
ifconfig | grep "inet "

cd ~/5G-IoT-Gateway/website/
python3 website.py



