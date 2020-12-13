/*
 * Template? :D
 */

#include "stdint.h"
#include "ets_sys.h"
#include "osapi.h"
#include "os_type.h"

#include "fast_gpio.h"


static volatile os_timer_t timer;

void ICACHE_FLASH_ATTR
blink(void *arg) {
    GPIO2_IN ? GPIO2_L : GPIO2_H;
}

void ICACHE_FLASH_ATTR
user_pre_init() {}

void ICACHE_FLASH_ATTR
user_init()
{
    gpio_init();
    GPIO2_OUTPUT_SET;

    os_timer_setfn(&timer, (os_timer_func_t *)blink, NULL);
    os_timer_arm(&timer, 500, 1);
}
