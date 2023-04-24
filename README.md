# 5G IoT Gateway with RF Measurement Capability
A measurement platform to test 5G networks

## Demo Video
I'm no youtuber but here is a video of the current state of the device as of March 2023
[![5G Demo](media/screenshot_youtube.png)](https://youtu.be/Gw4qhBvPAFY)

## Directions
1. Use RPI Imager and install Ubuntu Desktop 22.04.1 LTS (64-Bit) to SD Card
2. Install SD card, plug in, and follow prompts to start up the Pi
3. Open the command line and enter the following
4. sudo apt install git -y
5. git clone https://github.com/andrew153d/5G-IoT-Gateway.git
6. cd 5G-IoT-Gateway
7. nano install.sh
8. Change the 5GModem variable to your modem
9. Change bladeRF installs for xa4 or xa9 versions
10. chmod +x install.sh
11.  ./setup.sh
12. A purple box will come up, select lightdm and hit enter
13. The first item to install is vnc, you will need to type your pasword a few times here
14. After vnc installs, it will take ~30 minutes
15. Go to 9 dots on bottom left > settings
16. Power > Screen Blank > Never
17. Users > Unlock > Enter Password > Automatic Login > Turn that on


## Issues
* Currently bladeRF-cli does not work
  * Installing bladerf from source overwrites bladerf-cli with an incompatible version

* Ubuntu ppa bladerf_lib.h is out of date not including bladerf_feature keeping gr-bladerf from compilng
  * Need to install correct version while also installing python module
