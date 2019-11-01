/*
	This program is from https://zhoujianshi.github.io/articles/2017/Linux%E4%B8%B2%E5%8F%A3%E7%BD%91%E5%8D%A1%EF%BC%88%E4%BA%8C%EF%BC%89%E2%80%94%E2%80%94%E7%94%A8%E6%88%B7%E6%80%81%E8%BD%AC%E5%8F%91%E7%A8%8B%E5%BA%8F%E7%9A%84%E5%AE%9E%E7%8E%B0/index.html
	(in Chinese)
	Thanks to his great work.
	This program should working with kmod-eth-uart.
	
	Dirty mod by Github @libc0607:
	0. Remove the zh-cn comments in the original code. 
		If you want to see how it works, see the link above.
	1. Use libiniparser to get UART settings.
	
	Usage:
	eth-uart ./config.ini
	
	config.ini:
	
	[PROGRAM_NAME]
	uart=/dev/ttyUSB0			# uart port
	proc=/proc/eth_uart/uio		# proc file created by kmod-eth-uart
	baud=115200					# baud rate for both tx/rx
	datab=8						# data bits, 5/6/7/8
	stopb=1						# stop bits, 1/2
	pareb=0						# parity check, 0-none, 1-odd, 2-even

*/

#include <fcntl.h>
#include <iniparser.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>
#include <termios.h>
#include <unistd.h>

#define PROGRAM_NAME eth-uart

int open_uart(dictionary* ini)
{
    struct termios options;
	int param_baud, param_datab, param_stopb, param_pareb;
	char * param_uart;
	char error[1024];
	
	param_baud = iniparser_getint(ini, "PROGRAM_NAME:baud", 0);
	param_datab = iniparser_getint(ini, "PROGRAM_NAME:datab", 0);
	param_stopb = iniparser_getint(ini, "PROGRAM_NAME:stopb", 0);
	param_pareb = iniparser_getint(ini, "PROGRAM_NAME:pareb", 0);
	param_uart = (char *)iniparser_getstring(ini, "PROGRAM_NAME:uart", NULL);

	int fd = open(param_uart, O_RDWR | O_NOCTTY | O_NDELAY);
    if(fd < 0)
    {
        sprintf(error, "<eth_uart> open('%s') failed!\n", param_uart);
        goto err;
    }
    
	// get exist option
	memset(&options, 0, sizeof(options));
	if (tcgetattr(fd, &options) != 0) {  
		printf("tcgetattr() failed. Use new options.\n");
		memset(&options, 0, sizeof(options));
	}
	
	switch (param_baud) {
	case 2400: 
		cfsetispeed(&options, B2400);
		cfsetospeed(&options, B2400);
		break;
	case 4800: 
		cfsetispeed(&options, B4800);
		cfsetospeed(&options, B4800);
		break;
	case 9600: 
		cfsetispeed(&options, B9600);
		cfsetospeed(&options, B9600);
		break;
	case 19200: 
		cfsetispeed(&options, B19200);
		cfsetospeed(&options, B19200);
		break;
	case 38400: 
		cfsetispeed(&options, B38400);
		cfsetospeed(&options, B38400);
		break;
	case 57600: 
		cfsetispeed(&options, B57600);
		cfsetospeed(&options, B57600);
		break;
	case 115200: 
		cfsetispeed(&options, B115200);
		cfsetospeed(&options, B115200);
		break;
	case 230400: 
		cfsetispeed(&options, B230400);
		cfsetospeed(&options, B230400);
		break;
	case 460800: 
		cfsetispeed(&options, B460800);
		cfsetospeed(&options, B460800);
		break;
	case 576000: 
		cfsetispeed(&options, B576000);
		cfsetospeed(&options, B576000);
		break;
	case 921600: 
		cfsetispeed(&options, B921600);
		cfsetospeed(&options, B921600);
		break;	
	default:
		printf("<eth_uart> uart baud rate %d not supported - do not set. \n", param_baud);
	//	cfsetispeed(&options, B9600);
	//	cfsetospeed(&options, B9600);
		break;
	}

	switch (param_datab) {
	case 5:
		options.c_cflag |= CS5;
		break;
	case 6:
		options.c_cflag |= CS6;
		break;
	case 7:
		options.c_cflag |= CS7;
		break;
	case 8:
		options.c_cflag |= CS8;
		break;
	default: 
		printf("<eth_uart> uart data bits %d not supported - do not set. \n", param_datab);
		//options.c_cflag |= CS8;
		break;
	}
   
    switch (param_stopb) {
	case 1:
		options.c_cflag &= ~CSTOPB;
		break;
	case 2:
		options.c_cflag |= CSTOPB;
		break;
	default:
		printf("<eth_uart> uart stop bits %d not supported - do not set. \n", param_stopb);
		//options.c_cflag &= ~CSTOPB;
		break;
	}
	
	switch (param_pareb) {
	case 0:
		// none
		options.c_cflag &= ~PARENB;
		break;
	case 1:
		// odd
		options.c_cflag |= PARENB; 
		options.c_cflag |= PARODD; 
		options.c_iflag |= (INPCK | ISTRIP);
		break;
	case 2:
		// even
		options.c_iflag |= (INPCK | ISTRIP); 
		options.c_cflag |= PARENB; 
		options.c_cflag &= ~PARODD; 
	default:
		// none		
		printf("<eth_uart> uart parity bits %d not supported - do not set. \n", param_pareb);
		//options.c_cflag &= ~PARENB;
		break;
	}
	
	options.c_cc[VTIME] = 0;
	options.c_cc[VMIN] = 1;
	
    if(tcsetattr(fd, TCSANOW, &options) != 0)
    {
        strcpy(error, "<eth_uart> tcsetattr() failed!\n");
        goto err;
    }
    if(tcflush(fd, TCIOFLUSH) != 0)
    {
        strcpy(error, "<eth_uart> tcflush() failed!\n");
        goto err;
    }
    return fd;
    err:
        if(fd > 0)
            close(fd);
        printf("%s", error);
        return -1;
}

int init(dictionary* ini, int* fds)
{
    char error[1024];
    int eth_fd, uart_fd;
	char * param_proc;
	
	param_proc = (char *)iniparser_getstring(ini, "PROGRAM_NAME:proc", NULL);
	eth_fd = open(param_proc, O_RDWR);
    if(eth_fd < 0)
    {
        sprintf(error, "<eth_uart> open('%s') failed!\n", param_proc);
        goto err_1;
    }
    if(fcntl(eth_fd, F_SETFL, fcntl(eth_fd, F_GETFL, 0) | O_NONBLOCK) < 0)
    {
        strcpy(error, "<eth_uart> fcntl(eth, O_NONBLOCK) failed!\n");
        goto err_2;
    }
	
	uart_fd = open_uart(ini);
    if(uart_fd < 0)
    {
        strcpy(error, "");
        goto err_2;
    }
    fds[0] = eth_fd;
    fds[1] = uart_fd;
    return 0;
    err_2:
        close(eth_fd);
    err_1:
        ;
        printf("%s\n", error);
        return -1;
}

int main_routine(int eth_fd, int uart_fd, int max_buf)
{
    char error[1024];
    uint8_t to_send[max_buf];
    int to_send_len = 0;
    int sent_len = 0;
    uint8_t recving[max_buf];
    int recving_len = 0;
    int is_escape = 0;
	
    while(1)
    {
        int can_eth_read = 0, can_uart_read = 0, can_uart_write = 0;
        if(to_send_len == 0)
        {
            fd_set rds;
            FD_ZERO(&rds);
            FD_SET(eth_fd, &rds);
            FD_SET(uart_fd, &rds);
            if(select((eth_fd > uart_fd ? eth_fd : uart_fd) + 1, &rds, 0, 0, 0) < 0)
            {
                strcpy(error, "<eth_uart> select(eth + uart, READ) error!\n");
                goto err;
            }
            can_eth_read = FD_ISSET(eth_fd, &rds);
            can_uart_read = FD_ISSET(uart_fd, &rds);
        }
        else
        {
            fd_set rds;
            FD_ZERO(&rds);
            FD_SET(uart_fd, &rds);
            fd_set wrs;
            FD_ZERO(&wrs);
            FD_SET(uart_fd, &wrs);
            if(select(uart_fd + 1, &rds, &wrs, 0, 0) < 0)
            {
                strcpy(error, "<eth_uart> select(uart, READ + WRITE) error!\n");
                goto err;
            }
            can_uart_read = FD_ISSET(uart_fd, &rds);
            can_uart_write = FD_ISSET(uart_fd, &wrs);
        }
        if(can_eth_read)
        {
            uint8_t frame[max_buf];
            int len = read(eth_fd, frame, max_buf);
            if(len == 0)
                continue;
            if(len < 0)
            {
                sprintf(error, "<eth_uart> read(eth) == %d!\n", len);
                goto err;
            }
            else if(len > max_buf / 2)
            {
                sprintf(error, "<eth_uart> read(eth) == %d, too long!\n", len);
                goto err;
            }
            to_send[to_send_len++] = 255;
            to_send[to_send_len++] = 0;
            for(int i = 0; i < len; i++)
            {
                to_send[to_send_len++] = frame[i];
                if(frame[i] == 255)
                    to_send[to_send_len++] = 255;
            }
            to_send[to_send_len++] = 255;
            to_send[to_send_len++] = 1;
        }
        else if(can_uart_read)
        {
            uint8_t encoded[max_buf];
            int len = read(uart_fd, encoded, max_buf);
            if(len < 0)
            {
                sprintf(error, "<eth_uart> read(uart) == %d!\n", len);
                goto err;
            }
            for(int i = 0; i < len; i++)
            {
                uint8_t abyte = encoded[i];
                if(is_escape)
                {
                    if(abyte == 0)
                        recving_len = 0;
                    else if(abyte == 1)
                    {
                        if(write(eth_fd, recving, recving_len) != recving_len)
                        {
                            sprintf(error, "<eth_uart> write(eth, %d) != %d!\n", recving_len, recving_len);
                            goto err;
                        }
                    }
                    else
                        recving[recving_len++] = abyte;
                    is_escape = 0;
                }
                else
                {
                    if(encoded[i] == 255)
                        is_escape = 1;
                    else
                        recving[recving_len++] = abyte;
                }
                if(recving_len == max_buf)
                {
                    strcpy(error, "<eth_uart> too big frame!\n");
                    goto err;
                }
            }
        }
        else if(can_uart_write)
        {
            int sz = write(uart_fd, to_send + sent_len, to_send_len - sent_len);
            if(sz <= 0)
            {
                sprintf(error, "<eth_uart> write(uart) == %d!\n", sz);
                goto err;
            }
            sent_len += sz;
            if(sent_len == to_send_len)
            {
                to_send_len = 0;
                sent_len = 0;
            }
        }
    }
    err:
        printf("%s", error);
        return -1;
}

void usage() 
{
	printf(
		"PROGRAM_NAME by @zhoujianshi, dirty mod by @libc0607 \n" 
		"See https://zhoujianshi.github.io for more details. \n"
		"\n"
		"Usage: \n"
		"\teth-uart ./config.ini \n"
		"\n"
		"config.ini: \n"
		"[eth-uart]"
		"uart=/dev/ttyUSB0				# uart port"
		"proc=/proc/eth_uart/uio		# proc file created by kmod-eth-uart"
		"baud=115200					# baud rate for both tx/rx"
		"datab=8						# data bits, 5/6/7/8"
		"stopb=1						# stop bits, 1/2"
		"pareb=0						# parity check, 0-none, 1-odd, 2-even"
	);
	exit(0);
}

int main(int argc, char *argv[])
{
    int fds[2];
	char *file = argv[1];
	dictionary *ini = iniparser_load(file);
	
	if (!ini) {
		fprintf(stderr, "iniparser: failed to load %s.\n", file);
		exit(1);
	}
	if (argc != 2) {
		usage();
	}

    if ( init(ini, fds) != 0) 
	{
		return -1;
	}
        
    if ( main_routine(fds[0], fds[1], 4096) == -1) 
	{
		return -1;
	}
        
    close(fds[0]);
    close(fds[1]);
	iniparser_freedict(ini);
    return 0;
}
