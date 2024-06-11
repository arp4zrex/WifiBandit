
# WifiBandit

WiFiBandit is a script designed for penetration testing on WiFi networks to assess their security and detect potential vulnerabilities. The script provides an interactive interface for configuring the network card, selecting the attack mode, and executing the corresponding attacks.

# Usage

Clone this repository to your local machine:
git clone https://github.com/arp4zrex/WifiBandit.git
cd wifibandit
chmod +x wifibandit.sh
./wifibandit.sh

# Requirements

aircrack-ng: Utility for wireless security auditing.
macchanger: Tool for changing the MAC address of a network interface.
hostapd: Software for creating a Wi-Fi access point.
iwconfig: Utility for configuring parameters of a wireless network interface.
tcpdump: Network packet capture and analysis tool.
xterm: Terminal emulator to display terminal windows.
hashcat: Password recovery tool.
hcxdumptool: Tool for capturing PMKID from Wi-Fi networks.
rockyou.txt: is a widely-used password dictionary containing millions of common passwords for brute force attacks

# Types of Attacks

# Handshake
This attack mode is used to capture the authentication handshake between a client device and a Wi-Fi access point. Once the handshake is captured, brute force attacks can be performed to decrypt the network password.
This attack involves capturing authentication packets between a client device and an access point. Once the handshake is captured, a password dictionary can be used to try to decrypt the network password.
The script uses tools like airodump-ng to scan available WiFi networks and capture the authentication handshake.
Once the handshake is captured, the aircrack-ng tool can be used along with a password dictionary to attempt to decrypt the network password.
The time required to capture a handshake can vary depending on network activity and the number of connected devices.

# PKMID
The PKMID attack is a clientless attack that exploits a vulnerability in the WPA/WPA2 authentication standard to capture PMKID hashes. These hashes can then be used in a brute force attack to obtain the network password.
In this attack, the necessary PMKID hashes are captured to perform a brute force attack against the network password. This attack can be carried out without any clients associated with the network, making it especially stealthy.
This attack exploits a vulnerability in the authentication protocol of WPA/WPA2 WiFi networks.
The script uses the hcxdumptool to capture the PMKID, which is a hash derived from the network password and the MAC address of the access point.
Once the PMKID is captured, tools like hashcat can be used along with a password dictionary to attempt to decrypt the password.
