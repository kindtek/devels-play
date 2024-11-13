#syntax=docker/dockerfile:experimental
# to build and run an individual service with args (ie git):
## `docker compose build git --build-arg REFRESH_REPO=true && docker compose up git`
# to build everything:
## `docker compose build && docker compose up`
# to remove all volumes:
## docker compose down && docker volume rm $(docker volume ls -q)

ARG BUILD_TARGET=${INTERNAL_BUILD:+INTERNAL}
ARG BUILD_TARGET=${BUILD_TARGET:-EXTERNAL}
ARG INTERNAL_BUILD
ARG DOCKER_BUILDKIT=1
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
ARG _CPU_ARCH
ARG _CPU_VENDOR
ARG WINDOWS
ARG LINUX
ARG KERNEL_TYPE=${KERNEL_TYPE}
ARG KERNEL_PACKAGE_NAME=${KERNEL_PACKAGE_NAME}
ARG INSTALL_KERNEL="dont_install_kernel"
ARG install=INSTALL
ARG installkernel=${install}_KERNEL
# $ echo ${installkernel}
# dont_install_kernel
# $ echo ${!installkernel}
# INSTALL_KERNEL
ARG CONFIG_FILE
ARG DOCKER_TIMESTAMP
ARG KERNEL_PACKAGE_NAME

################
# kali_testing #
################
FROM kindtek/devels-playground:kali-skel AS dvlp_testing
WORKDIR /
RUN touch testing

################################### GITHUB REPO #####################################
########################
# dvlp_repo-builder #
########################
FROM kalilinux/kali-rolling:latest AS dvlp_repo-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG DOCKER_TIMESTAMP
ARG KERNEL_PACKAGE_NAME
ENV KERNEL_TYPE=${KERNEL_TYPE}
ENV KERNEL_FEATURE=${KERNEL_FEATURE}
ENV CONFIG_FILE=${CONFIG_FILE}
ENV DOCKER_TIMESTAMP=${DOCKER_TIMESTAMP}
ENV KERNEL_PACKAGE_NAME=${KERNEL_PACKAGE_NAME}

# USER ${_R00T}
WORKDIR /
# add git cache directory
# RUN mkdir -pv /var/cache/dvlp/archives && \
# chown -R ${_R00T}:${_R00T_GRP} /var/cache/dvlp/archives && \
#     mkdir -pv /dvlw && \
#     chown -R ${_R00T}:${_R00T_GRP} /repos/dvlw
RUN \
    # clear docker-clean to flag for apt-get clean
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    # cache packages in docker builds as long as using apt-get
    echo 'Binary::apt-get::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    # no suggests or recommends for apt-get
    # suggests and recommends for apt
    echo "\
    Acquire::Retries '3';\
    Acquire::https::Timeout '240';\
    Acquire::http::Timeout '240';\
    Acquire::BrokenProxy='true';\
    Acquire::http::No-Cache='true'; \ 
    Acquire::http::Pipeline-Depth='0';\
    Debug::Acquire::https 'true';\
    Binary::apt-get::APT::Get::Assume-Yes 'true';\
    Binary::apt-get::APT::Install-Recommends 'false';\
    Binary::apt-get::APT::Install-Suggests 'false'; \
    Binary::apt::APT::Install-Recommends 'true'; \
    Binary::apt::APT::Install-Suggests 'true';\
    Binary::apt-get::APT::Keep-Downloaded-Packages 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm 
# use apt loading bar for apt-get by default
# RUN echo 'Binary::apt-get::DPkg::Progress-Fancy "1"' | tee /etc/apt/apt.conf.d/99fancybar.conf
# import/install basic utils from layer cache if possible and delete .deb archives from container when finished
RUN \
    --mount=type=cache,target=/var/cache/dvlp/build-repo-git,sharing=locked \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y git && \
    apt-get --reinstall -y install ca-certificates && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt && \
    # add safe directories
    # RUN \
    # --mount=type=cache,target=/var/cache/dvlp/build-repo-git,sharing=locked  \
    # if [ "$fresh_repo" != no ]; then rm -rf /var/cache/dvlp/archives/dvlw; fi && \
    # git config --global --add safe.directory /home/${_DVL} && \
    # git config --global --add safe.directory /home/${_AGL} && \
    git config --global --add safe.directory ${_AGL_HOME} && \
    git config --global --add safe.directory ${_AGL_HOME}/dvlw && \
    git config --global --add safe.directory ${_DVL_HOME} && \
    git config --global --add safe.directory ${_DVL_HOME}/dvlw && \
    git config --global --add safe.directory / && \
    git config --global --add safe.directory /root && \
    git config --global --add safe.directory /${_R00T} && \
    git config --global --add safe.directory /repos/dvlw && \
    git config --global --add safe.directory /var/cache/dvlp/build-repo-git && \
    git config --global core.autocrlf input && \
    git config --global user.name 'Snail Mail' && \
    git config --global user.email '<>' 
########################
# dvlp_build-repo #
#######################
FROM kindtek/devels-playground:repo-builder AS dvlp_build-repo
WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/build-repo,sharing=locked  \
    repo_owner=kindtek && \
    repo_name=devels-workshop && \
    repo_url=https://github.com/${repo_owner}/${repo_name} && \
    repo_path=dvlw && \
    repo_branch=main && \
    echo repo_owner: $repo_owner && \
    echo repo_name: $repo_name && \
    echo repo_url: $repo_url && \
    echo repo_path: $repo_path && \
    echo repo_branch: $repo_branch && \
    mkdir -pv /repos/dvlw && \
    chmod -R 770 /repos && \
    cd repos || exit 1 && \
    # echo "git clone $repo_url --single-branch --branch $repo_branch --filter=blob:limit=13k --progress -- $repo_path 2>/dev/null" && \
    git clone "$repo_url" --single-branch --branch $repo_branch --filter=blob:limit=13k --progress -- $repo_path  && \
    cd dvlw || exit 1 && \
    # echo  "git submodule update --init --remote --filter=blob:limit=13k --progress -- dvlp dvl-adv powerhell 2>/dev/null" && \
    git submodule update --init --remote --filter=blob:limit=13k --progress -- dvlp dvl-adv powerhell && \
    cd dvlp || exit 1 && \
    # echo "git submodule update --init --progress -- mnt" && \
    git submodule update --init --progress -- mnt

###################
# dvlp_build-repo-kernel #
###################
FROM dvlp_build-repo AS dvlp_build-repo-kernel
RUN \
    # --mount=type=cache,target=/var/cache/dvlp/build-repo-kernel,sharing=locked \
    # allow download of larger files (kernels)
    cd /repos/dvlw/dvlp || exit 1 && \
    git submodule update --init --progress --filter=blob:limit=20m -- kernels 

FROM dvlp_build-repo${KERNEL_TYPE:+-kernel} AS dvlp_built-repo

#############
# dvlp_repo #
#############
FROM scratch AS dvlp_repo
COPY --from=dvlp_build-repo --chmod=770 ./repos/dvlw/ ./repos/dvlw/

FROM scratch AS dvlp_repo-kernel
COPY --from=dvlp_build-repo-kernel --chmod=770 ./repos/dvlw/ ./repos/dvlw/

####################### BASE volumes AND VOLUME MOUNT POINTS ####################################
# build home directory structure
########################
# dvlp_base-devel-volumes #
########################
FROM kalilinux/kali-rolling:latest AS dvlp_base-devel-volumes-builder
ARG _MNT
ARG _DVL=${_DVL:-'dvl'}
ENV _DVL=${_DVL}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ENV _DVL_HOME=${_DVL_HOME}
ARG KERNEL_TYPE
WORKDIR ${_DVL_HOME}
RUN mkdir -pv dvlw && \
    mkdir -pv dls && \
    mkdir -pv .docker/run && \
    ln -fsv dvlw devels-workshop && \
    ln -fsv dvlw/dvlp dvlp && \
    ln -fsv dvlw/dvlp/docker/kali kdock && \
    ln -fsv dvlw/dvlp/docker docker && \
    ln -fsv ${_DVL_HOME} /home/${_DVL} 
WORKDIR ${_MNT}/data
RUN ln -fsv ${_MNT}/data/bak/${_DVL} bak 
# && \
#     chmod -R 770 ${_MNT}/bak/${_DVL}
# ln -fsv ${_MNT}/data/bak/${_DVL} /home/${_DVL}/bak 
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_DVL_HOME}
ADD ./Dockerfile .${_DVL_HOME}/Dockerfile
ADD ./docker-compose.yaml .${_DVL_HOME}/docker-compose.yaml
ADD .env .${_DVL_HOME}/.env

################################
#  dvlp_base-devel-volumes-builder #
################################
FROM dvlp_base-devel-volumes-builder AS dvlp_base-devel-kernel-volumes-builder
ARG _CPU_ARCH
ARG _CPU_VENDOR
WORKDIR ${_DVL_HOME}
RUN ln -fsv dvlw/dvlp dvlp &&ln -fsv dvlw/dvlp/kernels/linux linux
    # # parse vars from .env
    # _CPU_ARCH=${_CPU_ARCH} && _CPU_VENDOR=${_CPU_VENDOR} && \
    # ln -fsv "dvlw/dvlp/kernels/linux/${_CPU_ARCH}/${_CPU_VENDOR}" && ln -fsv dvlw/dvlp/kernels kernels 
# WORKDIR /home/${_DVL}
# RUN ln -fsv dvlw/dvlp dvlp && \
#     ln -fsv dvlw/dvlp/kernels/linux linux && \
#     ln -fsv "dvlw/dvlp/kernels/linux/${_CPU_ARCH}/${_CPU_VENDOR}" && \
#     ln -fsv dvlw/dvlp/kernels kernels && \
WORKDIR /


###############################
#  dvlp_base-dvl-volumes-built #
###############################
FROM dvlp_base-devel-volumes-builder AS dvlp_base-devel-volumes-built
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/ .${_DVL_HOME}/dvlw/

FROM dvlp_base-devel-kernel-volumes-builder AS dvlp_base-devel-kernel-volumes-built
WORKDIR /
COPY --from=dvlp_repo-kernel ./repos/dvlw/ .${_DVL_HOME}/dvlw/

#########################
#  dvlp_base-angel-volumes-builder #
#########################
FROM kalilinux/kali-rolling:latest AS dvlp_base-angel-volumes-builder
ARG _MNT
ARG _AGL=${_AGL:-'agl'}
ENV _AGL=${_AGL}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ENV _AGL_HOME=${_AGL_HOME}
ARG KERNEL_TYPE
WORKDIR ${_AGL_HOME}
RUN mkdir -pv dvlw && \
    mkdir -pv dls && \
    mkdir -pv .docker/run && \
    ln -fsv dvlw devels-workshop && \
    ln -fsv dvlw/dvlp dvlp && \
    ln -fsv dvlw/dvlp/docker/kali kdock && \
    ln -fsv dvlw/dvlp/docker docker && \
    ln -fsv ${_AGL_HOME} /home/${_AGL} 
WORKDIR ${_MNT}/data
RUN mkdir -pv c && \
    mkdir -pv n && \
    mkdir -pv dls && \
    mkdir -pv bak && \
    mkdir -pv bak/${_AGL} 
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_AGL_HOME}
ADD ./Dockerfile .${_AGL_HOME}/Dockerfile
ADD ./docker-compose.yaml .${_AGL_HOME}/docker-compose.yaml
ADD .env .${_AGL_HOME}/.env

################################
#  dvlp_base-angel-volumes-builder #
################################
FROM dvlp_base-angel-volumes-builder AS dvlp_base-angel-kernel-volumes-builder
ARG _CPU_ARCH
ARG _CPU_VENDOR
WORKDIR ${_AGL_HOME}
# COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/      ./mnt/
RUN ln -fsv dvlw/dvlp dvlp && \
    ln -fsv dvlw/dvlp/kernels/linux linux && \
    # # parse vars from .env
    # _CPU_ARCH=${_CPU_ARCH} && _CPU_VENDOR=${_CPU_VENDOR} && \
    # ln -fsv "dvlw/dvlp/kernels/linux/${_CPU_ARCH}/${_CPU_VENDOR}" ${_CPU_ARCH}${_CPU_VENDOR}" && \
    ln -fsv dvlw/dvlp/kernels kernels  
# WORKDIR /home/${_AGL}
# RUN ln -fsv dvlw/dvlp dvlp && \
#     ln -fsv dvlw/dvlp/kernels/linux linux && \
#     ln -fsv dvlw/dvlp/kernels/linux/x86/amd x64amd && \
#     ln -fsv dvlw/dvlp/kernels kernels
WORKDIR /

###############################
#  dvlp_base-agl-volumes-built #
###############################
FROM dvlp_base-angel-volumes-builder AS dvlp_base-angel-volumes-built
ARG _AGL_HOME
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/ .${_AGL_HOME}/dvlw/

FROM dvlp_base-angel-kernel-volumes-builder AS dvlp_base-angel-kernel-volumes-built
ARG _AGL_HOME
WORKDIR /
COPY --from=dvlp_repo-kernel ./repos/dvlw/ .${_AGL_HOME}/dvlw/


########################
#  dvlp_base-r00t-volumes-builder #
########################
FROM kalilinux/kali-rolling:latest AS dvlp_base-r00t-volumes-builder
ARG _MNT
ARG _R00T=${_R00T:-'r00t'}
ENV _R00T=${_R00T}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ENV _R00T_HOME=${_R00T_HOME}
ARG KERNEL_TYPE
WORKDIR /${_R00T}
# COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/         ./mnt/

RUN mkdir -pv dvlw && \
    mkdir -pv dls && \
    mkdir -pv .docker/run && \
    ln -fsv dvlw devels-workshop && \
    ln -fsv dvlw/dvlp dvlp && \
    ln -fsv dvlw/dvlp/docker/kali kdock && \
    ln -fsv dvlw/dvlp/docker docker && \
    ln -fsv ${_R00T_HOME} /home/${_R00T} 
# && \
# chmod -R 770 /${_R00T}
WORKDIR ${_MNT}/data
RUN mkdir -pv dls && \
    mkdir -pv bak && \
    mkdir -pv etc && \
    # mkdir -pv home && \
    # mkdir -pv opt && \
    chmod -R 770 dls && \
    chmod -R 770 etc && \
    chmod -R 770 ${_MNT}/data
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${R00T_HOME}
ADD ./Dockerfile .${R00T_HOME}/Dockerfile
ADD ./docker-compose.yaml .${R00T_HOME}/docker-compose.yaml
ADD .env .${R00T_HOME}/.env




###############################
#  dvlp_base-r00t-volumes-builder #
###############################
FROM dvlp_base-r00t-volumes-builder AS dvlp_base-r00t-kernel-volumes-builder
ARG _MNT
ARG _CPU_ARCH
ARG _CPU_VENDOR
WORKDIR /${_R00T}
RUN ln -fsv dvlw/dvlp dvlp && \
    ln -fsv dvlw/dvlp/kernels/linux linux && \
    # parse vars from .env
    # _CPU_ARCH=${_CPU_ARCH} && _CPU_VENDOR=${_CPU_VENDOR} && \
    # ln -fsv "dvlw/dvlp/kernels/linux/${_CPU_ARCH}/${_CPU_VENDOR}" && \
    ln -fsv dvlw/dvlp/kernels kernels && \
    mkdir -pv /${_R00T} && mkdir -pv kache
#  && \
# chmod -R 770 /${_R00T} && \
# cp -prv * /home/${_R00T}
WORKDIR /

###############################
#  dvlp_base-r00t-volumes-built #
###############################
FROM dvlp_base-r00t-volumes-builder AS dvlp_base-r00t-volumes-built
WORKDIR /
COPY --from=dvlp_repo ./repos/dvlw/ ./${_R00T}/dvlw/

FROM dvlp_base-r00t-kernel-volumes-builder AS dvlp_base-r00t-kernel-volumes-built
WORKDIR /
COPY --from=dvlp_repo-kernel ./repos/dvlw/ ./${_R00T}/dvlw/


############################# BASE BUILD (part 1 ) ###################################
FROM kalilinux/kali-rolling:latest AS dvlp_base-skel
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ENV _MNT=${_MNT}
ENV _R00T=${_R00T}
ENV _R00T_GRP=${_R00T_GRP}
ENV _R00T_HOME=${_R00T_HOME}
ENV _DVL=${_DVL}
ENV _DVL_GRP=${_DVL_GRP}
ENV _DVL_HOME=${_DVL_HOME}
ENV _AGL=${_AGL}
ENV _AGL_GRP=${_AGL_GRP}
ENV _AGL_HOME=${_AGL_HOME}
ENV _W0RLD_GRP=${_W0RLD_GRP}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
USER root
WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/base-skel,sharing=locked \
    # mkdir -p /usr/lib/modules && \
    mkdir -pv /usr/lib/binfmt.d && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo ':WSLInterop:M::MZ::/init:PF' > /usr/lib/binfmt.d/WSLInterop.conf && \
    echo 'Acquire::Retries "3";\
    Acquire::https::Timeout "240";\
    Acquire::http::Timeout "240";\
    Acquire::http::No-Cache="true"; \ 
    Acquire::http::Pipeline-Depth="0"; \
    Acquire::BrokenProxy="true"; \
    Acquire::Check-Valid-Until="false"; \
    Acquire::Check-Date="false"; \
    Debug::Acquire::https "true"; \
    Binary::apt-get::APT::Get::Assume-Yes "true"; \
    Binary::apt-get::APT::Install-Recommends "false"; \
    Binary::apt-get::APT::Install-Suggests "false"; \
    Binary::apt::APT::Install-Recommends "true"; \
    Binary::apt::APT::Install-Suggests "true";\
    Binary::apt-get::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
    echo 'tzdata tzdata/Areas select America' | debconf-set-selections && \
    echo 'tzdata tzdata/Zones/America select Los Angeles' | debconf-set-selections && \
    groupadd    -g 999  docker && \
    groupadd            ${_R00T}    && \
    groupadd            ${_AGL_GRP}    && \
    groupadd            ${_DVL_GRP}    && \
    groupadd            ${_W0RLD_GRP}  && \
    useradd -s /bin/bash -u 0   -o  -g root            -G ${_R00T},${_W0RLD_GRP}        -d /${_R00T}        ${_R00T} && \
    useradd -s /bin/bash            -g ${_AGL_GRP}     -G ${_W0RLD_GRP},${_DVL_GRP}     -d ${_AGL_HOME}     ${_AGL} && \
    useradd -s /bin/bash            -g ${_DVL_GRP}     -G ${_W0RLD_GRP}                 -d ${_DVL_HOME}     ${_DVL} && \
    passwd -d ${_AGL} && \
    passwd -d ${_DVL} && \
    passwd -d ${_R00T} && \
    passwd -d root && \
    passwd -l root && \
    install -d -m 0750 -o ${_AGL} -g ${_AGL_GRP} /mnt/dls ${_MNT}/dls /kache /repos/dvlw /kache /mnt/c /mnt/n && \
    install -d -m 0777 -o ${_R00T} -g ${_W0RLD_GRP} /mnt/dls && \
    # mkdir -p /${_R00T}/dvlw && \
    # mkdir -m 770 ${_MNT}/dls && \
    # mkdir -m 770 repos  && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get purge -y openssh-server && \
    apt-get install --no-install-recommends -y curl locales openssh-server ssh systemd-sysv sysvinit-utils wget && \   
    update-locale LANGUAGE="C" && \
    update-locale LANG="C" && \
    update-locale LC_ALL="C" && \
    ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime  && \
    apt-get update --fix-missing -yq && apt-get install -f && apt-get upgrade -yq && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

###############################

FROM dvlp_base-skel AS dvlp_base-volumes-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
COPY --from=dvlp_base-devel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    ./home/${_DVL}/                 ./home/${_DVL}/
COPY --from=dvlp_base-angel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./home/${_AGL}/                 ./home/${_AGL}/
COPY --from=dvlp_base-r00t-volumes-builder            --chown=${_R00T}:${_R00T}       --chmod=770    ./home/${_R00T}/                ./home/${_R00T}/ 
COPY --from=dvlp_base-devel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    .${_DVL_HOME}/                  .${_DVL_HOME}/
COPY --from=dvlp_base-angel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    .${_AGL_HOME}/                  .${_AGL_HOME}/
COPY --from=dvlp_base-r00t-volumes-builder            --chown=${_R00T}:${_R00T}       --chmod=770    ./${_R00T}/                     ./${_R00T}/
COPY --from=dvlp_repo                                  --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/   ./repos/
# COPY --from=dvlp_repo                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/                   .${_AGL_HOME}/dvlw/
# COPY --from=dvlp_repo                               --chown=${_R00T}:${_R00T}     --chmod=770    ./repos/dvlw/                     ./${_R00T}/dvlw/
# special copy to give ownership of /r00t/dvlw to r00t
COPY --from=dvlp_base-r00t-volumes-builder            --chown=${_R00T}:${_R00T}     --chmod=770    ./${_R00T}/dvlw/                     ./${_R00T}/dvlw/
# COPY --from=dvlp_base-angel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    .${_AGL_HOME}/dvlw/                  .${_AGL_HOME}/dvlw/
# COPY --from=dvlp_base-devel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    .${_DVL_HOME}/dvlw/                  .${_DVL_HOME}/dvlw/
COPY --from=dvlp_repo                               --chown=${_DVL}:${_DVL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_DVL_HOME}/
COPY --from=dvlp_repo                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_AGL_HOME}/
COPY --from=dvlp_repo                               --chown=${_R00T}:${_R00T}       --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ ./${_R00T}/
COPY --from=dvlp_repo                               --chown=${_R00T}:${_R00T}       --chmod=755     /repos/dvlw/dvlp/mnt/etc/*     ./etc/
COPY --from=dvlp_repo                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/          .${_MNT}/ 

###############################
#  dvlp_base-kernel-volumes-builder #
###############################

FROM dvlp_base-skel AS dvlp_base-kernel-volumes-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
COPY --from=dvlp_base-devel-kernel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    ./home/${_DVL}/                 ./home/${_DVL}/
COPY --from=dvlp_base-angel-kernel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./home/${_AGL}/                 ./home/${_AGL}/
COPY --from=dvlp_base-r00t-kernel-volumes-builder            --chown=${_R00T}:${_R00T}       --chmod=770    ./home/${_R00T}/                ./home/${_R00T}/ 
COPY --from=dvlp_base-devel-kernel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    .${_DVL_HOME}/                  .${_DVL_HOME}/
COPY --from=dvlp_base-angel-kernel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    .${_AGL_HOME}/                  .${_AGL_HOME}/
COPY --from=dvlp_base-r00t-kernel-volumes-builder            --chown=${_R00T}:${_R00T}       --chmod=770    ./${_R00T}/                     ./${_R00T}/
COPY --from=dvlp_repo-kernel                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/                          ./repos/
COPY --from=dvlp_repo-kernel                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/                   .${_AGL_HOME}/dvlw/
COPY --from=dvlp_repo-kernel                               --chown=${_R00T}:${_R00T}     --chmod=770    ./repos/dvlw/                     ./${_R00T}/dvlw/
# # special copy to give ownership of /r00t/dvlw to agl
# COPY --from=dvlp_base-r00t-kernel-volumes-builder            --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./${_R00T}/dvlw/                     ./${_R00T}/dvlw/
# COPY --from=dvlp_base-angel-volumes-builder           --chown=${_AGL}:${_AGL_GRP}     --chmod=770    .${_AGL_HOME}/dvlw/                  .${_AGL_HOME}/dvlw/
# COPY --from=dvlp_base-devel-volumes-builder           --chown=${_DVL}:${_DVL_GRP}     --chmod=770    .${_DVL_HOME}/dvlw/                  .${_DVL_HOME}/dvlw/
COPY --from=dvlp_repo-kernel                               --chown=${_DVL}:${_DVL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_DVL_HOME}/
COPY --from=dvlp_repo-kernel                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ .${_AGL_HOME}/
COPY --from=dvlp_repo-kernel                               --chown=${_R00T}:${_R00T}       --chmod=770    ./repos/dvlw/dvlp/mnt/HOME_NIX/ ./${_R00T}/
COPY --from=dvlp_repo-kernel                               --chown=${_R00T}:${_R00T}       --chmod=755     /repos/dvlw/dvlp/mnt/etc/*     ./etc/
COPY --from=dvlp_repo-kernel                               --chown=${_AGL}:${_AGL_GRP}     --chmod=770    ./repos/dvlw/dvlp/mnt/          .${_MNT}/ 

############################# volumes-built ##################################
FROM dvlp_base-volumes-builder AS dvlp_base-volumes-built

FROM dvlp_base-kernel-volumes-builder AS dvlp_base-kernel-volumes-built


############################# BASE BUILD ###################################

FROM dvlp_base-volumes-builder AS dvlp_base-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ENV DEBIAN_FRONTEND=noninteractive


WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/base-kernel,sharing=locked \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get purge -y openssh-server
RUN \
    apt-get install --no-install-recommends -y apt-utils apt-transport-https curl libssl-dev locales openssh-server sudo ssh systemd-sysv sysvinit-utils vim wget && \    
    usermod -aG docker root && \
    usermod -aG docker ${_R00T} && \
    usermod -aG sudo ${_AGL} && \
    usermod -aG docker ${_AGL} && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt 

############################# BASE BUILD KERNEL ###################################

FROM dvlp_base-kernel-volumes-builder AS dvlp_base-kernel-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG DOCKER_BUILD_TIMESTAMP
ARG _MNT
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/base-kernel,sharing=locked \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y && \
    apt-get purge -y openssh-server
RUN \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y apt-utils apt-transport-https curl libssl-dev locales openssh-server sudo ssh systemd-sysv sysvinit-utils vim wget && \    
    usermod -aG docker root && \
    usermod -aG docker ${_R00T} && \
    usermod -aG sudo ${_AGL} && \
    usermod -aG docker ${_AGL} && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt 
RUN \
    --mount=type=cache,target=/var/cache/dvlp/build-kernel,sharing=locked \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --install-recommends -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y alien autoconf apt-utils apt-transport-https bison bc build-essential busybox cpio curl dbus-user-session daemonize dwarves fakeroot flex fontconfig \
    gawk gh git gnupg2 kmod libblkid-dev libffi-dev libudev-dev libaio-dev libattr1-dev libelf-dev libpam-systemd libncurses-dev libssl-dev libssl-dev lightdm lxcfs pigz plymouth plzip pkg-config python3-dev \
    python3-setuptools python3-cffi nvi net-tools rsync screen shellcheck ssh systemd-sysv sysvinit-utils snapd systemd-sysv sysvinit-utils uuid-dev virtualbox zstd wget && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt



################################## MAKE #######################################

FROM dvlp_base-builder AS dvlp_base

################################### KERNEL ###########################################

######################################################################################
########################  KERNEL MAKE/R - KERNEL COMPILER  ###########################
######################################################################################

FROM dvlp_base-kernel-builder AS dvlp_base-kernel
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG _WIN_USER
ARG DOCKER_BUILD_TIMESTAMP
ARG KERNEL_PACKAGE_NAME
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ENV KERNEL_TYPE=${KERNEL_TYPE}
ENV KERNEL_FEATURE=${KERNEL_FEATURE}
ENV CONFIG_FILE=${CONFIG_FILE}
# ENV _WIN_USER=${_WIN_USER}
ENV DOCKER_BUILD_TIMESTAMP=${DOCKER_BUILD_TIMESTAMP}
ARG installkernel
# WORKDIR /boot
# WORKDIR /kache
# WORKDIR /usr/lib
# WORKDIR /${_R00T}/dvlw
WORKDIR /${_R00T}/dvlw/dvlp/kernels/linux
USER ${_R00T}
SHELL ["/bin/bash", "-c"]
RUN \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y

# WORKDIR /
# ONBUILD COPY --from=dvlp_base${KERNEL_TYPE:+-kernel}-builder ./ ./
SHELL ["/bin/bash", "-c"]
RUN \
    git config --global --add safe.directory /${_R00T}/dvlw/dvlp && \
    git config --global --add safe.directory /${_R00T}/dvlw/dvlp/kernels 
RUN \
    # --mount=type=cache,target=/var/cache/kernel_${KERNEL_TYPE}_${KERNEL_FEATURE}_${CONFIG_FILE},sharing=private \
    bash build-export-kernel.sh "${KERNEL_TYPE}" "${CONFIG_FILE}" "${KERNEL_FEATURE}" "${DOCKER_BUILD_TIMESTAMP}" 
RUN \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

WORKDIR /

# every onbuild command in dvlp_make-kernel will be triggered to run here
# use COPY --from=dvlp_made-kernel instead of COPY --from=dvlp_make-kernel

###############################################################################
########################  dvlp_base-xxxx (cont'd)  ############################
###############################################################################
############################### dvlp_base #####################################

###############
# dvlp_base #
###############
# FROM scratch AS dvlp_base-skel 
# OR
# FROM dvlp_base-builder AS dvlp_base-skel 
# COPY --from=dvlp_base_build ./ ./
# COPY --from=dvlp_made-kernel ./boot/ ./boot/
# COPY --from=dvlp_made-kernel ./usr/src/ ./usr/src/
# COPY --from=dvlp_made-kernel ./usr/lib/modules/ ./usr/lib/modules/
# COPY --from=dvlp_made-kernel ./kache/ ./kache/
# COPY --from=dvlp_made-kernel ./${_R00T}/dvlw/ ./${_R00T}/dvlw/


################################# BASE #######################################

# FROM kindtek/devels-playground:kali-skel-image AS dvlp_base
# ARG _AGL_USR
# ARG _DVL_USR
# ARG _R00T_USR
# ARG _AGL=${_AGL:-'agl'}
# ARG KERNEL_TYPE
# ARG KERNEL_FEATURE
# ARG CONFIG_FILE
# ARG _WIN_USER
# ARG DOCKER_BUILD_TIMESTAMP
# ARG installkernel
# ENV _AGL=$_AGL
# ENV _DVL=$_DVL_USR
# ENV _R00T=$_R00T_USR
# USER root

# ONBUILD COPY --from=dvlp_made-kernel ./boot/ ./boot/
# ONBUILD COPY --from=dvlp_made-kernel ./usr/src/ ./usr/src/
# WORKDIR /usr/lib/modules
# ONBUILD COPY --from=dvlp_made-kernel ./ ./usr/lib/modules/
# WORKDIR /
# ONBUILD COPY --from=dvlp_made-kernel ./kache/ ./kache/
# ONBUILD COPY --from=dvlp_made-kernel ./${_R00T}/dvlw/ ./${_R00T}/dvlw/
# ONBUILD WORKDIR /${_R00T}/dvlw/dvlp/kernels/linux/linux-build*

###################################################################
######################## KERNEL KACHE #############################
###################################################################

################
# get-kernel #
################

FROM scratch AS dvlp_get-kernel
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG _WIN_USER
ARG DOCKER_BUILD_TIMESTAMP
ARG KERNEL_PACKAGE_NAME
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ENV KERNEL_TYPE=${KERNEL_TYPE}
ENV KERNEL_FEATURE=${KERNEL_FEATURE}
ENV CONFIG_FILE=${CONFIG_FILE}
USER ${_R00T}
WORKDIR /boot
WORKDIR /kache
WORKDIR /usr/lib
WORKDIR /
COPY --from=dvlp_madk-kernel ./${_R00T}/dvlw/dvlp/kernels/linux/kache/ ./


#################################################################################
############################### IMAGE BASES #####################################
################################################################################

################################## BARE #########################################
############
# dvlp_cli-bare #
############
# FROM dvlp_base AS dvlp_cli-bare
# ARG _MNT=${_MNT:-/mnt/data}
# ARG _R00T=${_R00T:-'r00t'}
# ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
# ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
# ARG _DVL=${_DVL:-'dvl'}
# ARG _DVL_GRP=${_DVL_GRP:-'hell'}
# ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
# ARG _AGL=${_AGL:-'agl'}
# ARG _AGL_GRP=${_AGL_GRP:-'halo'}
# ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
# ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
# ARG DEBIAN_FRONTEND
# ARG DEBCONF_NONINTERACTIVE_SEEN
# USER ${_R00T}
# WORKDIR /
# RUN echo "[user]" | tee /etc/wsl.conf && \
#     echo "default = ${_AGL}" | tee --append /etc/wsl.conf && \
#     rm -rf /etc/ssl/certs/* && \
#     apt-get -y install ca-certificates && \
#     update-ca-certificates && \
#     rm -rf /var/lib/apt/lists && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     echo " \
#     Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
#     rm -rf /var/lib/apt/lists && \
#     rm -rf /var/cache/apt 


# ################################### CLI #########################################

########################
# dvlp_cli        #
########################
FROM dvlp_base${KERNEL_TYPE:+-kernel} AS dvlp_cli-base

FROM dvlp_cli-base AS dvlp_cli-base-kernel

FROM dvlp_cli-base${KERNEL_TYPE:+-kernel} AS dvlp_cli-builder

FROM dvlp_cli-builder AS dvlp_cli
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
RUN rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    rm -rf /etc/ssl/certs/* && \
    apt-get -y install ca-certificates && \
    update-ca-certificates && \
    echo " \
    Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

########################
# dvlp_base-scan-build #
########################
# FROM kindtek/devels-playground:kali-skel-image AS dvlp_base-scan-builder
# USER ${_R00T}
# SHELL ["/bin/bash", "-c"]
# WORKDIR /${_R00T}/build
# RUN \
#     rm -f /etc/apt/apt.conf.d/docker-clean && \
#     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache
# RUN \
#     --mount=type=cache,target=/var/cache/dvlp/scan,sharing=locked \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     apt-get install -y --reinstall ca-certificates && \
#     apt-get install -y software-properties-common && \
#     apt-get update --fix-missing && apt-get install -f && \
#     apt-get install -y  --install-suggests autoconf automake build-essential espeak ethtool expect hostapd iw lame libnl-3-dev libnl-genl-3-dev libpcre2-dev libhwloc-dev libssl-dev libsqlite3-dev libtool libcmocka-dev libpcap-dev pkg-config ruby-dev rfkill shtool screen strace tcpdump usbutils wpasupplicant zlib1g-dev && \
#     rm -rf /var/lib/apt/lists && \
#     rm -rf /var/cache/apt
# WORKDIR /${_R00T}/build
# RUN git clone https://github.com/nmap/nmap 
# WORKDIR /${_R00T}/build/nmap
# RUN \
#     ./configure && \
#     make && \
#     make install && \
#     rm -rf /${_R00T}/build/nmap
# WORKDIR /${_R00T}/build
# RUN git clone https://github.com/aircrack-ng/aircrack-ng aircrack
# WORKDIR /${_R00T}/build/aircrack
# ENV NOCONFIGURE=1
# RUN \
#     ./autogen.sh && \
#     ./configure  && \
#     make  && \
#     make check && \
#     make install
# WORKDIR /usr/share
# RUN git clone https://github.com/beefproject/beef beef
# WORKDIR /usr/share/beef
# USER agl
# RUN \
#     gem install bundler
# # RUN \
# #     bundle config set --local with 'test' 
# RUN \
#     yes "" | ./install 
# WORKDIR /
# USER ${_R00T}
# RUN rm -rf /etc/ssl/certs/* && \
# apt-get -y install ca-certificates && \
# update-ca-certificates && \
# rm -rf /var/lib/apt/lists && \
# apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
# echo " \
# Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
# rm -rf /var/lib/apt/lists && \
# rm -rf /var/cache/apt 

##################
# dvlp_base-scan #
##################
# FROM dvlp_base-scan-builder AS dvlp_base-scan
# COPY --from=dvlp_python ./ ./
# USER ${_R00T}
# RUN \
#     rm -f /etc/apt/apt.conf.d/docker-clean && \
#     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache
# RUN \
#     --mount=type=cache,target=/var/cache/dvlp/scan,sharing=locked \
#     # rm -rf /var/lib/apt/lists && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     apt-get --no-install-recommends -y install burpsuite finger hydra maltego metasploit-framework ncat nmap nikto rpcbind telnet wireshark && \
#     echo " \
# Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm 
# # && \
# #     rm -rf /var/lib/apt/lists && \
# #     rm -rf /var/cache/apt

################################# PYTHON ########################################
#####################
# dvlp_python-build #
#####################
# FROM kindtek/devels-playground:kali-skel-image AS dvlp_python-build
FROM dvlp_cli-builder AS dvlp_cli-goodies
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
USER r00t

RUN \
    # --mount=type=cache,target=/var/cache/dvlp/python,sharing=locked \
    # rm -f /etc/apt/apt.conf.d/docker-clean && \
    # echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get --no-install-recommends -y install apt-utils jq libdbus-1-dev libcairo2-dev libgirepository1.0-dev libpython3-dev python3-pip python3-venv pkg-config  && \
    # && \
    # # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # rm -rf /var/cache/apt
    # RUN \
    # --mount=type=cache,target=/var/cache/pip,sharing=locked \
    pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    python3 -m pip list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip3 install --upgrade --no-warn-script-location --no-deps && \
    # RUN \
    #     apt-get --no-install-recommends -y remove libdbus-1-dev libcairo2-dev libgirepository1.0-dev libpython3-dev 
    ###############################
    # dvlp_python-build #
    ###############################
    # FROM dvlp_python-build AS dvlp_python
    # USER ${_R00T}
    # WORKDIR /
    # ARG angel_exists=true
    # ARG devel_exists=true
    # ARG ${_R00T}_exists=true
    # RUN \
    #     --mount=type=cache,target=/var/cache/dvlp/python,sharing=locked \
    #     rm -f /etc/apt/apt.conf.d/docker-clean && \
    #     # rm -rf /var/lib/apt/lists && \
    #     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    #     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    #     apt-get install --no-install-recommends -y jq python3-pip python3-venv 
    # && \
    # rm -rf /var/lib/apt/lists && \
    # rm -rf /var/cache/apt
    # WORKDIR /${_R00T}
    # RUN \
    # --mount=type=cache,target=/var/cache/pip,sharing=private \
    # $r00t_exists && 
    # pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    # pip3 install cdir --user --target=/${_R00T} && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt
USER ${_DVL}
WORKDIR ${_DVL_HOME}
RUN \
    # --mount=type=cache,target=/var/cache/pip,sharing=private \
    pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    pip3 install cdir --user 
USER ${_AGL}
WORKDIR ${_AGL_HOME}
# RUN  ( $angel_exists && (chown -R ${_AGL}:${_AGL_GRP} ${_AGL_HOME} || chown -R ${_AGL}:${_AGL_GRP} ${_AGL_HOME}/.local || angel_exists=false )) 
RUN \
    # --mount=type=cache,target=/var/cache/pip,sharing=private \
    pip3 install pip --upgrade --no-warn-script-location --no-deps && \
    pip3 install cdir --user
USER ${_R00T}
WORKDIR /


# RUN apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     apt-get autoremove -y && apt-get remove -y libdbus-1-dev libcairo2-dev libgirepository1.0-dev libpython3-dev apt-utils



# #########################
# # dvlp_python-lite #
# #########################
# FROM dvlp_python-lite AS dvlp_python-lite
# ARG CONFIG_FILE
# ARG KERNEL_TYPE
# ARG KERNEL_FEATURE
# ARG _WIN_USER
# ARG DOCKER_BUILD_TIMESTAMP
# ARG installkernel
# USER ${_R00T}
# WORKDIR / 
# COPY --from=dvlp_python-build ./ ./
# RUN rm -rf /etc/ssl/certs/* && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     apt-get -y install ca-certificates && \
#     update-ca-certificates && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     rm -rf /var/lib/apt/lists && \
#     rm -rf /var/cache/apt


######### POWERHELL ###########
###############################
# dvlp_msdot-build-lite #
##############################
# FROM kindtek/devels-playground:kali-skel-image AS dvlp_msdot-build-lite

# for powerhell install - https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3
## Download the Microsoft repository GPG keys
RUN \
    # --mount=type=cache,target=/var/cache/dvlp/msdot,sharing=locked \
    # rm -f /etc/apt/apt.conf.d/docker-clean && \
    # echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    # rm -rf /var/lib/apt/lists && \
    # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y powershell && \
    # wget "https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb" && \
    # mv packages-microsoft-prod.deb /var/cache/apt/archives/packages-microsoft-prod.deb && \
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/microsoft-prod.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" | tee /etc/apt/sources.list.d/microsoft-prod.list  > /dev/null && \
    # dpkg -i /var/cache/apt/archives/packages-microsoft-prod.deb && \
    #     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # # rm -rf /var/lib/apt/lists && \
    #     rm -rf /var/cache/apt
    #########################
    # dvlp_msdot-build #
    #########################
    # FROM dvlp_msdot-build-lite AS dvlp_msdot-build
    # RUN \
    # --mount=type=cache,target=/var/cache/dvlp/msdot,sharing=locked \
    # rm -f /etc/apt/apt.conf.d/docker-clean && \
    # echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    # rm -rf /var/lib/apt/lists && \
    # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # apt-get install --no-install-recommends -y apt-utils ca-certificates curl gnupg2 apt-transport-https lsb-release wget && \
    # curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    # wget -O - https://pkg.wslutiliti.es/public.key | tee --append /etc/apt/trusted.gpg.d/wslu.asc && \
    # echo "deb [arch=$(dpkg --print-architecture)] https://pkg.wslutiliti.es/kali kali-rolling main" | tee --append /etc/apt/sources.list && \
    # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # # apt-get install -y powershell wslu && \
    # apt-get install --no-install-recommends -y dotnet-sdk-7.0 wslu && \
    # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # rm -rf /var/lib/apt/lists && \
    # rm -rf /var/cache/apt
    # 
    ########################
    # dvlp_msdot-lite #
    ########################
    # FROM dvlp_msdot-builder-lite AS dvlp_msdot-builder
    # ARG _AGL_USR
    # ARG _DVL_USR
    # ARG _R00T_USR
    # ARG _AGL=${_AGL:-'agl'}
    # ARG KERNEL_TYPE
    # ENV _AGL=$_AGL
    # ENV _DVL=$_DVL_USR
    # ENV _R00T=$_R00T_USR
    # USER r00t
    # WORKDIR /
    # RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    #     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    #     rm -rf /etc/ssl/certs/* && \
    #     apt-get -y install ca-certificates && \
    #     update-ca-certificates && \
    #     rm -rf /var/lib/apt/lists && \
    #     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    #     rm -rf /var/lib/apt/lists && \
    #     rm -rf /var/cache/apt
    # 
    ########################## DOCKER IN DOCKER ######################################
    ########################
    # dvlp_dind-build #
    ########################
    # FROM dvlp_msdot-builder AS dvlp_dind-builder
    # USER ${_R00T}
    # WORKDIR /
    # DOCKER - https://docs.docker.com/engine/install/ubuntu/
    # RUN \
    #     --mount=type=cache,target=/var/cache/dvlp/dind,sharing=locked \
    #     rm -f /etc/apt/apt.conf.d/docker-clean && \
    #     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y ca-certificates curl lsb-release gpg && \
    mkdir -pv /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gnupg && \
    # apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

#######################
# dvlp_dind #
#######################
# FROM dvlp_dind-build AS dvlp_dind-base
# COPY --from=dvlp_base ./ ./

# FROM dvlp_dind-build AS dvlp_dind-base-kernel
# COPY --from=dvlp_base-kernel ./ ./

# FROM dvlp_dind-base${KERNEL_TYPE:+-kernel} AS dvlp_dind_built

# FROM dvlp_dind-builder AS dvlp_dind
# USER ${_R00T}
# ARG KERNEL_TYPE
# ARG KERNEL_FEATURE
# ARG CONFIG_FILE
# ARG _WIN_USER
# ARG DOCKER_BUILD_TIMESTAMP
# ARG installkernel
# USER ${_R00T}
# WORKDIR /
# RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
#     echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
#     rm -rf /etc/ssl/certs/* && \
#     apt-get -y install ca-certificates && \
#     update-ca-certificates && \
#     rm -rf /var/lib/apt/lists && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     rm -rf /var/lib/apt/lists && \
#     rm -rf /var/cache/apt


#################################### GUI ######################################
##################
# dvlp_gui-lite #
#################
# FROM scratch AS dvlp_gui-lite-base
# COPY --from=dvlp_python ./ ./
# COPY --from=dvlp_msdot-build-lite ./ ./
# COPY --from=dvlp_dind-build ./ ./
# COPY --from=dvlp_base ./ ./
# # COPY --from=dvlp_msdot-build-lite ./etc/apt/trusted.gpg.d/microsoft-prod.gpg ./etc/apt/trusted.gpg.d/microsoft-prod.gpg

# FROM scratch AS dvlp_gui-lite-base-kernel
# COPY --from=dvlp_python ./ ./
# COPY --from=dvlp_msdot-build-lite ./ ./
# COPY --from=dvlp_dind-build ./ ./
# COPY --from=dvlp_base-kernel ./ ./
# # COPY --from=dvlp_msdot-build-lite ./etc/apt/trusted.gpg.d/microsoft-prod.gpg ./etc/apt/trusted.gpg.d/microsoft-prod.gpg

# FROM dvlp_gui-lite-base${KERNEL_TYPE:+-kernel} as dvlp_gui-lite-builder
FROM dvlp_cli-goodies AS dvlp_gui-builder
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/gui-lite,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    rm -rf /var/lib/apt/lists && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/microsoft-prod.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" | tee /etc/apt/sources.list.d/microsoft-prod.list  > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # RUN \
    #     rm -rf /etc/ssl/certs/* && \
    #     update-ca-certificates 
    apt-get install --install-recommends -y apt-transport-https curl && \
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y brave-browser bridge-utils libvirt-clients libvirt-daemon-system qemu-system-gui qemu-kvm vlc x11-apps && \
    # change last line of this file - fix for brave-browser displaying empty windows
    cp /opt/brave.com/brave/brave-browser /opt/brave.com/brave/brave-browser.old && \
    head -n -1 /opt/brave.com/brave/brave-browser.old | tee /opt/brave.com/brave/brave-browser > /dev/null && \
    # now no longer need to add --disable-gpu flag everytime
    echo '"$HERE/brave" "$@" " --disable-gpu " || true' | tee --append /opt/brave.com/brave/brave-browser > /dev/null && \
    # apt-get install --no-install-recommends -y vlc x11-apps qemu-system-gui qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt
COPY --from=dvlp_repo /repos/dvlw/dvlp/mnt/opt/* /opt/

# # # this is a better way to do this but needs work
# # # cd /opt/brave.com/brave && \
# # # brave_old_line='\"\$HERE\/brave\"\s\"\$\@\"\s\|\|\strue' && \
# # # brave_new_line='"\$HERE/brave" "\$@" " " --disable-gpu " || true' && \
# # # sed -i 's/$brave_old_line/$brave_new_line/g' /opt/brave.com/brave/brave-browser && cd /home/${_DVL} && \
# FROM dvlp_gui-lite-builder AS dvlp_gui-lite
# ARG _AGL_USR
# ARG _DVL_USR
# ARG _R00T_USR
# ARG _AGL=${_AGL:-'agl'}
# ENV _AGL=$_AGL
# ENV _DVL=$_DVL_USR
# ENV _R00T=$_R00T_USR
# ARG REFRESH_REPO
# ARG CONFIG_FILE
# ARG KERNEL_TYPE
# ARG KERNEL_FEATURE
# ARG CONFIG_FILE
# ARG _WIN_USER
# ARG DOCKER_BUILD_TIMESTAMP
# ARG installkernel
# RUN rm -rf /var/lib/apt/lists && \
#     apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
#     rm -rf /etc/ssl/certs/* && \
#     apt-get -y install ca-certificates && \
#     update-ca-certificates && \
#     echo " \
#     Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
#     rm -rf /var/lib/apt/lists && \
#     rm -rf /var/cache/apt

#################
# dvlp_gui #
#################
# wsl2 required
FROM dvlp_gui-builder AS dvlp_gui
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
USER r00t
WORKDIR /
RUN \
    --mount=type=cache,target=/var/cache/dvlp/gui,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee --append /etc/apt/apt.conf.d/keep-cache && \
    # rm -rf /etc/ssl/certs/* && \
    # # apt-get -y install ca-certificates && \
    # update-ca-certificates && \
    # rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install -y gobject-introspection libgirepository1.0-dev xrdp xfce4 xfce4-goodies && \
    apt-get install -y locales && \
    dpkg-reconfigure --frontend noninteractive locales && \
    echo "/usr/sbin/lightdm" | tee /etc/X11/default-display-manager && \
    locale-gen && update-locale && \
    apt-get install -y lightdm && \
    mkdir -pv /var/lib/lightdm/data && \
    echo "set shared/default-x-display-manager lightdm" | debconf-communicate && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y locales kali-defaults kali-root-login desktop-base kali-win-kex kali-desktop-xfce pulseaudio-module-xrdp virt-manager virtualbox && \
    # rm -rf /etc/ssl/certs/* && \
    # apt-get -y install ca-certificates && \
    # update-ca-certificates && \
    # rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    # echo " \
    # Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt
COPY --from=dvlp_repo --chmod=755 /repos/dvlw/dvlp/mnt/etc/* /etc/


FROM dvlp_gui-builder AS dvlp_gui-goodies
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
RUN rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    rm -rf /etc/ssl/certs/* && \
    apt-get -y install ca-certificates && \
    update-ca-certificates && \
    echo " \
    Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

############################## CUDA ###############################
##################
# dvlp_cuda #
##################
FROM dvlp_gui-goodies-builder AS dvlp_gui-cuda-goodies
ARG _MNT=${_MNT:-/mnt/data}
ARG _R00T=${_R00T:-'r00t'}
ARG _R00T_GRP=${_R00T_GRP:-'r00t'}
ARG _R00T_HOME=${_R00T_HOME:-'/r00t'}
ARG _DVL=${_DVL:-'dvl'}
ARG _DVL_GRP=${_DVL_GRP:-'hell'}
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG _AGL=${_AGL:-'agl'}
ARG _AGL_GRP=${_AGL_GRP:-'halo'}
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG _W0RLD_GRP=${_W0RLD_GRP:-'w0rld'}
ARG DEBIAN_FRONTEND
ARG DEBCONF_NONINTERACTIVE_SEEN
ARG _WIN_USER
USER ${_R00T}
WORKDIR /
RUN rm -rf /etc/ssl/certs/* && \
    apt-get -y install ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists && \
    apt-get update --fix-missing -y && apt-get install -f && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y nvidia-cuda-toolkit && \
    echo " \
    Binary::apt-get::APT::Install-Recommends 'true';" | tee --append /etc/apt/apt.conf.d/98aptsuggrecomm && \
    # rm -rf /var/lib/apt/lists && \
    rm -rf /var/cache/apt

###################################################################
########################### K-HOME ################################
###################################################################
############
# get-home #
############


FROM scratch AS dvlp_k-home-nix
# ARG WINDOWS
# ARG LINUX
# # determine which home dir to get -- default is HOME_NIX 
ARG _AGL_HOME=${_AGL_HOME:-'/hal'}
ARG HOME_DIR='HOME_NIX'
ARG KERNEL_TYPE
# # if WINDOWS argument is provided, use win home dir
# ARG HOME_DIR="${WINDOWS:+'HOME_WIN'}"
# # if LINUX argument is provided, use nix home dir
# ARG HOME_DIR="${LINUX:+'HOME_NIX'}"
WORKDIR /
COPY --from=dvlp_repo-kernel --chmod=770 ./repos/ ./
COPY --from=dvlp_base-angel-kernel-volumes-builder .${_AGL_HOME}/ ./

FROM dvlp_k-home-nix AS dvlp_k-home-nix-angel


FROM scratch AS dvlp_k-home-nix-devel
# ARG WINDOWS
# ARG LINUX
# # determine which home dir to get -- default is HOME_NIX 
ARG _DVL_HOME=${_DVL_HOME:-'/hel'}
ARG HOME_DIR='HOME_NIX'
ARG KERNEL_TYPE
# # if WINDOWS argument is provided, use win home dir
# ARG HOME_DIR="${WINDOWS:+'HOME_WIN'}"
# # if LINUX argument is provided, use nix home dir
# ARG HOME_DIR="${LINUX:+'HOME_NIX'}"
WORKDIR /
COPY --from=dvlp_repo-kernel --chmod=770 ./repos/ ./
COPY --from=dvlp_base-devel-kernel-volumes-builder .${_DVL_HOME}/ ./

FROM scratch AS dvlp_k-home-nix-r00t
# ARG WINDOWS
# ARG LINUX
# # determine which home dir to get -- default is HOME_NIX 
ARG HOME_DIR='HOME_NIX'
ARG KERNEL_TYPE
# # if WINDOWS argument is provided, use win home dir
# ARG HOME_DIR="${WINDOWS:+'HOME_WIN'}"
# # if LINUX argument is provided, use nix home dir
# ARG HOME_DIR="${LINUX:+'HOME_NIX'}"
WORKDIR /
COPY --from=dvlp_repo-kernel --chmod=770 ./repos/ ./
COPY --from=dvlp_base-r00t-kernel-volumes-builder ./${_R00T}/ ./


############
# get-home #
############
FROM scratch AS dvlp_k-home-win
# ARG WINDOWS
# ARG LINUX
# determine which home dir to get -- default is HOME_NIX 
# ARG HOME_DIR='HOME_WIN'
# # if WINDOWS argument is provided, use win home dir
# ARG HOME_DIR="${WINDOWS:+'HOME_WIN'}"
# # if LINUX argument is provided, use nix home dir
# ARG HOME_DIR="${LINUX:+'HOME_NIX'}"
ARG _AGL=${_AGL:-'agl'}
ENV _AGL=$_AGL=${_AGL:-'agl'}
ARG _DVL
ARG CONFIG_FILE
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG _WIN_USER
ARG DOCKER_BUILD_TIMESTAMP
ARG installkernel
USER ${_R00T}
WORKDIR /
COPY --from=dvlp_repo-kernel ./repos/dvlw/dvlp/mnt/HOME_WIN/ ./
COPY --from=dvlp_repo-kernel ./repos/dvlw/ ./repos/kindtek/dvlw/
COPY --from=dvlp_repo-kernel ./repos/dvlw/dvlp/kernels/linux/kache/wsl* ./

# COPY --from=dvlp_repo ./repos/dvlw/dvlp/mnt/${HOME_DIR}/ ./

FROM kindtek/devels-playground:kali-skel AS dvlp_k-home-win-user-mod
ARG _AGL=${_AGL:-'agl'}
ENV _AGL=$_AGL=${_AGL:-'agl'}
ARG CONFIG_FILE
ARG KERNEL_TYPE
ARG KERNEL_FEATURE
ARG CONFIG_FILE
ARG _WIN_USER
ARG DOCKER_BUILD_TIMESTAMP
ARG installkernel
COPY --from=dvlp_k-home-win ./ ./build/
WORKDIR /build
RUN ls -al
RUN head -n -1 KEX-GUI.rdp > KEX-GUI-temp.rdp
RUN rm KEX-GUI.rdp && mv KEX-GUI-temp.rdp KEX-GUI.rdp
RUN echo "username:s:${_AGL}" >> KEX-GUI.rdp
RUN head -n -1 KDE-GUI.rdp > KDE-GUI-temp.rdp
RUN rm KDE-GUI.rdp && mv KDE-GUI-temp.rdp KDE-GUI.rdp
RUN echo "username:s:${_AGL}" >> KDE-GUI.rdp

# add custom user
FROM scratch AS dvlp_k-home-win-user
# # # # TODO: debug COPY --from=dvlp_k-home-win-user-mod ./build/ ./
COPY --from=dvlp_k-home-win ./ ./
