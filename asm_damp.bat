@if exist .\app\.output\eagle\image\eagle.app.v6.out C:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-objdump -S .\app\.output\eagle\image\eagle.app.v6.out > eagle.app.v6.asm
@if exist .\AutoMake\MinEspSDKLib.elf C:\Espressif\xtensa-lx106-elf\bin\xtensa-lx106-elf-objdump -S .\AutoMake\MinEspSDKLib.elf > MinEspSDKLib.asm


