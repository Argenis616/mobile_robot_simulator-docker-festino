# Copyright (c) 2023 Ryohei Kobayashi
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

# https://github.com/ry0hei-kobayashi/mobile_robot_simulator_final-docker by Ryohei Kobayashi. 
# eR@sers JP from Tamagawa Robot Challenge Project

# All source codes were developed by Jesus Savage and Diego Cordero.

###                                             ###
#  Ubuntu18.04, ROS melodic, PyClips, Python2     #
#  With mobile_robot_simulator pkg final version  # 
###                                             ###
 
# For using CPU
FROM ubuntu:18.04 AS mobile_robot_simulator_festiono-cpu
LABEL maintainer="Ryohei Kobayashi <ryohei.kobayashi@okadanet.org>" \
      org.okadanet.dept="TRCP" \
      org.okadanet.version="1.0.0" \
      org.okadanet.released="January 1, 2023"

SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# update and install pkg
RUN apt-get update && apt-get install -y \
    build-essential gcc git vim ssh \
    lsb-core libcgal-qt5-dev libcgal-dev xterm \
    && rm -rf /var/lib/apt/lists/*

# Install ROS Melodic 
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update \
 && apt-get install -y --no-install-recommends ros-melodic-desktop-full
RUN apt-get install -y --no-install-recommends python-rosdep
RUN rosdep init \
 && rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

RUN apt-get install -y python-clips python-tk ros-melodic-turtlebot-* 

# Create an Catkin workspace
RUN source /opt/ros/melodic/setup.bash \
 && mkdir -p /catkin_ws/src \
 && catkin_init_workspace
COPY ./mobile_robot_simulator/start.sh /catkin_ws/
COPY ./mobile_robot_simulator/src /catkin_ws/src/

RUN source /opt/ros/melodic/setup.bash && \
    rosdep update && \
    cd /catkin_ws  &&  \
    /bin/bash -c "source /opt/ros/melodic/setup.bash; catkin_make"
RUN echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Install wine and winetricks
RUN dpkg --add-architecture i386

RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN apt-key add winehq.key
RUN wget -qO- https://dl.winehq.org/wine-builds/Release.key | apt-key add -
RUN apt-get update
RUN apt-get -y install software-properties-common && add-apt-repository 'deb http://dl.winehq.org/wine-builds/ubuntu/ bionic main'

RUN apt-get -y install --install-recommends winehq-devel cabextract mono-complete

# Install audio
RUN apt-get -y install pulseaudio alsa-utils
RUN gpasswd -a root pulse-access


# Set up the work directory and entrypoint
COPY ./ros_entrypoint.sh /
ENTRYPOINT [ "/ros_entrypoint.sh" ]
WORKDIR /catkin_ws

CMD ["/bin/bash"]
