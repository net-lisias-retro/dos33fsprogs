#include <stdio.h>

char data[12*6]={
	   0x00,0x00,0x40,0x01,0x00,0x00,
           0x00,0x00,0x0C,0x18,0x00,0x00,
           0x00,0x00,0x70,0x07,0x00,0x00,
           0x00,0x00,0x43,0x61,0x00,0x00,
           0x00,0x00,0x4C,0x19,0x00,0x00,
           0x33,0x00,0x70,0x07,0x00,0x66,
           0x30,0x06,0x40,0x01,0x30,0x06,
           0x3f,0x06,0x40,0x01,0x30,0x7e,
           0x40,0x07,0x30,0x06,0x70,0x01,
           0x7c,0x07,0x30,0x06,0x70,0x1f,
           0x00,0x18,0x0F,0x78,0x0C,0x00,
           0x00,0x60,0x40,0x01,0x03,0x00,
};

int tokens[100];
int freq[100];

int main(int argc, char **argv) {

	int i,j,b,total=0;

	for(i=0;i<12*6;i+=2) {
		b=(data[i]<<8)|data[i+1];
		for(j=0;j<total;j++) {
			if (b==tokens[j]) {
				freq[j]++;
				break;
			}
		}
		if (j==total) {
			total++;
			tokens[j]=b;
			freq[j]=1;
		}
	}

	printf("Tokens: %d\n",total);
	for(i=0;i<total;i++) {
		printf("%d\t%x\n",freq[i],tokens[i]);
	}
	return 0;
}