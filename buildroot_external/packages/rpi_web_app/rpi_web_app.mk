################################################################################
# rpi_web_app.mk - Buildroot package for Raspberry Pi sensors web application
################################################################################

RPI_WEB_APP_VERSION = 1.0
RPI_WEB_APP_SITE = $(TOPDIR)/../rpi_web_app
RPI_WEB_APP_SITE_METHOD = local

RPI_SENSORS_DEPENDENCIES = flask

define RPI_WEB_APP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/app.py $(TARGET_DIR)/usr/share/rpi_web_app/app.py
	$(INSTALL) -D -m 0644 $(@D)/templates/index.html $(TARGET_DIR)/usr/share/rpi_web_app/templates/index.html

	# Create a symlink from /usr/share/rpi_web_app/app.py to /usr/bin/rpi_web_app
    ln -sf $(TARGET_DIR)/usr/share/rpi_web_app/app.py $(TARGET_DIR)/usr/bin/rpi_web_app
endef

$(eval $(generic-package))
