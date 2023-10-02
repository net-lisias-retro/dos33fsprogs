/* box_convert */

/* Try to automate the loser conversion process */

#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "loadpng.h"

#include "box_sizes.c"

static int debug=0;

static char color_names[16][16]={
	"BLACK",	/* $00 */
	"RED",		/* $01 */
	"DARK_BLUE",	/* $02 */
	"MAGENTA",	/* $03 */
	"GREEN",	/* $04 */
	"GREY1",	/* $05 */
	"MEDIUM_BLUE",	/* $06 */
	"LIGHT_BLUE",	/* $07 */
	"BROWN",	/* $08 */
	"ORANGE",	/* $09 */
	"GREY2",	/* $0A */
	"PINK",		/* $0B */
	"LIGHT_GREEN",	/* $0C */
	"YELLOW",	/* $0D */
	"AQUA",		/* $0E */
	"WHITE",	/* $0F */
};


/* SET_COLOR = $C0 */

#define ACTION_END		0x0
#define ACTION_CLEAR		0x1
#define ACTION_BOX		0x2
#define ACTION_HLIN		0x3
#define ACTION_VLIN		0x4
#define ACTION_PLOT		0x5
#define ACTION_HLIN_ADD		0x6
#define ACTION_HLIN_ADD_LSAME	0x7
#define ACTION_HLIN_ADD_RSAME	0x8
#define ACTION_BOX_ADD		0x9
#define ACTION_BOX_ADD_LSAME	0xA
#define ACTION_BOX_ADD_RSAME	0xB


#if 0
static char action_names[9][16]={
	"END","CLEAR","BOX","HLIN","VLIN","PLOT",
	"HLIN_ADD","HLIN_ADD_LSAME","HLIN_ADD_RSAME"
};
#endif

#define MAX_PRIMITIVES	4096
static struct primitive_list_t {
	int type;
	int color;
	int x1,y1,x2,y2;
} primitive_list[MAX_PRIMITIVES];

static int framebuffer[40][48];
static int background_color=0;

int create_using_plots(void) {

	int current_primitive=0;
	int row,col;

	/* Initial Implementation, All Plots */

	for(row=0;row<48;row++) {
		for(col=0;col<40;col++) {
			primitive_list[current_primitive].color=framebuffer[col][row];
			primitive_list[current_primitive].x1=col;
			primitive_list[current_primitive].y1=row;
			primitive_list[current_primitive].type=ACTION_PLOT;
			current_primitive++;

		}
	}
	return current_primitive;
}

static unsigned char *image;

static struct color_lookup_t {
	int color;
	int count;
} color_lookup[16]={
	{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{8,0},
	{9,0},{10,0},{11,0},{12,0},{13,0},{14,0},{15,0}
};

int create_using_hlins(void) {

	int current_primitive=0;
	int row,col,start_x;
	int prev_color;
	int len;

	for(row=0;row<48;row++) {
		prev_color=framebuffer[0][row]; len=0; start_x=0;
		for(col=0;col<40;col++) {
			if (framebuffer[col][row]!=prev_color) {
				primitive_list[current_primitive].color=
					prev_color;
				primitive_list[current_primitive].x1=start_x;
				primitive_list[current_primitive].x2=start_x+len;
				primitive_list[current_primitive].y1=row;
				primitive_list[current_primitive].type=ACTION_HLIN;
				current_primitive++;
				len=0;
				prev_color=framebuffer[col][row];
				start_x=col;
			}
			else {
				len++;
			}

		}
	}
	return current_primitive;
}

int create_using_hlins_by_color(void) {

	int current_primitive=0;
	int row,col,start_x;
	int current_color,prev_color;
	int len,color;

	for(color=0;color<16;color++) {
	current_color=color_lookup[color].color;

	if (current_color==background_color) continue;

	for(row=0;row<48;row++) {
		prev_color=framebuffer[0][row]; len=0; start_x=0;
		for(col=0;col<40;col++) {
			if (framebuffer[col][row]!=prev_color) {
				if (prev_color==current_color) {
				primitive_list[current_primitive].color=
					prev_color;
				primitive_list[current_primitive].x1=start_x;
				primitive_list[current_primitive].x2=start_x+len;
				primitive_list[current_primitive].y1=row;
				primitive_list[current_primitive].type=ACTION_HLIN;
				current_primitive++;
				}
				len=0;
				prev_color=framebuffer[col][row];
				start_x=col;
			}
			else {
				len++;
			}

		}
	}
	}
	return current_primitive;
}

int find_max_color_extent(int current_color,int *color_minx,int *color_miny,
			int *color_maxx,int *color_maxy) {


	int xx,yy;

	*color_minx=39;
	*color_miny=47;
	*color_maxx=0;
	*color_maxy=0;

	/* Find maximum extent of color */
	for(yy=0;yy<48;yy++) {
		for(xx=0;xx<40;xx++) {
			if (current_color==framebuffer[xx][yy]) {
				if (xx<*color_minx) *color_minx=xx;
				if (xx>*color_maxx) *color_maxx=xx;
				if (yy<*color_miny) *color_miny=yy;
				if (yy>*color_maxy) *color_maxy=yy;
			}
		}
	}
	if (debug) fprintf(stderr,"Color %d: range %d,%d to %d,%d\n",
			current_color,*color_minx,*color_miny,
			*color_maxx,*color_maxy);


	return 0;

}

int create_using_boxes(void) {

	int current_primitive=0;
	int row,col,box;
	int current_color;
	int color;
	int color_minx,color_maxx,color_miny,color_maxy;

	for(color=0;color<16;color++) {
	current_color=color_lookup[color].color;

	if (current_color==background_color) continue;


	find_max_color_extent(current_color,
					&color_minx,&color_miny,
					&color_maxx,&color_maxy);

	for(box=0;box<NUM_BOX_SIZES;box++) {

	int xx,yy,box_found,color_found,color_found2;

	for(row=0;row<48-box_sizes[box].y;row++) {
		for(col=0;col<40-box_sizes[box].x;col++) {
			box_found=1;
			color_found=0;
			color_found2=0;

			for(yy=0;yy<box_sizes[box].y;yy++) {
			for(xx=0;xx<box_sizes[box].x;xx++) {


//			only counts if color found
			if (framebuffer[xx+col][yy+row]==current_color) {
				color_found=1;
			}

			if ((framebuffer[xx+col][yy+row]==background_color)||
				(framebuffer[xx+col][yy+row]==0xff))
				 {
				box_found=0;
				break;
			}
			} // xx
			if (!box_found) break;
			} // yy

			if (( (col)>=color_minx)&&((col+box_sizes[box].x-1)<=color_maxx)&&
				((row)>=color_miny)&&((row+box_sizes[box].y-1)<=color_maxy)) {
				color_found2=1;
			}


			if ((box_found)&&(color_found)&&(color_found2)) {
				if (debug) fprintf(stderr,"Found box c=%d %d,%d to %d,%d\n",
					current_color,col,row,col+box_sizes[box].x-1,
						row+box_sizes[box].y-1);
				primitive_list[current_primitive].color=
					current_color;
				primitive_list[current_primitive].x1=col;
				primitive_list[current_primitive].x2=col+
					box_sizes[box].x-1;
				primitive_list[current_primitive].y1=row;
				primitive_list[current_primitive].y2=row+
					box_sizes[box].y-1;
				primitive_list[current_primitive].type=ACTION_BOX;
				current_primitive++;
				if (current_primitive>=MAX_PRIMITIVES) {
					fprintf(stderr,"Error!  Too many primitives: %d\n",current_primitive);
					exit(1);
				}
				for(yy=0;yy<box_sizes[box].y;yy++) {
				for(xx=0;xx<box_sizes[box].x;xx++) {
					if(framebuffer[xx+col][yy+row]==current_color) {
					framebuffer[xx+col][yy+row]=0xff;
					}
				}
				}
	find_max_color_extent(current_color,
					&color_minx,&color_miny,
					&color_maxx,&color_maxy);

			}


		} // col
	}	// row
	}	// box
	}	// current_color
	return current_primitive;
}

static int compare_type(const void *p1, const void *p2) {

	struct primitive_list_t *first,*second;

	first=(struct primitive_list_t *)p1;
	second=(struct primitive_list_t *)p2;

	return (first->type > second->type);

}

static int compare_y1(const void *p1, const void *p2) {

	struct primitive_list_t *first,*second;

	first=(struct primitive_list_t *)p1;
	second=(struct primitive_list_t *)p2;

	return (first->y1 > second->y1);

}

static int compare_color(const void *p1, const void *p2) {

	struct color_lookup_t *first,*second;

	first=(struct color_lookup_t *)p1;
	second=(struct color_lookup_t *)p2;

	return (first->count < second->count);

}




int generate_frame(int print_results) {

	int i;

	int current_color=0;

	int max_primitive=0;
	int previous_primitive=0;
	int total_size=0;



//	max_primitive=create_using_hlins();
//	max_primitive=create_using_hlins_by_color();
	max_primitive=create_using_boxes();


	/* Optimize boxes to PLOT/VLIN/HLIN*/
	for(i=0;i<max_primitive;i++) {
		if (primitive_list[i].type==ACTION_BOX) {
			if ((primitive_list[i].x1==primitive_list[i].x2) &&
				(primitive_list[i].y1==primitive_list[i].y2)) {
				primitive_list[i].type=ACTION_PLOT;
			} else
			if (primitive_list[i].x1==primitive_list[i].x2) {
				primitive_list[i].type=ACTION_VLIN;
			} else
			if (primitive_list[i].y1==primitive_list[i].y2) {
				primitive_list[i].type=ACTION_HLIN;
			}
		}
	}

	/* Sort each color by BOX/HLIN/ETC */
	int old_color,last_color_start=0;

	old_color=primitive_list[0].color;
	for(i=0;i<max_primitive;i++) {
		if ((primitive_list[i].color!=old_color)||(i==max_primitive-1)) {
			if (debug) fprintf(stderr,"Sorting color %d from %d to %d\n",
				old_color,last_color_start,i);
			qsort(&(primitive_list[last_color_start]),i-last_color_start,
				sizeof(struct primitive_list_t),compare_type);
			last_color_start=i;
		}
		old_color=primitive_list[i].color;
	}

	/* Sort HLIN by Y1 */
	int first_hlin=0,last_hlin=0,j,hlin_found;

	old_color=primitive_list[0].color;
	for(i=0;i<max_primitive;i++) {
		if ((primitive_list[i].color!=old_color)||(i==max_primitive-1))  {
			hlin_found=0;
			first_hlin=0; last_hlin=0;
//			fprintf(stderr,"Searching for HLIN in color %d from %d to %d\n",
//				old_color,last_color_start,i);
			for(j=last_color_start;j<i;j++) {
				if (primitive_list[j].type==ACTION_HLIN) {
					if (!hlin_found) {
						first_hlin=j;
						hlin_found=1;
					}
					last_hlin=j;
				}
			}
			if (hlin_found) {
				if (debug) fprintf(stderr,"Sorting color %d HLIN Y1 from %d to %d\n",
					old_color,first_hlin,last_hlin);
				// qsort(base, num_members,size_members,compare func
				qsort(&(primitive_list[first_hlin]),last_hlin-first_hlin,
					sizeof(struct primitive_list_t),compare_y1);
			}
			else {
//				fprintf(stderr,"No HLIN in color %d\n",old_color);
			}
			last_color_start=i;
		}
		old_color=primitive_list[i].color;
	}

	/* Sort BOX by Y1 */
	int first_box=0,last_box=0,box_found;

	old_color=primitive_list[0].color;
	for(i=0;i<max_primitive;i++) {
		if ((primitive_list[i].color!=old_color)||(i==max_primitive-1))  {
			box_found=0;
			first_box=0; last_box=0;
//			fprintf(stderr,"Searching for BOX in color %d from %d to %d\n",
//				old_color,last_color_start,i);
			for(j=last_color_start;j<i;j++) {
				if (primitive_list[j].type==ACTION_BOX) {
					if (!box_found) {
						first_box=j;
						box_found=1;
					}
					last_box=j;
				}
			}
			if (box_found) {
				if (debug) fprintf(stderr,"Sorting color %d BOX Y1 from %d to %d\n",
					old_color,first_box,last_box);
				// qsort(base, num_members,size_members,compare func
				qsort(&(primitive_list[first_box]),last_box-first_box,
					sizeof(struct primitive_list_t),compare_y1);
			}
			else {
//				fprintf(stderr,"No BOX in color %d\n",old_color);
			}
			last_color_start=i;
		}
		old_color=primitive_list[i].color;
	}


	/* Optimize HLIN */
	int previous_entry=0,previous_y1=0,previous_x1=0,previous_x2=0,previous_y2=0;
	for(i=0;i<max_primitive;i++) {
		if (primitive_list[i].type==ACTION_HLIN) {

			if ( ((previous_entry==ACTION_HLIN)||(previous_entry==ACTION_HLIN_ADD) ||(previous_entry==ACTION_HLIN_ADD_LSAME)) &&
				(previous_y1==primitive_list[i].y1-1) &&
				(previous_x1==primitive_list[i].x1)) {
				primitive_list[i].type=ACTION_HLIN_ADD_LSAME;
			}
			else
			if ( ((previous_entry==ACTION_HLIN)||(previous_entry==ACTION_HLIN_ADD) ||(previous_entry==ACTION_HLIN_ADD_RSAME)) &&
				(previous_y1==primitive_list[i].y1-1) &&
				(previous_x2==primitive_list[i].x2)) {
				primitive_list[i].type=ACTION_HLIN_ADD_RSAME;
			}
			else
			if ( ((previous_entry==ACTION_HLIN) || (previous_entry==ACTION_HLIN_ADD) || (previous_entry==ACTION_PLOT)) &&
				(previous_y1==primitive_list[i].y1-1)) {
				primitive_list[i].type=ACTION_HLIN_ADD;
			}
		}
		previous_entry=primitive_list[i].type;
		previous_y1=primitive_list[i].y1;
		previous_x1=primitive_list[i].x1;
		previous_x2=primitive_list[i].x2;
	}


	/* Optimize BOX */
	previous_entry=0,previous_y1=0,previous_y2=0,previous_x1=0,previous_x2=0;
	for(i=0;i<max_primitive;i++) {
		if (primitive_list[i].type==ACTION_BOX) {

			if ( ((previous_entry==ACTION_BOX)||(previous_entry==ACTION_BOX_ADD) ||(previous_entry==ACTION_BOX_ADD_LSAME)) &&
				(previous_y2==primitive_list[i].y1-1) &&
				(previous_x1==primitive_list[i].x1)) {
				primitive_list[i].type=ACTION_BOX_ADD_LSAME;
			}
			else
			if ( ((previous_entry==ACTION_BOX)||(previous_entry==ACTION_BOX_ADD) ||(previous_entry==ACTION_BOX_ADD_RSAME)) &&
				(previous_y2==primitive_list[i].y1-1) &&
				(previous_x2==primitive_list[i].x2)) {
				primitive_list[i].type=ACTION_BOX_ADD_RSAME;
			}
			else
			if ( ((previous_entry==ACTION_BOX) || (previous_entry==ACTION_BOX_ADD)) &&
				(previous_y2==primitive_list[i].y1-1)) {
				primitive_list[i].type=ACTION_BOX_ADD;
			}
		}
		previous_entry=primitive_list[i].type;
		previous_x1=primitive_list[i].x1;
		previous_y1=primitive_list[i].y1;
		previous_x2=primitive_list[i].x2;
		previous_y2=primitive_list[i].y2;
	}



	/* Dump results */
	for(i=0;i<max_primitive;i++) {
		if (primitive_list[i].color==0) continue;

		if (current_color!=primitive_list[i].color) {
			printf("\t.byte SET_COLOR | %s\n",
				color_names[primitive_list[i].color]);
			current_color=primitive_list[i].color;
			total_size+=1;
		}

		switch(primitive_list[i].type) {
			case ACTION_END:
					break;
			case ACTION_CLEAR:
					break;
			case ACTION_BOX:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].y1,
						primitive_list[i].x2,
						primitive_list[i].y2);
					total_size+=4;
				}
				else {
					printf("\t.byte BOX,%d,%d,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].y1,
						primitive_list[i].x2,
						primitive_list[i].y2);
					total_size+=5;
					previous_primitive=ACTION_BOX;
				}
					break;
			case ACTION_HLIN:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=3;
				}
				else {
					printf("\t.byte HLIN,%d,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=4;
					previous_primitive=ACTION_HLIN;

				}
					break;
			case ACTION_VLIN:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d,%d\n",
						primitive_list[i].y1,
						primitive_list[i].y2,
						primitive_list[i].x1);
					total_size+=3;
				}
				else {
					printf("\t.byte VLIN,%d,%d,%d\n",
						primitive_list[i].y1,
						primitive_list[i].y2,
						primitive_list[i].x1);
					total_size+=4;
					previous_primitive=ACTION_VLIN;

				}
					break;
			case ACTION_PLOT:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].y1);
					total_size+=2;
				}
				else {
					printf("\t.byte PLOT,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].y1);
					total_size+=3;
					previous_primitive=ACTION_PLOT;

				}
					break;
			case ACTION_HLIN_ADD:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d\t; %d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=2;
				}
				else {
					printf("\t.byte HLIN_ADD,%d,%d\t; %d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=3;
					previous_primitive=ACTION_HLIN_ADD;

				}
					break;
			case ACTION_HLIN_ADD_LSAME:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d\n",
						primitive_list[i].x2);
					total_size+=1;
				}
				else {
					printf("\t.byte HLIN_ADD_LSAME,%d ; %d, %d, %d\n",
						primitive_list[i].x2,
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=2;
					previous_primitive=ACTION_HLIN_ADD_LSAME;

				}
					break;
			case ACTION_HLIN_ADD_RSAME:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d\t; %d %d %d\n",
						primitive_list[i].x1,
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=1;
				}
				else {
					printf("\t.byte HLIN_ADD_RSAME,%d\t; %d %d %d\n",
						primitive_list[i].x1,
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=2;
					previous_primitive=ACTION_HLIN_ADD_RSAME;

				}
					break;
			case ACTION_BOX_ADD:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d,%d\t; %d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y2,
						primitive_list[i].y1);
					total_size+=3;
				}
				else {
					printf("\t.byte BOX_ADD,%d,%d,%d\t; %d\n",
						primitive_list[i].x1,
						primitive_list[i].x2,
						primitive_list[i].y2,
						primitive_list[i].y1);
					total_size+=4;
					previous_primitive=ACTION_BOX_ADD;

				}
					break;
			case ACTION_BOX_ADD_LSAME:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d\n",
						primitive_list[i].x2,
						primitive_list[i].y2);
					total_size+=2;
				}
				else {
					printf("\t.byte BOX_ADD_LSAME,%d,%d ; %d, %d\n",
						primitive_list[i].x2,
						primitive_list[i].y2,
						primitive_list[i].x1,
						primitive_list[i].y1);
					total_size+=3;
					previous_primitive=ACTION_BOX_ADD_LSAME;

				}
					break;
			case ACTION_BOX_ADD_RSAME:
				if (primitive_list[i].type==previous_primitive) {
					printf("\t.byte %d,%d\t; %d %d\n",
						primitive_list[i].x1,
						primitive_list[i].y2,
						primitive_list[i].x2,
						primitive_list[i].y1);
					total_size+=2;
				}
				else {
					printf("\t.byte BOX_ADD_RSAME,%d,%d\n",
						primitive_list[i].x1,
						primitive_list[i].y2);
					total_size+=3;
					previous_primitive=ACTION_BOX_ADD_RSAME;

				}
					break;

			default:
				fprintf(stderr,"Error unknown type!\n");
				exit(1);
				break;

		}


	}
	printf("\t.byte END\n");
	total_size++;
	printf("; total size = %d\n",total_size);

	return total_size;
}

int main(int argc, char **argv) {

	int xsize,ysize;
	int row,col,pixel,i;

	if (argc<1) {
		fprintf(stderr,"Usage:\t%s INFILE\n",argv[0]);
		exit(-1);
	}

	if (loadpng(argv[1],&image,&xsize,&ysize,PNG_WHOLETHING)<0) {
		fprintf(stderr,"Error loading png!\n");
		exit(-1);
	}

	if (debug) fprintf(stderr,"Loaded image %d by %d\n",xsize,ysize);

	if (ysize!=48) {
		fprintf(stderr,"Error!  Ysize must be 48!\n");
		exit(1);
	}

	if (xsize==40) {

	}
	else if (xsize==80) {

	}
	else {
		fprintf(stderr,"Error!  Improper xsize %d!\n",xsize);
		exit(1);
	}

	for(row=0;row<24;row++) {
		for(col=0;col<40;col++) {
			pixel=(image[row*40+col]);
			color_lookup[pixel&0xf].count++;
			color_lookup[(pixel>>4)&0xf].count++;
			framebuffer[col][row*2]=pixel&0xf;
			framebuffer[col][(row*2)+1]=(pixel>>4)&0xf;
		}
	}

	qsort(&(color_lookup[1]),15,
			sizeof(struct color_lookup_t),compare_color);


	/* TODO: sort */
	printf("; Histogram\n");
	for(i=0;i<16;i++) {
		printf("; $%02X %s: %d\n",color_lookup[i].color,color_names[color_lookup[i].color],color_lookup[i].count);
	}



	generate_frame(1);


	return 0;
}


