#!/bin/bash

# Check if there is any device connected via ADB
# If there are no devices connected, connect ADB via USB 

# Start ADB in usb mode
adb usb

sleep 3

# Start scrcpy when phone is connected over USB
/usr/bin/scrcpy --always-on-top --max-fps 60 --stay-awake --window-x 1500 --window-y 90

#adb kill-server
adb shell dumpsys power | grep -w mWakefulness=Asleep
if [ $? -eq 0 ]; then
	adb shell input keyevent 26
fi

sleep 2

adb shell dumpsys power | grep -wE mWakefulness=Awake
if [ $? -eq 0 ]; then
#	adb shell dumpsys bluetooth_manager | grep -q "Mi Smart Band 5"
#	if [ $? -ne 0 ]; then 
	adb shell input swipe 600 600 0 0
	adb shell svc data enable	
	adb shell "am start -n com.android.settings/.TetherSettings"
	adb shell "am start -n com.android.settings/.TetherSettings"
	adb shell input keyevent 20
	adb shell input keyevent 66
fi

/usr/bin/netctl stop-all && \ 
/usr/bin/netctl start wireless-wpa-jio-mita && \
adb tcpip 5555

# ADB does not connect over wifi on the first try, keep trying until the connection over wifi is successful 
while adb connect 192.168.43.1:5555 | grep -qw failed; do
	echo "Connection failed, retrying.."
	adb connect 192.168.43.1:5555
	sleep 2
done

# Start scrcpy
# Use --serial to choose the ADB device connected over wifi
/usr/bin/scrcpy --always-on-top --max-fps 60 --stay-awake --serial 192.168.43.1:5555 --window-x 1500 --window-y 90

