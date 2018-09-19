#
# crashplan Dockerfile
#
# https://github.com/jlesage/docker-crashplan
#

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.8-glibc-v3.5.1

# Define software versions.
ARG CRASHPLAN_VERSION=4.8.4
ARG CRASHPLAN_JRE_VERSION=1.8.0_72

# Define software download URLs.
ARG CRASHPLAN_URL=https://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_${CRASHPLAN_VERSION}_Linux.tgz
ARG CRASHPLAN_JRE_URL=http://download.code42.com/installs/proserver/jre/jre-linux-x64-${CRASHPLAN_JRE_VERSION}.tgz

# Define container build variables.
ARG TARGETDIR=/usr/local/crashplan
ARG MANIFESTDIR=/backupArchives

# Define working directory.
WORKDIR /tmp

# Install CrashPlan.
RUN \
    add-pkg --virtual build-dependencies cpio curl && \
    # Download CrashPlan.
    echo "Downloading CrashPlan..." && \
    curl -# -L ${CRASHPLAN_URL} | tar -xz && \
    echo "Installing CrashPlan..." && \
    mkdir -p ${TARGETDIR} && \
    # Extract CrashPlan.
    cat crashplan-install/CrashPlan_${CRASHPLAN_VERSION}.cpi | gzip -d -c - | cpio -i --no-preserve-owner --directory=${TARGETDIR} && \
    # Keep a copy of the default config.
    mv ${TARGETDIR}/conf ${TARGETDIR}/conf.default && \
    # Make sure the UI connects by default to the engine using the loopback IP address (127.0.0.1).
    sed-patch '/<helpNovice>STILL_RUNNING<\/helpNovice>/a \\t<serviceUIConfig>\n\t\t<serviceHost>127.0.0.1<\/serviceHost>\n\t<\/serviceUIConfig>' ${TARGETDIR}/conf.default/default.service.xml && \
     # Set the manifest path (directory for inbound backups).
    sed-patch "s|<backupConfig>|<backupConfig>\n\t\t\t<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf.default/default.service.xml && \
    # Prevent automatic updates.
    rm -r /usr/local/crashplan/upgrade && \
    touch /usr/local/crashplan/upgrade && chmod 400 /usr/local/crashplan/upgrade && \
    # The configuration directory should be stored outside the container.
    ln -s /config/conf $TARGETDIR/conf && \
    # The run.conf file should be stored outside the container.
    cp crashplan-install/scripts/run.conf ${TARGETDIR}/bin/run.conf.default && \
    ln -s /config/bin/run.conf $TARGETDIR/bin/run.conf && \
    # The cache directory should be stored outside the container.
    ln -s /config/cache $TARGETDIR/cache && \
    # The log directory should be stored outside the container.
    rm -r $TARGETDIR/log && \
    ln -s /config/log $TARGETDIR/log && \
    # The '/var/lib/crashplan' directory should be stored outside the container.
    ln -s /config/var /var/lib/crashplan && \
    # Download and install the JRE.
    echo "Downloading and installing JRE..." && \
    curl -# -L ${CRASHPLAN_JRE_URL} | tar -xz -C ${TARGETDIR} && \
    chown -R root:root ${TARGETDIR}/jre && \
    # Cleanup
    del-pkg build-dependencies && \
    rm -rf /tmp/*

# Install dependencies.
RUN \
    add-pkg \
        gtk+2.0 \
        # For the monitor.
        yad \
        bc \
        curl

# Adjust the openbox config.
RUN \
    # Maximize only the main/initial window.
    sed-patch 's/<application type="normal">/<application type="normal" class="CrashPlan">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" class="CrashPlan">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Enable log monitoring.
RUN \
    sed-patch 's|LOG_FILES=|LOG_FILES=/config/log/service.log.0|' /etc/logmonitor/logmonitor.conf && \
    sed-patch 's|STATUS_FILES=|STATUS_FILES=/config/log/app.log|' /etc/logmonitor/logmonitor.conf

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/crashplan-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV S6_WAIT_FOR_SERVICE_MAXTIME=9000 \
    APP_NAME="CrashPlan" \
    KEEP_APP_RUNNING=1 \
    CRASHPLAN_DIR=${TARGETDIR} \
    JAVACOMMON="/usr/local/crashplan/jre/bin/java"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]
VOLUME ["/backupArchives"]

# Expose ports.
#   - 4242: Computer-to-computer connections.
#   - 4243: Connection to the CrashPlan service.
EXPOSE 4242 4243

# Metadata.
LABEL \
      org.label-schema.name="crashplan" \
      org.label-schema.description="Docker container for CrashPlan" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-crashplan" \
      org.label-schema.schema-version="1.0"
