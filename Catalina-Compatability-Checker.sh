#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Copyright (c) 2019 Jamf.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the Jamf nor the names of its contributors may be
#                 used to endorse or promote products derived from this software without
#                 specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# This script was designed to be used as an Extension Attribute to ensure specific
# requirements have been met to deploy macOS Catalina.
#
# General Requirements:
# 	- OS X 10.9.0 or later
# 	- 4GB of memory
# 	- 12.5GB of available storage if upgrading from OS X 10.11.5 (up to 18.5GB if upgrading from an earlier release)
#
# These last 2 requirements can be modified in the first 2 variables (MINIMUMRAM
# and MINIMUMSPACE).
# 	- REQUIREDMINIMUMRAM: minimum RAM required, in GB
# 	- REQUIREDMINIMUMSPACE: minimum disk space available, in GB
#
#
# Mac Hardware Requirements and equivalent as minimum Model Identifier
# 	- MacBook (Early 2015 or newer), ie MacBook8,1
# 	- MacBook Pro (Mid 2012 or newer), ie MacBookPro9,1
# 	- MacBook Air (Mid 2012 or newer), ie MacBookAir5,1
# 	- Mac mini (Late 2012 or newer), ie Macmini6,1
# 	- iMac (Late 2012 or newer), ie iMac13,1
# 	- iMac Pro, ie iMacPro1,1
# 	- Mac Pro (Late 2013 or newer), ie MacPro6,1
#
#
# Default compatibility is set to False if no test pass (variable COMPATIBILITY)
#
# Written by: Laurent Pertois | Senior Professional Services Engineer | Jamf
#
# Created On: 2017-09-18
# Modified On: 2018-12-19 (minor changes reported by @sdpalmer)
# Modified On: 2019-12-28 (updated for macOS Catalina by Andrew Needham)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# Minimum RAM and Disk Space required (4GB and 18.5GB default. Note that REQUIREDMINIMUMSPACE must be set to an integer)
REQUIREDMINIMUMRAM=4
REQUIREDMINIMUMSPACE=19

#########################################################################################
############### DO NOT CHANGE UNLESS NEEDED
#########################################################################################

# Default values for Compatibility is false
COMPATIBILITY="False"

#########################################################################################
############### Let's go!
#########################################################################################

# Checks minimum version of the OS before upgrade (10.9.0)
OSVERSIONMAJOR=$(sw_vers -productVersion | awk -F"." '{ print $2 }')
OSVERSIONMINOR=$(sw_vers -productVersion | awk -F"." '{ print $3 }')

# Checks if computer meets pre-requisites for Mojave
if [[ "$OSVERSIONMAJOR" -ge 9 && "$OSVERSIONMAJOR" -le 15 ]]; then

	# Transform GB into Bytes
	GIGABYTES=$((1024 * 1024 * 1024))
	MINIMUMRAM=$(($REQUIREDMINIMUMRAM * $GIGABYTES))
	MINIMUMSPACE=$(($REQUIREDMINIMUMSPACE * $GIGABYTES))

	# Gets the Model Identifier, splits name and major version
	MODELIDENTIFIER=$(/usr/sbin/sysctl -n hw.model)
	MODELNAME=$(echo "$MODELIDENTIFIER" | sed 's/[^a-zA-Z]//g')
	MODELVERSION=$(echo "$MODELIDENTIFIER" | sed 's/[^0-9,]//g' | awk -F, '{print $1}')

	# Gets amount of memory installed
	MEMORYINSTALLED=$(/usr/sbin/sysctl -n hw.memsize)

	# Gets free space on the boot drive
	FREESPACE=$(diskutil info / | awk -F'[()]' '/Free Space|Available Space/ {print $2}' | sed -e 's/\ Bytes//')

	# Checks if computer meets pre-requisites for Catalina
	if [[ "$MODELNAME" == "iMac" && "$MODELVERSION" -ge 13 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
		COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "iMacPro" && "$MODELVERSION" -ge 1 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
		COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "Macmini" && "$MODELVERSION" -ge 6 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
		COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "MacPro" && "$MODELVERSION" -ge 6 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
	    COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "MacBook" && "$MODELVERSION" -ge 8 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
	    COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "MacBookAir" && "$MODELVERSION" -ge 5 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
	    COMPATIBILITY="True"
	elif [[ "$MODELNAME" == "MacBookPro" && "$MODELVERSION" -ge 9 && "$MEMORYINSTALLED" -ge "$MINIMUMRAM" && "$FREESPACE" -ge "$MINIMUMSPACE" ]]; then
	    COMPATIBILITY="True"
	fi
	# Outputs result
	echo "<result>$COMPATIBILITY</result>"
else
	echo "<result>$COMPATIBILITY</result>"
	exit $?
fi
