####### This is a multi-stage build ######
####### Below is for building app ########
# switch node base image for good / bad build - newer = good
FROM node:18.10.0-alpine3.16 AS installer
#FROM node:23.10.0-alpine3.21 AS installer

# copy application into container
COPY app/* /app/

# set the working directory to our app directory
WORKDIR /app

# build app
# switch -g npm@11.2.0 for good / bad build
RUN npm install --omit=dev --unsafe-perm && \
    npm dedupe 
#RUN npm install -g npm@11.2.0 --omit=dev --unsafe-perm && \
#    npm dedupe 

####### Below is for building image ########
# switch node base image for good / bad build - newer = good
FROM node:18.10.0-alpine3.16
#FROM node:23.10.0-alpine3.21

# Arguments for use in image build
ARG USER=simple
ARG UID=1001
ARG GID=1001

# create directory for application
#RUN mkdir -p /app

# set the working directory to our app directory
WORKDIR /app

# using alpine
RUN addgroup --system --gid ${GID} ${USER} && \
    adduser ${USER} --system --uid ${UID} --ingroup ${USER}
# using Red Hat
#RUN groupadd --system --gid ${GID} ${USER} && \
#    useradd ${USER} --system --uid ${UID} --gid ${USER}

# copy built app into image
COPY --from=installer --chown=${USER} /app .

## see if this solves Error: EACCES: permission denied, mkdir '/home/simple' problem with npm
# using Red Hat
#RUN mkdir /home/${USER} && \
#	chown ${USER} /home/${USER}
RUN	chown ${USER} /app

# Remove any setuid or setgid bits from files to avoid permission elevation
RUN find / -xdev -perm /6000 -type f -exec chmod a-s {} \; || true

# set run user to not run as root
USER ${UID}

# set a health check
HEALTHCHECK --interval=30s \
            --timeout=5s \
            --retries=3 \
            CMD curl -f http://127.0.0.1:8000 || exit 1

# tell docker what port to expose
EXPOSE 8000

# tell docker what command to run when container is run
#CMD npm start
CMD ["npm", "start"]

