# Stage 1: Build stage using AlmaLinux
FROM almalinux:latest AS builder

# Install necessary packages in a single layer
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y yum-utils && \
    yum config-manager --set-enabled crb && \
    yum install -y \
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
        procps \
        net-tools \
        hostname \
        --nodocs \
        --setopt=install_weak_deps=False \
        --exclude=*.i686 && \
    yum clean all && \
    rm -rf /var/cache/yum

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

# Use cp -rn to avoid overwriting existing files and -a to preserve the all the attributes
RUN cp -ran /usr/bin-temp/* /usr/bin/ && \
    cp -ran --sparse=always /usr/lib64-temp/* /usr/lib64/ && \
    cp -ran /usr/libexec-temp/* /usr/libexec/ && \
    cp -ran /usr/share-temp/* /usr/share/ && \
    cp -ran /etc-temp/* /etc/ && \
    cp -ran /usr/lib/python3.9-temp/* /usr/lib/python3.9/ && \
    rm -rf  /usr/bin-temp /usr/lib64-temp /usr/libexec-temp /usr/share-temp /etc-temp  /usr/lib/python3.9-temp/

# Restore the original UBI 9 yum repository files
RUN rm -rf /etc/yum.repos.d && \
    mv /etc/yum.repos.d.backup /etc/yum.repos.d

# Stage 3: Runtime stage using UBI 9
FROM registry.access.redhat.com/ubi9/ubi:latest AS runtime

# Set the password using an environment variable
ENV VNC_PASSWORD=YourSecurePasswordHere

#Set Envs configurable through 'podman run' 
ENV NOVNC_PORT=6080
ENV DISPLAY=:1
ENV VNC_GEOMETRY=1280x800
ENV VNC_DEPTH=24
ENV NOVNC_PORT=6080

# Set flags for the chromium-browser
ENV CHROMIUM_USER_FLAGS=""

# Copy necessary files from the builder stage to a temporary directory
COPY --from=cache /usr/bin /usr/bin
COPY --from=cache /usr/lib64 /usr/lib64
COPY --from=cache /usr/libexec /usr/libexec
COPY --from=cache /usr/share /usr/share
COPY --from=cache /etc /etc
COPY --from=cache /usr/lib/python3.9/ /usr/lib/python3.9/

# Crea te username chromiumuser and set permissions
RUN useradd -m chromiumuser && \
    mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    touch /home/chromiumuser/.Xauthority && \
    chown chromiumuser:chromiumuser /home/chromiumuser/.Xauthority && \
    mkdir -p /home/chromiumuser/.dbus && \
    chown -R chromiumuser:chromiumuser /home/chromiumuser/.dbus && \
    mkdir -p /home/chromiumuser/.config/openbox && \
    chown -R chromiumuser:chromiumuser /home/chromiumuser/.config/openbox && \
    mkdir -p /home/chromiumuser/.cache && \
    chown -R chromiumuser:chromiumuser /home/chromiumuser/.cache && \
    chown -R chromiumuser:chromiumuser /home/chromiumuser/.config && \
    systemd-machine-id-setup 

# Passing the script to the container
COPY --chown=chromiumuser:chromiumuser --chmod=755 startup_chromium.sh /home/chromiumuser/startup.sh

# Switch to the non-root user 'chromiumuser'
USER chromiumuser

# Expose the VNC port
EXPOSE ${NOVNC_PORT}

# Set the default command to run the startup script
CMD ["/home/chromiumuser/startup.sh"]