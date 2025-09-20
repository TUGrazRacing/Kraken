/*
 * main.c
 *
 *  Created on: 19. Sep. 2025
 *      Author: Jakob
 */


#include "system.h"
#include "stdio.h"
#include "unistd.h"
#include "altera_avalon_pio_regs.h"

int main(void)
{



	while(1)
	{
		printf("Hello World\n");
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 0x1);
		usleep(500000);
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 0x0);
		usleep(500000);
	}


	return 0;
}
