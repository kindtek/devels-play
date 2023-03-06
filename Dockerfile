# to build, for exemple, run: 
# `username=mine groupname=ours docker run -d -i`
FROM ubuntu:latest AS devp_skinny
ARG username=${username:-gabriel}
ARG groupname=${groupname:-arcans}

# # set glob exp pattern matching default
# RUN echo "shopt -s histappend" >> /etc/profile

# set up basic utils
RUN apt-get update -yq && \
    apt-get upgrade -y && \
    # install github, build-essentials, libssl, etc
    apt-get install -y git gh build-essential libssl-dev ca-certificates wget curl gnupg lsb-release python3 python3-pip vim

# # set up group/user 
# RUN addgroup --system --gid 1001 ${groupname} && \
#     adduser --system --home /home/${username} --shell /bin/bash --uid 1001 --gid 1001 --disabled-password ${username}  
# set up groups
RUN addgroup --gid 111 ${groupname} && \
    addgroup --gid 888 archans && \
    addgroup --gid 666 devels

RUN adduser --home /home/${username} --shell /bin/bash --uid 1011 --disabled-password ${username}

# make default user 
RUN echo "[user]\ndefault=${username}" >> /etc/wsl.conf

# custom user setup
USER ${username}
# install cdir on nonroot user - an absolute lifesaver for speedy nav in an interactive cli (cannot be root for install)
RUN pip3 install cdir --user && \
    echo "alias cdir='source cdir.sh'\nalias grep='grep --color=auto'\nalias powershell=pwsh\ndevw=devels-workshop\ndevp=devels-playground\nkindtek=~/repos/kindtek" >> ~/.bashrc

# finish cdir setup, add repos directory, copy custom user setup to skel
RUN export PATH=~/.local/bin:~/repos/kindtek/devels-workshop/scripts:$PATH

# switch back to root to setup
USER root

# add devel and host users using custom user setup
RUN adduser --system --home /home/host --shell /bin/bash --uid 888 --disabled-password host
RUN adduser --system --home /home/devel --shell /bin/bash --uid 666 --disabled-password devel

# enable regexp matching
# RUN shopt -s extglob && \
RUN cp -r ./home/${username}/.local/bin /usr/local && \
    cp -r /home/${username}/. /etc/skel/ && \
    cp -rp /etc/skel/. /home/devel/

# add username only to sudo
RUN usermod -aG archans host && usermod -aG archans ${username} 
RUN usermod -aG devels devel && usermod -aG devels ${username} 
RUN usermod -aG sudo ${username}

# RUN sed -e 's;^# \(%sudo.*NOPASSWD.*\);\1;g' -i /etc/sudoers
# RUN chown -R ${username}:archans /home/host
RUN chown -R host:archans /home/host
RUN chown -R devel:devels /home/devel


# need to use sudo from now on
RUN apt-get -y install sudo && \
    # add devel and ${username} to sudo group
    sudo adduser ${username} sudo 
    # uncomment to add sudo priveleges for host and devel
    # && \
    # sudo adduser devel sudo && \
    # sudo adduser host sudo

# ensure no password and sudo runs as root
RUN passwd -d ${username} && passwd -d devel && passwd -d root && passwd -l root
RUN passwd -d ${username} && passwd -d host && passwd -d root && passwd -l root

# mount w drive - set up drive w in windows using https://allthings.how/how-to-partition-a-hard-drive-on-windows-11/
# RUN sudo mkdir /mnt/w && sudo mount -t drvfs w: /mnt/w


# set up /devel folder as symbolic link to /home/devel for cloning repository(ies)
RUN ln -s /home/devel /hel && chown -R devel:devels /hel
RUN touch /hel/lo.hiworld



USER ${username}

FROM devp_skinny AS devp_git

WORKDIR /hel
USER devel

# add safe directories
RUN git config --global --add safe.directory /home/devel
RUN git config --global --add safe.directory /hel

RUN git clone https://github.com/kindtek/devels-playground
RUN cd devels-playground && git submodule update --force --recursive --init --remote
USER ${username}

# brave browser/gui/media support
FROM devp_git as devp_phat
# make man available
# RUN yes | unminimize
# for powershell install - https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3
## Download the Microsoft repository GPG keys
USER ${username}
RUN sudo wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

## Register the Microsoft repository GPG keys
RUN sudo dpkg -i packages-microsoft-prod.deb
RUN sudo rm packages-microsoft-prod.deb
RUN sudo apt-get update -yq && \
    sudo apt-get install -y gedit powershell

FROM devp_phat as devp_phatt
# for brave install - https://linuxhint.com/install-brave-browser-ubuntu22-04/
RUN sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main"| sudo tee /etc/apt/sources.list.d/brave-browser-release.list


RUN sudo apt-get update -yq && \
    sudo apt-get install -y brave-browser gimp nautilus vlc x11-apps apt-transport-https software-properties-common 
USER ${username}

# for docker in docker
FROM devp_phatt as devp_phatter
USER root
# for docker install - https://docs.docker.com/engine/install/ubuntu/
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# DOCKER
RUN apt-get update && apt-get install -y docker-compose-plugin docker-ce docker-ce-cli containerd.io 
USER ${username}
RUN echo "export DOCKER_HOST=tcp://localhost:2375" >> ~/.bashrc && . ~/.bashrc

# for heavy gui and cuda
FROM devp_phatter as devp_phattest
# GNOME
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install gnome-session gdm3

FROM devp_phattest as devp_phatso
# CUDA
RUN sudo apt-get -y install nvidia-cuda-toolkit
USER ${username}

# VSCODE
# RUN apt-get -y install apt-transport-https wget -y
# RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -
# RUN add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/vscode stable main"
# RUN apt-get -y install code
# RUN apt-get -y update

# username=dev08 groupname=wheel docker compose -f docker-compose.ubuntu.yaml build
