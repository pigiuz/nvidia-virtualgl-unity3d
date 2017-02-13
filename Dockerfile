#Links :
#http://download.unity3d.com/download_unity/unity-editor-installer-5.1.0f3+2015082501.sh
#http://blogs.unity3d.com/2015/08/26/unity-comes-to-linux-experimental-build-now-available/

FROM plumbee/nvidia-virtualgl

MAINTAINER thshaw

RUN apt-get update

WORKDIR unity3d
ARG TAG="5.3.3f1+20160223"
ARG PKG="unity-editor-${TAG}_amd64.deb"
ARG URL="http://download.unity3d.com/download_unity/linux/${PKG}"

ADD ${URL}
#ARG VIDEO_GID

#Resolve missing dependencies
RUN dpkg -i ${PKG} || apt-get -f install -y

#Install unity3d
RUN dpkg -i ${PKG}

# Add the gamedev user
RUN useradd -ms /bin/bash gamedev && \
    chmod 0660 /etc/sudoers && \
    echo "gamedev ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    usermod -aG video gamedev && \
    #groupadd -g ${VIDEO_GID} unity3ddockervideo && \
    groupadd unity3ddockervideo && \
    usermod -aG unity3ddockervideo gamedev

# this is a requirement by chrome-sandbox
RUN chown root /opt/Unity/Editor/chrome-sandbox
RUN chmod 4755 /opt/Unity/Editor/chrome-sandbox

RUN apt-get clean
RUN rm ${PKG}

ADD  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /src/google-chrome-stable_current_amd64.deb

# Install Chromium
RUN mkdir -p /usr/share/icons/hicolor && \
	apt-get update && apt-get install -y \
	ca-certificates \
  	fonts-liberation \
	gconf-service \
	hicolor-icon-theme \
	libappindicator1 \
	libasound2 \
	libcanberra-gtk-module \
	libcurl3 \
  	libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 \
	libexif-dev \
	libgconf-2-4 \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libnspr4 \
	libnss3 \
	libpango1.0-0 \
	libv4l-0 \
  	libxcb1 \
  	libxcb-render0 \
  	libxcb-shm0 \
	libxss1 \
	libxtst6 \
  	mono-complete \
  	monodevelop \
	wget \
	xdg-utils \
	--no-install-recommends && \
	dpkg -i '/src/google-chrome-stable_current_amd64.deb' && \
	rm -rf /var/lib/apt/lists/*

# add audio support
#RUN add-apt-repository -y ppa:mc3man/trusty-media << not needed, running on 16.04
RUN apt-get update
RUN apt-get install -y ffmpeg

USER gamedev
WORKDIR /home/gamedev
ENTRYPOINT ["sudo", "/opt/Unity/Editor/Unity"]
