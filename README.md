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

You need to create a project to isolate the context of this lab. For this example, the project is called _ubi-chromium_.

![](images/image-project.jpeg)

Next, we will prepare the deployment of our image using the "Import from Git" option.

![](images/image-import-from-git.png)

The information to be filled in is as follows:

* Git Repo URL: _https://github.com/LeandroJan/ubi-chromium_
* Application: _ubi-chromium-app_
* Name: _ubi-chromium-new_
* Environment variables (Inside Show advanced Deployment option): _VNC_PASSWORD_:_redhat123_
* Target Port: _6080_

Then click Create Button.

After the build completes successfully, the pod icon on the OpenShift screen should be dark blue, and the pod should be in Running status.

![](images/image-pod.png)

When accessing the route assigned to the application service, the noVNC connection screen is displayed.

![](images/image-vnc.png)

Click the Connect button and enter the access password defined previously during the build process. The result should be an environment in which Chromium is running.

![](images/image-chromium.png)

The environment has an integrated xterm terminal so you can run commands on the UBI image.
