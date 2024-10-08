# ubi-chromium

## Command to build the Containerfile
`podman build -t <image_name> .`

## Command to build the Containerfile.redhat
`podman build -t <image_name> --build-arg RHEL_ORG=<number_here> --build-arg RHEL_AK=<ak_here> -f Containerfile.redhat`

## Command to run the Containerfile and Containerfile.redhat
```
podman run -d -p 6080:6080 -e VNC_PASSWORD=<your_password> -e VNC_GEOMETRY=<default is 1280X800> CHROMIUM_USER_FLAGS="--disable-dev-shm-usage --disable-gpu" --name <container_name> <image_name or id>
```

## Accessing the GUI
`http://localhost:<chosen_published_port>`

## Deploying this solution on Red Hat OpenShift 

The following approach demonstrates how to prepare the Red Hat OpenShift environment to create a UBI container in which you can run a version of chromium.

You need to create a project to isolate the context of this lab. For this example, the project is called **ubi-chromium**.
[image-project]

Next, we will prepare the deployment of our image using the "Import from Git" option.
[image-import-from-git]

The information to be filled in is as follows:

* Git Repo URL: __https://github.com/LeandroJan/ubi-chromium__
* Application: __ubi-chromium-app__
* Name: __ubi-chromium-new__
* Environment variables (Inside Show advanced Deployment option): __VNC_PASSWORD__:__redhat123__
* Target Port: __6080__

Then click Create Button

