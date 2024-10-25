#!/bin/bash

BLACK='\033[30m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
DARKGRAY='\033[1;90m'
BGDARKGRAY='\033[100m'
BGBLACK='\033[1;40m'
BGCYAN='\033[46m'
BGWHITE='\033[47m'
RESET='\033[0m'

stty erase "^H"

if [ $(id -u) -ne 0 ]; then
    echo -e "${RED}${BGWHITE}hey! ${RESET}you need root permissions to run ${BGWHITE}${BLACK}crosboot${RESET}. please run this script as root or with sudo. you can do so by using 'sudo su'.${RESET}"
    exit
fi

my_files_dir="/home/chronos/user/MyFiles"
crosboot_dir="/usr/share/chromeos-assets/images_100_percent"
crosboot_temp="$crosboot_dir/crosboot_temp"
settings_file="$crosboot_temp/crosboot_settings.conf"

initialize_crosboot() {
    if [ ! -d "$crosboot_temp/default" ]; then
        sudo mkdir -p "$crosboot_temp/default"
        sudo cp "$crosboot_dir"/boot_splash* "$crosboot_temp/default/"
        echo -e "${GREEN}Default images loaded.${RESET}"
    fi
    if [ ! -f "$settings_file" ]; then
        echo "fps=25" | sudo tee "$settings_file" > /dev/null
        echo "current_set=" | sudo tee -a "$settings_file" > /dev/null
    fi
}

initialize_crosboot


echo "┌────────────────────────────────────────────────┐"
echo "│ Welcome to crosboot! Please, select an option. │"
echo "├────────────────────────────────────────────────┤"
echo "│ 1) Change chromeos boot screen                 │"
echo "│ 2) Reset to default boot screen                │"
echo "├────────────────────────────────────────────────┤"
echo "│ made by alex badi, v1.0                        │"
echo "└────────────────────────────────────────────────┘"

current_set=$(grep "current_set=" "$settings_file" | cut -d'=' -f2)

if [ -n "$current_set" ]; then
    echo -e "${YELLOW}you're using the boot set: ${GREEN}$current_set${RESET}"
else
    echo -e "${YELLOW}no boot set currently selected.${RESET}"
fi

echo " "

sleep 1
read -p "$(echo -e ${YELLOW}select an option: ${RESET})" choice

case "$choice" in
    1)
        fps_prompt="${YELLOW}enter FPS for the boot animation: ${RESET}"
        read -p "$(echo -e $fps_prompt)" fps
        if ! [[ "$fps" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}${BGWHITE}invalid FPS!${RESET}"
            exit 1
        fi
        
        frame_interval=$((1000 / fps))
        sudo sed -i "s/--frame-interval [0-9]*/--frame-interval $frame_interval/g" /etc/init/boot-splash.conf
        echo "fps=$fps" | sudo tee "$settings_file" > /dev/null

        directories=($(find "$my_files_dir" -mindepth 1 -maxdepth 1 -type d))
        if [ ${#directories[@]} -eq 0 ]; then
            exit 1
        fi

        echo -e "${YELLOW}select a directory containing the new boot files:${RESET}"
        for i in "${!directories[@]}"; do
            if (( i % 2 == 0 )); then
                echo -e "${BGWHITE}${BLACK}$((i+1))) ${directories[$i]}${RESET}"
            else
                echo -e "$((i+1))) ${directories[$i]}${RESET}"
            fi
        done

        read -p "$(echo -e ${YELLOW}enter your choice: ${RESET})" dir_choice

        if [[ "$dir_choice" -ge 1 && "$dir_choice" -le ${#directories[@]} ]]; then
            directory_selected="${directories[$((dir_choice-1))]}"
            subdirectories=($(find "$directory_selected" -mindepth 1 -maxdepth 1 -type d))
            boot_splash_files=($(find "$directory_selected" -type f -name "boot_splash*.png"))

            if [[ ${#subdirectories[@]} -gt 0 || ${#boot_splash_files[@]} -gt 0 ]]; then
                echo -e "${YELLOW}the directory has additional options. choose one:${RESET}"

                for i in "${!subdirectories[@]}"; do
                    echo -e "$((i+1))) ${subdirectories[$i]}${RESET}"
                done

                if [[ ${#boot_splash_files[@]} -gt 0 ]]; then
                    echo -e "${BGWHITE}${BLACK}$(( ${#subdirectories[@]}+1 ))) use files in the current directory${RESET}"
                fi

                read -p "$(echo -e ${YELLOW}enter your selection: ${RESET})" sub_choice
                
                if [[ "$sub_choice" -ge 1 && "$sub_choice" -le ${#subdirectories[@]} ]]; then
                    directory_selected="${subdirectories[$((sub_choice-1))]}"
                elif [[ "$sub_choice" -eq $(( ${#subdirectories[@]}+1 )) ]]; then
                    sudo cp "$directory_selected"/boot_splash*.png "$crosboot_dir/"
                    echo -e "${YELLOW}applying boot screen from selected directory.${RESET}"
                else
                    echo -e "${RED}invalid selection. exiting.${RESET}"
                    exit 1
                fi
            fi
            
            backup_dir="$crosboot_temp/$(basename "$directory_selected")"
            sudo mkdir -p "$backup_dir"
            sudo cp "$crosboot_dir"/boot_splash* "$backup_dir/"
            echo -e "${YELLOW}applying new boot images...${RESET}"
            
            if sudo cp "$directory_selected"/boot_splash* "$crosboot_dir/"; then
                echo -e "${GREEN}crosboot applied successfully! :)${RESET}"
                
                echo "current_set=$(basename "$directory_selected")" | sudo tee -a "$settings_file" > /dev/null
            else
                echo -e "${RED}failed to apply crosboot.${RESET}"
            fi
        else
            echo -e "${RED}invalid selection. Exiting.${RESET}"
            exit 1
        fi
        ;;
    
    2)
        echo -e "${YELLOW}resetting to default boot screen...${RESET}"
        if [ -d "$crosboot_temp/default" ]; then
            sudo cp "$crosboot_temp/default"/boot_splash* "$crosboot_dir/"
            echo -e "${GREEN}default boot screen restored!${RESET}"
            echo "current_set=" | sudo tee -a "$settings_file" > /dev/null
        else
            echo -e "${RED}no default backup found.${RESET}"
        fi
        ;;
    
    *)
        echo -e "${RED}invalid option. please try again.${RESET}"
        ;;
esac
