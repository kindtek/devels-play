# to build, for exemple, run: 
# `username=mine groupname=ours docker run -d -i`
FROM ubuntu:latest AS d2w_skinny
ARG username=${username:-dev0}
ARG groupname=${groupname:-dev}

# set up basic utils
RUN apt-get update -yq && \
    apt-get upgrade -y && \
    # install github, build-essentials, libssl, etc
    apt-get install -y git gh build-essential libssl-dev ca-certificates wget curl gnupg lsb-release python3 python3-pip vim

# # set up group/user 
# RUN addgroup --system --gid 1000 ${groupname} && \
#     adduser --system --home /home/${username} --shell /bin/bash --uid 1000 --gid 1000 --disabled-password ${username}  
# set up groups
RUN addgroup --gid 1001 ${groupname} && \
    addgroup --gid 1008 devbp

RUN adduser --home /home/${username} --shell /bin/bash --uid 1000 --disabled-password ${username}

# make default user 
RUN echo "[user]\ndefault=${username}" >> /etc/wsl.conf
RUN mkdir -p repos/kindtek
RUN chown -R ${username} repos
# custom user setup
USER ${username}
# install cdir on nonroot user - an absolute lifesaver for speedy nav in an interactive cli (cannot be root for install)
RUN pip3 install cdir --user && \
    echo "alias cdir='source cdir.sh'\nalias grep='grep --color=auto'\nalias powershell=pwsh\ndevw=devels-workshop\ndevp=devels-playground\nkindtek=~/repos/kindtek" >> ~/.bashrc

# finish cdir setup, add repos directory, copy custom user setup to skel
# update all the paths (with etc/skel)
RUN export PATH=~/.local/bin:~/repos/kindtek/devels-workshop/scripts:$PATH

USER root
RUN cp -r ./home/${username}/.local/bin /usr/local
RUN cp -r /home/${username}/. /etc/skel/

# add devel user using custom user setup
RUN adduser --system --home /home/devel --shell /bin/bash --disabled-password devel
# RUN sed -e 's;^# \(%sudo.*NOPASSWD.*\);\1;g' -i /etc/sudoers

RUN chown -R ${username} /home/devel
WORKDIR /home/devel/repos/kindtek
RUN git clone https://github.com/kindtek/devels-playground

# add devel and dev to sudo and devbp
RUN usermod -aG sudo devel && usermod -aG sudo ${username} && \
    usermod -aG devbp devel && usermod -aG devbp ${username}

# need to use sudo from now on
RUN apt-get -y install sudo && \
    # add devel and ${username} to sudo group
    sudo adduser ${username} sudo && \
    sudo adduser devel sudo

# ensure no password and sudo runs as root
RUN passwd -d ${username} && passwd -d devel && passwd -d root && passwd -l root

# mount w drive - set up drive w in windows using https://allthings.how/how-to-partition-a-hard-drive-on-windows-11/
# RUN sudo mkdir /mnt/w && sudo mount -t drvfs w: /mnt/w

USER ${username}
WORKDIR /home/${username}

FROM d2w_skinny AS d2w_phat
USER root

RUN yes | unminimize
USER ${username}
WORKDIR /home/${username}



# for powershell install - https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3
## Download the Microsoft repository GPG keys
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

## Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get update -yq && \
    apt-get install -y gedit powershell
USER ${username}
WORKDIR /home/${username}

# brave browser/gui/media support
FROM d2w_phat as d2w_phatt
# for brave install - https://linuxhint.com/install-brave-browser-ubuntu22-04/
RUN sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main"| sudo tee /etc/apt/sources.list.d/brave-browser-release.list

RUN sudo apt-get update -yq && \
    sudo apt-get install -y gimp nautilus vlc x11-apps apt-transport-https software-properties-common brave-browser
USER ${username}

# for docker in docker
FROM d2w_phatt as d2w_phatter
USER root

# for docker install - https://docs.docker.com/engine/install/ubuntu/
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# DOCKER
RUN apt-get update && apt-get install -y docker-compose-plugin docker-ce docker-ce-cli containerd.io 
USER ${username}
WORKDIR /home


# for heavy gui and cuda
FROM d2w_phatter as d2w_phattest
# GNOME
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install gnome-session gdm3
# CUDA
RUN sudo apt-get -y install nvidia-cuda-toolkit
USER ${username}
WORKDIR /home

# VSCODE
# RUN apt-get -y install apt-transport-https wget -y
# RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
# RUN add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main"
# RUN apt-get -y install code
# RUN apt-get -y update

# username=dev08 groupname=wheel docker compose -f docker-compose.ubuntu.yaml build
