FROM ubuntu:22.04

# 1. Install Java and jq (jq is needed to parse HA options)
ARG _JAVA_OPTIONS
ENV _JAVA_OPTIONS=${_JAVA_OPTIONS}
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    jq \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Work Directory
WORKDIR /home/fdo/

# 3. Create necessary directories
RUN mkdir -p /home/fdo/lib /home/fdo/WEB-INF /home/fdo/app-data

# 4. Copy Files (Assumes you are building from the addon folder where you put these files)
COPY ./lib ./lib/
COPY log4j2.xml .
COPY device.jar .
COPY service.yml .
COPY secrets.run.path /home/fdo/secrets.path

# 5. Copy the startup script and make it executable
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# 6. Start via the script
CMD [ "/run.sh" ]
