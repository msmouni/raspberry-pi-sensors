################################################################################
# rpi_sensors.mk - Buildroot package for Raspberry Pi sensors
################################################################################

RPI_SENSORS_VERSION = custom
RPI_SENSORS_SITE = $(TOPDIR)/../rpi_sensors
RPI_SENSORS_SITE_METHOD = local

RPI_SENSORS_DEPENDENCIES = sqlite

define RPI_SENSORS_BUILD_CMDS
	$(MAKE) -C $(@D) \
	    CC="$(TARGET_CC)" \
	    CFLAGS="$(TARGET_CFLAGS)" \
	    LDFLAGS="$(TARGET_LDFLAGS)"
endef

define RPI_SENSORS_INSTALL_TARGET_CMDS
	# Create writable directory for the DB
	mkdir -p $(TARGET_DIR)/var/lib/rpi_sensors_data
	
	$(INSTALL) -D -m 0755 $(@D)/build/bin/rpi_sensors $(TARGET_DIR)/usr/bin/rpi_sensors
endef

$(eval $(generic-package))
