
[![Build Status](https://travis-ci.org/IBM/kubernetes-cobol.svg?branch=master)](https://travis-ci.org/IBM/kubernetes-cobol)

# Running COBOL on a Kubernetes cluster

In this code pattern, we will build a Docker container with a simple hello world COBOL application using Kubernetes and Docker. We will build a Docker container locally, test it, push it to a registry, then pull it down to a remote Kubernetes cluster expecting our output.

When you have completed this code pattern, you will understand how to:

* Build Docker containers locally
* Test a basic Docker container
* Push a Docker container to a remote registry
* Configure Kubernetes to pull from a remote registry and run a COBOL Hello World Application

# Steps

1. [Install Docker Community Edition](#1-install-docker-community-edition).
2. [Clone the Repository Locally](#2-clone-the-repository-locally).
3. [Install IBM Cloud CLI](#3-install-ibm-cloud-cli).
4. [Create your namespace](#4-create-your-namespace).
5. [Build your COBOL container](#5-build-your-cobol-container).
6. [Test your COBOL container locally](#6-test-your-cobol-container-locally).
7. [Create and connect to IBM Cloud Kubernetes cluster](#7-create-and-connect-to-ibm-cloud-kubernetes-cluster).
8. [Run a job on Kubernetes](#8-run-a-job-on-kubernetes).

### 1. Install Docker Community Edition

First install the Docker-CE edition on your local workstation. There are two main editions of Docker, I’d like to take a moment to discuss the different versions here. First there is Docker Community Edition, or `docker-ce`, and Docker Enterprise Edition, or `docker-ee`. They both have advantages and are aimed at different use cases. I strongly suggest after walking through the documentation [here](https://docs.docker.com/install/overview/) to verify that Docker-CE is the correct one for your use case.

Some of the further steps require that `docker` command do NOT use `sudo` preface, which is the default behavior after installation. To do so, log in as root user or follow the optional installations steps [here](https://docs.docker.com/engine/install/linux-postinstall/).

### 2. Clone the repository locally

Clone down this `git` repository on your local workstation.

```bash
$ git clone https://github.com/IBM/kubernetes-cobol
```

### 3. Install IBM Cloud CLI

Before continue, make sure you have an active IBM Cloud account, as well as you have the IBM Cloud CLI already working in your shell. To learn more about IBM Cloud Container Registry and sign up for an IBM Cloud account, visit [website](https://www.ibm.com/cloud/container-registry). To install the IBM CLoud CLI, follow these [instructions](https://cloud.ibm.com/docs/cli?topic=cloud-cli-getting-started).

### 4. Create your namespace

Next create a `namespace` in IBM Cloud Container Registry to store your Docker images. Log into IBM Cloud via the CLI, then run the following commands. We are going to call our container registry `namespace` "docker_cobol" as our example.

**NOTE**: `docker_cobol` is a universal namespace, you will need to change it so SOMETHING ELSE for you. I suggest maybe your first name and `docker_cobol` for instance `jj_docker_cobol` in my case.

```bash
$ ibmcloud login
$ ibmcloud cr namespace-add docker_cobol
$ ibmcloud cr namespace-list | grep docker_cobol # a sanity check to make sure it was created correctly
```

### 5. Build your COBOL container

Build the Docker container on your local workstation. This will require a few steps. We will walk you through each. First change the directory of `docker/`. You'll want build your container and tag it with a meaningful tag. Using the IBM Cloud registry, you can build the container and also push it to a registry in one command. We are going to use the `namespace` that we created above, and call the container `hello_world` and label it with `v1`.

```bash
$ cd docker/
$ ibmcloud cr login
$ ibmcloud cr build --tag us.icr.io/docker_cobol/hello_world:v1 ./
Sending build context to Docker daemon   2.56kB
Step 1/11 : FROM centos:latest
latest: Pulling from library/centos
8ba884070f61: Pull complete
Digest: sha256:8d487d68857f5bc9595793279b33d082b03713341ddec91054382641d14db861
Status: Downloaded newer image for centos:latest
 ---> 9f38484d220f
Step 2/11 : ENV GMP_VERSION=6.0.0
 ---> Running in 2fb58cad59c6
Removing intermediate container 2fb58cad59c6
 ---> fdbd9fe6be02
Step 3/11 : ENV GNU_COBOL=1.1
 ---> Running in 31dc23ee79b3
Removing intermediate container 31dc23ee79b3
 ---> 96ad047e4fd5

[-- snip --]

The push refers to repository [us.icr.io/docker_cobol/hello_world]
f3eaacc5c5c1: Pushed
cdf3deb1ef52: Pushed
98290c1d657b: Pushed
438a70293769: Pushed
166cbcd2bc5d: Pushed
cc201d7335e0: Pushed
d69483a6face: Pushed
v1: digest: sha256:9dac5ddf1210b899bf3fd75e263bc5a5854ade2141ec2abb6f3e6bf5c59b3539 size: 1785
$
```

### 6. Test your COBOL container locally

After a successful build, lets test it out on our local machine. Go ahead and run the following command to pull from your local `namespace` and run it on your local workstation.

```bash
$ ibmcloud cr login # incase you haven't already
$ docker run us.icr.io/docker_cobol/hello_world:v1   # remember to type in the correct namespace previously created
Unable to find image 'us.icr.io/docker_cobol/hello_world' locally
v1: Pulling from docker_cobol/hello_world
8ba884070f61: Pull complete
e48b6497387f: Pull complete
28037863ba49: Pull complete
94e07aff83de: Pull complete
be35421f2508: Pull complete
70ced04e9e75: Pull complete
92cce9b2c928: Pull complete
Digest: sha256:9dac5ddf1210b899bf3fd75e263bc5a5854ade2141ec2abb6f3e6bf5c59b3539
Status: Downloaded newer image for us.icr.io/docker_cobol/hello_world:v1
Hello world!
```

Now that we have the container on our local workstation, lets run some tests against it. We'll be using some software called [InSpec](https://inspec.io). Go ahead and install the software from the official page. After that, change directory into the `inspec/` directory and edit `01-docker.rb` file in order to replace "docker_cobol" by the correct `namespace` previously created.

```bash
$ cd inspec/
$ nano 01-docker.rb   # inside the file, replace "docker_cobol" example namespace by the namespace previously created
$ inspec exec 01-docker.rb
Profile: tests from 01-docker.rb (tests from 01-docker.rb)
Version: (not specified)
Target:  local://

  #<Inspec::Resources::DockerImageFilter:0x0000000004c47cd8> with repository == "ubuntu" tag == "12.04"
     ✔  should not exist
  #<Inspec::Resources::DockerImageFilter:0x0000000004c5ccf0> with repository == "us.icr.io/docker_cobol/hello_world" tag == "v1"
     ✔  should exist
  Command: `docker run us.icr.io/docker_cobol/hello_world:v1`
     ✔  stdout should eq "Hello world!\n"
     ✔  stderr should eq ""
     ✔  exit_status should eq 0

Test Summary: 5 successful, 0 failures, 0 skipped
$
```

There are a many tests you can write and very your Docker containers here, I suggest taking a look at the official documentation [here](https://www.inspec.io/docs/reference/resources/docker/). We have a few tests in the `01-docker.rb` file I'd check it to see the a few options for some sanity checks.


### 7. Create and connect to IBM Cloud Kubernetes cluster

If we now have some successful building on the IBM Cloud, running the output to see `Hello World!` We need to request a IBM Cloud Kubernetes cluster. Run the following commands to request it. You can run a "free tier" cluster here for this code pattern. This will take a few minutes, and check the status by the second command.

```bash
$ ibmcloud ks cluster create classic --name cobol_docker
$ ibmcloud ks clusters | grep cobol_docker
```

When the cluster is complete and in `normal` state, we can connect to it. You can connect to in via the following commands, and run the second command as a sanity check.

```bash
$ ibmcloud ks cluster config --cluster cobol_docker
OK
The configuration for cobol_docker was downloaded successfully.

Added context for cobol_docker to the current kubeconfig file.
You can now execute 'kubectl' commands against your cluster. For example, run 'kubectl get nodes'.
$ kubectl get nodes
NAME            STATUS    ROLES     AGE       VERSION
10.186.59.93    Ready     <none>    1d      v1.16.9+IKS
```

Now that you have your cluster and your container build on the IBM Cloud Container Registry we should create some keys to allow for our Kubernetes cluster to call into the Registry and request our build.

```bash
$ ibmcloud iam service-id-create docker_cobol-service-id --description "COBOL Kubernetes service"
$ ibmcloud iam service-policy-create docker_cobol-service-id --roles Manager --service-name container-registry
$ ibmcloud iam service-api-key-create docker_cobol-api-key docker_cobol-service-id --description "API key for COBOL Kubernetes service"
#
# Take note of the API Key created and put it as <API_Key> in the following command
#
$ kubectl create secret docker-registry docker-cobol-registry-secret \
  --docker-server=us.icr.io \
  --docker-username=iamapikey \
  --docker-password=<API_Key> \
  --docker-email=null
```

### 8. Run a job on Kubernetes

Next change directory to the `job` directory, and open up the `job.yml`. You should see the `docker_cobol` and you need to edit it to your `namespace`. After this you will want to apply your batch job.

```bash
$ cd job/
$ nano job.yml   # remember to replace docker_cobol by the namespace previously created
$ kubectl apply -f job.yml
job.batch/cobol-docker-job created
```

Finally to verify your deployment you will want to run the following to see the `Hello World!`. The easiest way would be to run the following commands to see the pod `Completed` then run the `logs` command to verify that it has the out put we are expecting.

```bash
$ kubectl get pods
NAME                                  READY     STATUS      RESTARTS   AGE
cobol-docker-job-mlggk                0/1       Completed   0          40s
$ kubectl logs cobol-docker-job-mlggk
Hello World!
```

# Troubleshooting

### I had an error message saying that it is unable to find resource 'us.icr.io/docker_cobol/hello_world'

Make sure you replace "docker_cobol" by your own `namespace` as discussed in the section [Create your namespace](#4-create-your-namespace).
If the error persists, it may be related to version divergence (e.g.`Unable to find image 'us.icr.io/docker_cobol/hello_world:latest'`). In the last case, try to explicitly mention ":v1" after the resource name:

```bash
$ docker run us.icr.io/docker_cobol/hello_world:v1
```


<!-- keep this -->
## License

This code pattern is licensed under the Apache License, Version 2. Separate third-party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/) and the [Apache License, Version 2](https://www.apache.org/licenses/LICENSE-2.0.txt).

[Apache License FAQ](https://www.apache.org/foundation/license-faq.html#WhatDoesItMEAN)
