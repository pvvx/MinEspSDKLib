/******************************************************************************
 * FileName: user_main.c
 * Test meSDK :)
 *******************************************************************************/

#include "user_config.h"
#include "bios.h"
#include "sdk/add_func.h"
#include "hw/esp8266.h"
#include "user_interface.h"
#include "sdk/rom2ram.h"

/******************************************************************************
 * FunctionName : wifi_handle_event_cb
 * Description  :
 * Parameters   : none
 * Returns      : none
 *******************************************************************************/
void ICACHE_FLASH_ATTR wifi_handle_event_cb(System_Event_t *evt)
{
	int i;
	os_printf("WiFi event %x\n", evt->event);
	switch (evt->event) {
		case EVENT_STAMODE_CONNECTED:
			os_printf("Connect to ssid %s, channel %d\n",
					evt->event_info.connected.ssid,
					evt->event_info.connected.channel);
			break;
		case EVENT_STAMODE_DISCONNECTED:
			os_printf("Disconnect from ssid %s, reason %d\n",
					evt->event_info.disconnected.ssid,
					evt->event_info.disconnected.reason);
			break;
		case EVENT_STAMODE_AUTHMODE_CHANGE:
			os_printf("New AuthMode: %d -> %d\n",
					evt->event_info.auth_change.old_mode,
					evt->event_info.auth_change.new_mode);
			break;
		case EVENT_STAMODE_GOT_IP:
			os_printf("Station ip:" IPSTR ", mask:" IPSTR ", gw:" IPSTR "\n",
					IP2STR(&evt->event_info.got_ip.ip),
					IP2STR(&evt->event_info.got_ip.mask),
					IP2STR(&evt->event_info.got_ip.gw));
			break;
		case EVENT_SOFTAPMODE_STACONNECTED:
			i = wifi_softap_get_station_num(); // Number count of stations which connected to ESP8266 soft-AP
			os_printf("Station[%u]: " MACSTR " join, AID = %d\n",
					i,
					MAC2STR(evt->event_info.sta_connected.mac),
					evt->event_info.sta_connected.aid);
			break;
		case EVENT_SOFTAPMODE_STADISCONNECTED:
			i = wifi_softap_get_station_num();
			os_printf("Station[%u]: " MACSTR " leave, AID = %d\n",
					i,
					MAC2STR(evt->event_info.sta_disconnected.mac),
					evt->event_info.sta_disconnected.aid);
			break;
/*		default:
			break; */
		}
}

/******************************************************************************
 * FunctionName : init_done_cb
 * Description  :
 * Parameters   : none
 * Returns      : none
 *******************************************************************************/
void ICACHE_FLASH_ATTR init_done_cb(void)
{
    os_printf("\nSDK Init - Ok\nCurrent 'heap' size: %d bytes\n", system_get_free_heap_size());
	os_printf("Set CPU CLK: %u MHz\n", ets_get_cpu_frequency());
}

/******************************************************************************
 * FunctionName : user_init
 * Description  : entry of user application, init user function here
 * Parameters   : none
 * Returns      : none
 *******************************************************************************/
void ICACHE_FLASH_ATTR user_init(void) {
	if(eraminfo.size > 0) os_printf("Found free IRAM: base: %p, size: %d bytes\n", eraminfo.base,  eraminfo.size);
	os_printf("System memory:\n");
    system_print_meminfo();
    os_printf("Start 'heap' size: %d bytes\n", system_get_free_heap_size());
	os_printf("Set CPU CLK: %u MHz\n", ets_get_cpu_frequency());
	system_deep_sleep_set_option(0);
	wifi_set_event_handler_cb(wifi_handle_event_cb);
	system_init_done_cb(init_done_cb);
}
