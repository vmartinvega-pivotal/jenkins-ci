FROM vmartinvega/jnlp-agent:latest

ARG NO_PROXY=.corp
ARG HTTP_PROXY
ARG MVN_EXTENSION_URL
ARG AGENT_VERSION=vmartinvega/maven-jnlp-agent:latest
ARG AGENT_IMAGE_VERSION=latest

ENV MAVEN_HOME=/usr/share/maven \
    MAVEN_CONFIG="${JENKINS_AGENT_HOME}/.m2" \
    MAVEN_VERSION=3.6.3 \
    MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0 \
    JAVA_11_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    AGENT_VERSION=${AGENT_VERSION}

ENV BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz 

LABEL ALM_DESCRIPTION="Maven Jenkins JNLP Slave docker image" \
    ALM_COMPONENTS="${ALM_COMPONENTS} mvn" \
    ALM_IMAGE_VERSION="$AGENT_IMAGE_VERSION"

USER root

RUN mkdir -p ${MAVEN_HOME}/ref \
  && echo "Downloading maven from ${BASE_URL} ..." \
  && http_proxy=${HTTP_PROXY} https_proxy=${HTTP_PROXY} no_proxy=${NO_PROXY} curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}

RUN echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  && mkdir -p "${MAVEN_CONFIG}" "${MAVEN_HOME}/lib/ext" \
  && chown 1000:1000 "${MAVEN_CONFIG}" "${MAVEN_HOME}/lib/ext"

#Installs jdk-11
RUN apt-get update -y \
  && apt-get install -y openjdk-11-jdk \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
RUN chmod +x /usr/local/bin/mvn-entrypoint.sh
VOLUME [ "${MAVEN_CONFIG}" ]
USER 1000:1000

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]

CMD ["mvn"]