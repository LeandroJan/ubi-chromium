# ubi-chromium

## Command to build the Containerfile
podman build -t <image_name> .

## Command to build the Containerfile.redhat
podman build -t <image_name> --build-arg RHEL_ORG=<number_here> --build-arg RHEL_AK=<ak_here> -f Containerfile.redhat

## Command to run the Containerfile and Containerfile.redhat
podman run -d -p 6080:6080 -e VNC_PASSWORD=<your_password> -e VNC_GEOMETRY=<default is 1280X800> --name <container_name> <image_name or id>

## Accessing the GUI
http://localhost:<chosen published port>
