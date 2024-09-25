# ubi-chromium
# Command to build the container 
podman build -t <image_name> .
# Command to run the container
podman run -d  -p 5901:5901 --shm-size=2g  -e VNC_PASSWORD=<your_password> --name <container_name> <container_image>
