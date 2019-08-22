  /*
	Original code from https://po-util.com
	Modified for https://github.com/libc0607/YJSNPI-Broadcast
	set an uart to S.BUS 
	(See https://github.com/uzh-rpg/rpg_quadrotor_control/wiki/SBUS-Protocol)
	
	Usage: 
		setsbus /dev/ttyUSB0
 */
 
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <stropts.h>
#include <asm/termios.h>

int main(int argc, char* argv[]) {

    if (argc != 2) {
        printf("%s device \n\nSet a serial device to S.BUS (b100000,8E2).\nFor instance:\n    %s /dev/ttyUSB0 \n", argv[0], argv[0]);
        return -1;
    }

    int fd = open(argv[1], O_RDONLY);
    int rate = 100000;

    struct termios2 tio;
    ioctl(fd, TCGETS2, &tio);
	// 8bit
	tio.c_cflag &= ~CSIZE;   
	tio.c_cflag |= CS8;
 	// even
	tio.c_cflag &= ~(PARODD | CMSPAR);
    tio.c_cflag |= PARENB;
	// 2 stop bits
	tio.c_cflag |= CSTOPB;	 
	// baud rate
    tio.c_ispeed = rate;
    tio.c_ospeed = rate;
	// other
	tio.c_iflag |= (INPCK|IGNBRK|IGNCR|ISTRIP);
	tio.c_cflag &= ~CBAUD;
    tio.c_cflag |= (BOTHER|CREAD|CLOCAL);

    int r = ioctl(fd, TCSETS2, &tio);

    close(fd);

    if (r == 0) {
        fprintf(stderr, "Set %s to S.BUS port successfully.\n", argv[1]);
    } else {
        perror("ioctl");
    }
}