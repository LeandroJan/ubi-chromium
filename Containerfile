# Stage 1: Build stage using CentOS Stream 9 (contribution of imesquit@redhat.com)
FROM quay.io/centos/centos:stream9 AS builder

# Install necessary packages in a single layer
RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y yum-utils && \
    yum config-manager --set-enabled crb && \
    dnf install -y \
        xorg-x11-server-Xorg \
        xorg-x11-xauth \
        xorg-x11-xinit \
        xterm \
        openbox \
        tigervnc-server \
        novnc \
        chromium \
        chromedriver \
        util-linux \
        procps-ng \
        net-tools \
        hostname \
        --nodocs \
        --setopt=install_weak_deps=False \
        --exclude=*.i686 && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Stage 2: Runtime stage using UBI 9
FROM registry.access.redhat.com/ubi9/ubi:latest AS cache

# Backup the original UBI 9 yum repository files
RUN cp -ra /etc/yum.repos.d /etc/yum.repos.d.backup

# Copy necessary files from the builder stage to a temporary directory
COPY --from=builder /usr/bin /usr/bin-temp
COPY --from=builder /usr/lib64 /usr/lib64-temp
COPY --from=builder /usr/libexec /usr/libexec-temp
COPY --from=builder /usr/share /usr/share-temp
COPY --from=builder /etc /etc-temp
COPY --from=builder /usr/lib/python3.9/ /usr/lib/python3.9-temp

# Use cp -rn to avoid overwriting existing files and -a to preserve the all the attributes.
# Restore the original UBI 9 yum repository files
RUN cp -ran /usr/bin-temp/* /usr/bin/ && \
    cp -ran --sparse=always /usr/lib64-temp/* /usr/lib64/ && \
    cp -ran /usr/libexec-temp/* /usr/libexec/ && \
    cp -ran /usr/share-temp/* /usr/share/ && \
    cp -ran /etc-temp/* /etc/ && \
    cp -ran /usr/lib/python3.9-temp/* /usr/lib/python3.9/ && \
    rm -rf  /usr/bin-temp /usr/lib64-temp /usr/libexec-temp /usr/share-temp /etc-temp  /usr/lib/python3.9-temp/ && \
    rm -rf /etc/yum.repos.d && \
    mv /etc/yum.repos.d.backup /etc/yum.repos.d

# Stage 3: Runtime stage using UBI 9
FROM registry.access.redhat.com/ubi9/ubi:latest AS runtime

# Set the password using an environment variable
ENV VNC_PASSWORD=YourSecurePasswordHere

#Set Envs to configure VNC and NOVNC
ENV NOVNC_PORT=6080
ENV DISPLAY=:1
ENV VNC_GEOMETRY=1600x900
ENV VNC_DEPTH=24
ENV NOVNC_PORT=6080

# Set flags for the chromium-browser
ENV CHROMIUM_USER_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage"

# Since inside openshift we can't use /home setting $HOME to /tmp
ENV HOME=/tmp 

# Copy necessary files from the builder stage to a temporary directory
COPY --from=cache /usr/bin /usr/bin
COPY --from=cache /usr/lib64 /usr/lib64
COPY --from=cache /usr/libexec /usr/libexec
COPY --from=cache /usr/share /usr/share
COPY --from=cache /etc /etc
COPY --from=cache /usr/lib/python3.9/ /usr/lib/python3.9/

# Adding the necessary files
RUN systemd-machine-id-setup  && \
    mkdir -p /tmp/.X11-unix && \
    touch /tmp/.Xauthority && \
    chmod 770 /tmp/.Xauthority && \
    mkdir -p /tmp/.config && \
    chgrp -R 0 /tmp/.config && \
    chmod -R g=u /tmp/.config && \
    mkdir -p /tmp/.cache && \
    chgrp -R 0 /tmp/.cache && \
    chmod -R g=u /tmp/.cache

# Expose the VNC port
EXPOSE ${NOVNC_PORT}

# Passing the script to the container
COPY  --chown=1001:0 --chmod=775 startup_chromium.sh /usr/local/bin/startup.sh

# Switch to the non-root user
USER 1001

# Set the default command to run the startup script
CMD ["/usr/local/bin/startup.sh"]