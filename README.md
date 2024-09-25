# ubi-chromium

## Install VNC Viewer
https://www.realvnc.com/pt/connect/download/viewer/

## Command to build the container 
podman build -t <image_name> .
## Command to run the container
podman run -d  -p 5901:5901 --shm-size=2g  -e VNC_PASSWORD=<your_password> --name <container_name> <container_image>
## Accessing the GUI
Inside the VNC cliente put the address 'localhost:5901' (or other published port).

