#!/bin/bash

# 检查是否有 --noconfirm 参数
for arg in "$@"
do
    if [ "$arg" == "--noconfirm" ]; then
        noconfirm=true
    fi
done

install_wget() {
    if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install wget -y
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S wget --noconfirm
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install wget -y
    elif [ -f /etc/centos-release ]; then
        sudo yum install wget -y
    else
        echo "Unsupported distribution. Please install wget manually."
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to install wget. Please install it manually and run the script again."
        exit 1
    fi
}

download_realesrgan() {
    if [ "$noconfirm" == true ]; then
        choice=0 # 自动选择GitHub源
    else
        while true; do
            echo "Select the download source for Real-ESRGAN (Default: GitHub):"
            echo "0. GitHub"
            echo "1. jsDelivr CDN"
            read -p "Enter your choice (0 or 1). Press Enter for default [0]: " choice
            
            # 如果用户没有输入，使用默认GitHub源
            if [ -z "$choice" ]; then
                choice=0
            fi

            if [[ "$choice" == "0" || "$choice" == "1" ]]; then
                break
            else
                echo "Invalid choice. Please try again."
            fi
        done
    fi

    case "$choice" in
        0) url="https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan/releases/download/v0.2.0/realesrgan-ncnn-vulkan-v0.2.0-ubuntu.zip";;
        1) url="https://cdn.jsdelivr.net/gh/xinntao/Real-ESRGAN-ncnn-vulkan@v0.2.0/realesrgan-ncnn-vulkan-v0.2.0-ubuntu.zip";;
    esac

    wget $url || { echo "Failed to download Real-ESRGAN. Exiting."; exit 1; }
}

# 检查是否安装了 wget
if ! command -v wget > /dev/null; then
    echo "wget not found. Installing wget..."
    install_wget
fi

download_realesrgan

unzip realesrgan-ncnn-vulkan-v0.2.0-ubuntu.zip || { echo "Failed to unzip Real-ESRGAN. Exiting."; exit 1; }
sudo mv ./realesrgan-ncnn-vulkan-v0.2.0-ubuntu/realesrgan-ncnn-vulkan /usr/bin/realesrgan-ncnn-vulkan

rm -r ./realesrgan-ncnn-vulkan-v0.2.0-ubuntu
rm ./realesrgan-ncnn-vulkan-v0.2.0-ubuntu.zip
echo "Finished"
