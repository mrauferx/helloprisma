# hellonode
This is a very basic Hello World application written with Node.

It includes a `Dockerfile` for building a Docker image with the application, and a `Jenkinsfile` that defines a build pipeline for it.
The pipeline will check out and build the image, then scan it for vulnerabilities and configuration conformance using either Aqua, NeuVector, or Prisma Cloud.

If the image passes the scan it will be pushed to a local Harbor registry.
The Dockerfile controls the base image to build from; change as needed to illustrate difference in vulnerability findings after scanning.

Credentials for Git, security tools, and registry must be defined in Jenkins.
Jenkins needs to run locally to the registry. Alternatively, change to push to a remote registry such as quay.io.
