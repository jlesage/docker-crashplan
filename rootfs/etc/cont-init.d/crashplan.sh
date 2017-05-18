#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure required directories exist.
mkdir -p /config/bin
mkdir -p /config/log
mkdir -p /config/cache
mkdir -p /config/var

# Install default config if needed.
if [ ! -d /config/conf ]
then
  cp -pr $CRASHPLAN_DIR/conf.default /config/conf
fi

# Upgrade existing installation.
if [ -f /config/id/.identity ] && [ ! -f /config/var/.identity ]
then
  cp /config/id/.identity /config/var/.identity
fi

# Install default run.conf if needed.
[ -f /config/bin/run.conf ] || cp $CRASHPLAN_DIR/bin/run.conf.default /config/bin/run.conf

# Clear some log files.
rm -f /config/log/engine_output.log \
      /config/log/engine_error.log \
      /config/log/ui_output.log \
      /config/log/ui_error.log

# Adjust ownership of all files under /config.
chown -R $USER_ID:$GROUP_ID /config

# vim: set ft=sh :
