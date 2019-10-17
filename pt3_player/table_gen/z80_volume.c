#include <stdio.h>
#include <string.h>


static unsigned char PT3VolumeTable_33_34[]={
	0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,   //0
	0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,   //1
	0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x2,   //2
	0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x3,0x3,0x3,0x3,   //3
	0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x2,0x2,0x2,0x3,0x3,0x3,0x4,0x4,0x4,   //4
	0x0,0x0,0x0,0x1,0x1,0x1,0x2,0x2,0x3,0x3,0x3,0x4,0x4,0x4,0x5,0x5,   //5
	0x0,0x0,0x0,0x1,0x1,0x2,0x2,0x3,0x3,0x3,0x4,0x4,0x5,0x5,0x6,0x6,   //6
	0x0,0x0,0x1,0x1,0x2,0x2,0x3,0x3,0x4,0x4,0x5,0x5,0x6,0x6,0x7,0x7,   //7
	0x0,0x0,0x1,0x1,0x2,0x2,0x3,0x3,0x4,0x5,0x5,0x6,0x6,0x7,0x7,0x8,   //8
	0x0,0x0,0x1,0x1,0x2,0x3,0x3,0x4,0x5,0x5,0x6,0x6,0x7,0x8,0x8,0x9,   //9
	0x0,0x0,0x1,0x2,0x2,0x3,0x4,0x4,0x5,0x6,0x6,0x7,0x8,0x8,0x9,0xA,   //a
	0x0,0x0,0x1,0x2,0x3,0x3,0x4,0x5,0x6,0x6,0x7,0x8,0x9,0x9,0xA,0xB,   //b
	0x0,0x0,0x1,0x2,0x3,0x4,0x4,0x5,0x6,0x7,0x8,0x8,0x9,0xA,0xB,0xC,   //c
	0x0,0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x7,0x8,0x9,0xA,0xB,0xC,0xD,   //d
	0x0,0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,   //e
	0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,0xF,   //f
};


static unsigned char PT3VolumeTable_35[]={
 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,
 0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,
 0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x2,0x3,0x3,0x3,
 0x0,0x0,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x3,0x3,0x3,0x3,0x4,0x4,
 0x0,0x0,0x1,0x1,0x1,0x2,0x2,0x2,0x3,0x3,0x3,0x4,0x4,0x4,0x5,0x5,
 0x0,0x0,0x1,0x1,0x2,0x2,0x2,0x3,0x3,0x4,0x4,0x4,0x5,0x5,0x6,0x6,
 0x0,0x0,0x1,0x1,0x2,0x2,0x3,0x3,0x4,0x4,0x5,0x5,0x6,0x6,0x7,0x7,
 0x0,0x1,0x1,0x2,0x2,0x3,0x3,0x4,0x4,0x5,0x5,0x6,0x6,0x7,0x7,0x8,
 0x0,0x1,0x1,0x2,0x2,0x3,0x4,0x4,0x5,0x5,0x6,0x7,0x7,0x8,0x8,0x9,
 0x0,0x1,0x1,0x2,0x3,0x3,0x4,0x5,0x5,0x6,0x7,0x7,0x8,0x9,0x9,0xA,
 0x0,0x1,0x1,0x2,0x3,0x4,0x4,0x5,0x6,0x7,0x7,0x8,0x9,0xA,0xA,0xB,
 0x0,0x1,0x2,0x2,0x3,0x4,0x5,0x6,0x6,0x7,0x8,0x9,0xA,0xA,0xB,0xC,
 0x0,0x1,0x2,0x3,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xA,0xB,0xC,0xD,
 0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,
 0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,0xF,
};


static unsigned char VT[256];

#if 0
//VolTableCreator (c) Ivan Roshin
//A - VersionForVolumeTable (0..4 - 3.xx..3.4x;
//5.. - 3.5x..3.6x..VTII1.0)

void VolTableCreator(int which) {

	unsigned char h,l,d,e,a,c,carry,old_carry;
	unsigned short ix;
	unsigned char s[16];
	unsigned int temp1,temp2;
	int self_modified=0;

	//cp 005h			; compare accumulator with 5?

	carry=which;

	h=0;	//ld hl,00011h		; load 16-bit value at address $11 to hl?
	l=0x11;	//			; does not affect flags
	d=h;	//ld d,h			; d=h
	e=h;	//ld e,h			; e=h
	a=0x17;	//ld a,017h	RLA	; a=$17
	if (!carry) goto m1;	//jr nc,m1		; if (carry==1) {
	l--;	//dec l			;	l--;
	e=l;	//ld e,l			;	e=l;
	a=a^a;	//xor a			;	a=a^a; (a=0?)
	self_modified=1;
m1:		//		; }
	//	ld (m2),a	set m2 to NOP (0) or RLA ($17)
	ix=16;	//ld ix,VT_+16		; IX is 16 entries into table (
	c=0x10;	//ld c,010h		; c=16
pt3_initv2:
	s[0]=h;
	s[1]=l;	// push hl			; save hl

		// add hl,de		; hl=hl+de
	temp1=(h<<8)|l;
	temp2=(d<<8)|e;
	temp1=temp1+temp2;
	h=(temp1>>8)&0xff;
	l=temp1&0xff;
	if (temp1&(1<<16)) carry=1;
	else carry=0;

		// ex de,hl		; swap
	temp1=(h<<8)|l;
	temp2=(d<<8)|e;
	h=(temp2>>8);
	l=temp2&0xff;
	d=(temp1>>8);
	e=temp1&0xff;

		// sbc hl,hl
//	temp1=(h<<8)|l;
//	temp2=(h<<8)|l;
//	temp1=temp1-temp2-carry;
//	h=(temp1>>8);
//	l=temp1&0xff;
	if (carry==0) { h=0; l=0;}
	else {h=0xff; l=0xff;}

pt3_initv1:
	a=l;	// ld a,l	7d		; ?
//m2:
	// Self modified, RLA or NOP depending
		// ld a,l	7d  00=nop	; this is self modified
	if (self_modified) {
		/* nop */
	}
	else {
		/* rla $17 */
		old_carry=carry;
		carry=!!(a&0x80);
		a=a<<1;
		a|=old_carry;
	}

	a=h;	// ld a,h	7c		; ?
		// adc a,000h
	a=a+carry;

	VT[ix]=a;//ld (ix+000h),a
	ix++;	// inc ix

		// add hl,de
	temp1=(h<<8)|l;
	temp2=(d<<8)|e;
	temp1=temp1+temp2;
	h=(temp1>>8);
	l=temp1&0xff;

	c++;	// inc c
	a=c;	// ld a,c
	a=a&0xf;// and 00fh
	if (a!=0) goto pt3_initv1; //	jr nz,pt3_initv1
	h=s[0];
	l=s[1];	// pop hl
	a=e;	// ld a,e
		// cp 077h
		// jr nz,m3
	if ((a-0x77)!=0) goto m3;
	e++; //inc e
m3:
	a=c;	// ld a,c
	a=a&a;	// and a
	if (a!=0) goto pt3_initv2; //	jr nz,pt3_initv2
}

#endif


	/*  PT3VolumeTable_35 = 1 */
	/*  PT3VolumeTable_33334 = 0 */
void pt3_setup_volume_table(int which) {
	//based on VolTableCreator by Ivan Roshin
	// originally in z80 assembly language
	//A - VersionForVolumeTable (0..4 - 3.xx..3.4x;
	//5.. - 3.5x..3.6x..VTII1.0)

	unsigned int carry,a,hl,de,temp1,temp2,c,ix;

	/* 0x00 or 0x10 */
	de=(which<<4);

	for(ix=1;ix<16;ix++) {

		/* 0x10 or 0x11 */
		hl=(0x11-which);

		hl=hl+de;

		carry=(hl>>16);
		hl&=0xffff;

		/* swap hl and de */
		temp1=hl;
		temp2=de;
		hl=temp2;
		de=temp1;

		/* 0 or 0xffff */
		hl=(0-carry)&0xffff;

		for(c=0;c<16;c++) {

			if (!which) {
				carry=!!(hl&0x80);
			}

			a=(hl>>8)&0xff;
			a=a+carry;

			VT[ix*16+c]=a;

			hl=hl+de;

		}

		if ((de&0xff)==0x77) {
			de++;
		}

	}
}

int main(int argc, char **argv) {

	int i;

	pt3_setup_volume_table(0);

	for(i=0;i<256;i++) {
		if (i%16==0) printf("\n");
		printf(" %02X",VT[i]);
	}
	printf("\n");

	if (!memcmp(VT,PT3VolumeTable_35,256)) {
		printf("MATCH 35\n");
	}
	else {
		printf("NO MATCH 35\n");
	}

	if (!memcmp(VT,PT3VolumeTable_33_34,256)) {
		printf("MATCH 34\n");
	}
	else {
		printf("NO MATCH 34\n");
	}



	pt3_setup_volume_table(1);

	for(i=0;i<256;i++) {
		if (i%16==0) printf("\n");
		printf(" %02X",VT[i]);
	}
	printf("\n");

	if (!memcmp(VT,PT3VolumeTable_35,256)) {
		printf("MATCH 35\n");
	}
	else {
		printf("NO MATCH 35\n");
	}

	if (!memcmp(VT,PT3VolumeTable_33_34,256)) {
		printf("MATCH 34\n");
	}
	else {
		printf("NO MATCH 34\n");
	}



}



