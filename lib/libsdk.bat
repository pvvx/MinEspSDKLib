@echo 
if not exist ..\app\sdklib\.output\eagle\lib\libsdk.a goto end
del libsdk120.a
md sdklib
cd sdklib
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\..\app\sdklib\.output\eagle\lib\libsdk.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\libmmain.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\libmphy.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\libmwpa.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\libnet80211.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar xo  ..\libpp.a
c:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-ar ru ..\libsdk120.a *.o
cd ..
rd /q /s sdklib
:end