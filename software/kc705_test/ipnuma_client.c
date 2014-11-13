#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define		MAGIC_CODE	0xbe9be955
#define		SERV_PORT	3422		// USB over IP
#define		BUFSIZE		1024

// sudo arp -s 10.0.21.99 00:37:76:00:00:01
// sudo arp -s 203.178.143.85 00:37:76:00:00:01
// sudo arp -s 203.178.139.139 00:37:76:00:00:01

int main(int argc, char **argv)
{
	int sockfd;
	struct sockaddr_in servaddr;
	int i, j, dwlen, dwlen2;
	int tlp[10];
	char sdata[BUFSIZE], dest_ip[256];
	long int write_addr, write_data;

	if ( argc < 2) {
		fprintf( stderr, "usage: %s [dest IP] <write_address> <write_data>\n", argv[0] );
		exit(-1);
	}

	strcpy( dest_ip, argv[1] );

	if ( argc >= 3 ) {
		write_addr = strtol( argv[2], NULL, 0);
		printf("write_addr=%012lx\n", write_addr);
	}

	if ( argc >= 4 ) {
		write_data = strtol( argv[3], NULL, 0);
		printf("write_data=%08x\n", write_data);
	}

	memset(&servaddr, 0, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(SERV_PORT);
	inet_aton(dest_ip, &servaddr.sin_addr);

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0){
		perror("socket()");
		exit(EXIT_FAILURE);
	}

	dwlen = 16;

	bzero( sdata, sizeof(sdata) );

	sdata[ 0] = (MAGIC_CODE >> 24) & 0xff;
	sdata[ 1] = (MAGIC_CODE >> 16) & 0xff;
	sdata[ 2] = (MAGIC_CODE >>  8) & 0xff;
	sdata[ 3] = (MAGIC_CODE >>  0) & 0xff;
	sdata[ 4] = 0x00;
	sdata[ 5] = 0x00;

#if 0
	if ( argc == 2 ) {

		sdata[ 4] = 0x80|dwlen;// write command(b7), 64bit(b6), length(b5-b0)=4DW
		sdata[ 5] = 0xff;	// LBE(b8-4), FBE(b3-0)

		sdata[ 6] = 0xc0;	// ADDR=0xD0000000
		sdata[ 7] = 0x00;
		sdata[ 8] = 0x00;
		sdata[ 9] = 0x00;

		sdata[dwlen*4+10] = 0x80|dwlen;// write command(b7), 64bit(b6), length(b5-b0)=4DW
		sdata[dwlen*4+11] = 0xff;	// LBE(b8-4), FBE(b3-0)

		sdata[dwlen*4+12] = 0xc0;	// ADDR=0xD0000000
		sdata[dwlen*4+13] = 0x00;
		sdata[dwlen*4+14] = 0x02;
		sdata[dwlen*4+15] = 0x80;

		for ( j=1 ; ; ++j) {
			for (i=0; i<dwlen; ++i) {
				sdata[ 10+i*4+0 ] = ((i+j)&0xf)*0x10+0;
				sdata[ 10+i*4+1 ] = ((i+j)&0xf)*0x10+1;
				sdata[ 10+i*4+2 ] = ((i+j)&0xf)*0x10+2;
				sdata[ 10+i*4+3 ] = ((i+j)&0xf)*0x10+3;
				sdata[ 16+(i+dwlen)*4+0 ] = ((i+j+1)&0xf)*0x10+0;
				sdata[ 16+(i+dwlen)*4+1 ] = ((i+j+1)&0xf)*0x10+1;
				sdata[ 16+(i+dwlen)*4+2 ] = ((i+j+1)&0xf)*0x10+2;
				sdata[ 16+(i+dwlen)*4+3 ] = ((i+j+1)&0xf)*0x10+3;
			}
//write	(1,sdata,18+(4*dwlen*2)+1);
			if (sendto(sockfd, sdata, 16+(4*dwlen*2)+1, 0, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0){
				perror("sendto()");
			}
			usleep(1);
		}
	} else {
#endif
//		sdata[ 4] = 0xc1;// write command(b7), 64bit(b6), length(b5-b0)=4DW
//		sdata[ 5] = 0xff;	// LBE(b8-4), FBE(b3-0)

//		sdata[ 6] = (write_addr >> 32) & 0xff;

		tlp[0] = 0x40000001;
		tlp[1] = 0x123401ff;
		tlp[2] = write_addr; //0x000b8000;
		tlp[3] = 0xa1b2c3d4;

		for (i=0; i<4; ++i) {
			sdata[ i*4+6 ] = (tlp[i] >>  0) & 0xff;
			sdata[ i*4+7 ] = (tlp[i] >>  8) & 0xff;
			sdata[ i*4+8 ] = (tlp[i] >> 16) & 0xff;
			sdata[ i*4+9 ] = (tlp[i] >> 24) & 0xff;
		}

		if (sendto(sockfd, sdata, 6+4*4, 0, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0){
			perror("sendto()");
		}

//	}

	exit(EXIT_SUCCESS);
}
