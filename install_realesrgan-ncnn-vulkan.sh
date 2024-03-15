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
        choice=0 # 使用 --noconfirm 参数时，默认选择GitHub源
    else
        echo "Select the download source for Real-ESRGAN (Default: GitHub):"
        echo "0. GitHub"
        echo "1. mirror.ghproxy.com"
        read -p "Enter your choice (0 or 1). Press Enter for default [0]: " choice
        
        # 如果用户没有输入，使用默认GitHub源
        if [ -z "$choice" ]; then
            choice=0
        fi
    fi

    case "$choice" in
        0) url="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip";;
        1) url="https://mirror.ghproxy.com/https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip";;
        *) echo "Invalid choice. Defaulting to GitHub source."
           url="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip";;
    esac

    wget $url || { echo "Failed to download Real-ESRGAN. Exiting."; exit 1; }
}

# 检查是否安装了 wget
if ! command -v wget > /dev/null; then
    echo "wget not found. Installing wget..."
    install_wget
fi

download_realesrgan

# 使用 unzip 的 -x 选项排除不需要的文件，并保留目录结构解压到指定位置
unzip realesrgan-ncnn-vulkan-20220424-ubuntu.zip -x README_ubuntu.md onepiece_demo.mp4 input2.jpg input.jpg -d /tmp/realesrgan-ncnn-vulkan

# 将解压的文件移动到 /usr/bin，保留目录结构，并覆盖任何现有文件
sudo cp -r /tmp/realesrgan-ncnn-vulkan/* /usr/bin/
sudo rm -rf /tmp/realesrgan-ncnn-vulkan

rm realesrgan-ncnn-vulkan-20220424-ubuntu.zip
echo "Finished"
