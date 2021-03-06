# Linux startup script

# For devIocStats
epicsEnvSet("ENGINEER", "${USER=Raspberry Pi}")
epicsEnvSet("LOCATION", "${IP_ADDR=LAN}")
epicsEnvSet("GROUP",    "ioc_raspi_sensors")

< envPaths
epicsEnvSet("PREFIX", "${PV_PREFIX=raspi:}")

# save_restore.cmd needs the full path to the startup directory, which
# envPaths currently does not provide
epicsEnvSet(STARTUP,$(TOP)/iocBoot/$(IOC))

# Increase size of buffer for error logging from default 1256
errlogInit(20000)

# Specify largest array CA will transport
# Note for N doubles, need N*8 bytes+some overhead
epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 64010

################################################################################
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in the software we just loaded (raspi.munch)
dbLoadDatabase("../../dbd/iocraspiLinux.dbd")
iocraspiLinux_registerRecordDeviceDriver(pdbbase)


# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=$(PREFIX)")


# DHT22 humidity & temperature sensor on wiringPi pin 0
dbLoadRecords("$(TOP)/db/dht22.db", "P=$(PREFIX),C=0")
#doAfterIocInit("seq dht22_seq, 'name=dht22_0,P=$(PREFIX),C=0'")

###############################################################################
iocInit
###############################################################################

# write all the PV names to a local file
dbl > dbl-all.txt

seq dht22_seq, "name=dht22_0,P=$(PREFIX),C=0"

# print the time our boot was finished
date

