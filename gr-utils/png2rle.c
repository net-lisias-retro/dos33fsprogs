#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "loadpng.h"

/* Converts a PNG to RLE compressed data */

int main(int argc, char **argv) {

	int enough=0,run=0;
	int x;

	unsigned char *image;
	int xsize,ysize,last=-1,next;
	FILE *outfile;
	int size=0;

	if (argc<3) {
		fprintf(stderr,"Usage:\t%s INFILE OUTFILE\n\n",argv[0]);
		exit(-1);
	}

	outfile=fopen(argv[2],"w");
	if (outfile==NULL) {
		fprintf(stderr,"Error!  Could not open %s\n",argv[2]);
		exit(-1);
	}

	if (loadpng(argv[1],&image,&xsize,&ysize)<0) {
		fprintf(stderr,"Error loading png!\n");
		exit(-1);
	}

	printf("Loaded image %d by %d\n",xsize,ysize);

	x=0;
	enough=0;

	/* Write out xsize and ysize */

	fprintf(outfile,"{ 0x%X,0x%X,\n",xsize,ysize);
	size+=2;

	/* Get first top/bottom color pair */
	last=image[x];
	run++;
	x++;

	while(1) {

		/* get next top/bottom color pair */
		next=image[x];

//		printf("x=%d, next=%x image[%d]=%x\n",
//			x,next,
//			x,image[x]);


		/* If color change (or too big) then output our run */
		/* Note 0xff for run length is special case meaning "finished" */
		if ((next!=last) || (run>253)) {
			fprintf(outfile,"0x%02X,0x%02X, ",run,last);

//			printf("%x,%x\n",run,last);

			size+=2;
			run=0;
			last=next;
		}

		x++;

		/* Split up per-line */
		enough++;
		if (enough>=xsize) {
			enough=0;
			fprintf(outfile,"\n");
		}

		/* If we reach the end */
		if (x>=xsize*(ysize/2)) {
			run++;
			/* print tailing value */
			if (run!=0) {
				fprintf(outfile,"0x%02X,0x%02X, ",run,last);
				size+=2;
			}
			break;
		}

		run++;


	}

	/* Print closing marker */

	fprintf(outfile,"0xFF,0xFF,");
	size+=2;
	fprintf(outfile,"};\n");

	fclose(outfile);

	printf("Size %d bytes\n",size);

	return 0;
}
