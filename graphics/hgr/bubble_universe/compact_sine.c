#include <stdio.h>

static unsigned char const good_sine[256]={
	0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
	0x40,0x41,0x42,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x48,0x49,0x4A,0x4B,0x4C,0x4C,
	0x4D,0x4E,0x4E,0x4F,0x50,0x50,0x51,0x52,0x52,0x53,0x53,0x54,0x54,0x55,0x55,0x55,
	0x56,0x56,0x57,0x57,0x57,0x58,0x58,0x58,0x58,0x58,0x59,0x59,0x59,0x59,0x59,0x59,

	0x59,0x59,0x59,0x59,0x59,0x59,0x59,0x58,0x58,0x58,0x58,0x58,0x57,0x57,0x57,0x56,
	0x56,0x55,0x55,0x55,0x54,0x54,0x53,0x53,0x52,0x52,0x51,0x50,0x50,0x4F,0x4E,0x4E,
	0x4D,0x4C,0x4C,0x4B,0x4A,0x49,0x48,0x48,0x47,0x46,0x45,0x44,0x43,0x42,0x42,0x41,
	0x40,0x3F,0x3E,0x3D,0x3C,0x3B,0x3A,0x39,0x38,0x37,0x36,0x35,0x34,0x33,0x32,0x31,

	0x30,0x2F,0x2E,0x2D,0x2C,0x2B,0x2A,0x29,0x28,0x27,0x26,0x25,0x24,0x23,0x22,0x21,
	0x20,0x1F,0x1E,0x1E,0x1D,0x1C,0x1B,0x1A,0x19,0x18,0x18,0x17,0x16,0x15,0x14,0x14,
	0x13,0x12,0x12,0x11,0x10,0x10,0x0F,0x0E,0x0E,0x0D,0x0D,0x0C,0x0C,0x0B,0x0B,0x0B,
	0x0A,0x0A,0x09,0x09,0x09,0x08,0x08,0x08,0x08,0x08,0x07,0x07,0x07,0x07,0x07,0x07,
	0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x08,0x08,0x08,0x08,0x08,0x09,0x09,0x09,0x0A,
	0x0A,0x0B,0x0B,0x0B,0x0C,0x0C,0x0D,0x0D,0x0E,0x0E,0x0F,0x10,0x10,0x11,0x12,0x12,
	0x13,0x14,0x14,0x15,0x16,0x17,0x18,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1E,0x1F,
	0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,
};

static unsigned char const quarter_sine[65]={
	0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
	0x40,0x41,0x42,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x48,0x49,0x4A,0x4B,0x4C,0x4C,
	0x4D,0x4E,0x4E,0x4F,0x50,0x50,0x51,0x52,0x52,0x53,0x53,0x54,0x54,0x55,0x55,0x55,
	0x56,0x56,0x57,0x57,0x57,0x58,0x58,0x58,0x58,0x58,0x59,0x59,0x59,0x59,0x59,0x59,0x59
};

static unsigned char final_sine[256];

int main(int argc, char **argv) {

	int i,errors=0;

	for(i=0;i<65;i++) {
		final_sine[i]=quarter_sine[i];		// 0..64
		final_sine[128-i]=quarter_sine[i];	// 64..128
		final_sine[128+i]=0x60-quarter_sine[i];	// 128..192
		final_sine[256-i]=0x60-quarter_sine[i]; // 192..256
	}

	for(i=0;i<256;i++) {
		if (good_sine[i]!=final_sine[i]) {
			printf("%d: %d!=%d\n",i,good_sine[i],final_sine[i]);
			errors++;
		}
	}

	printf("Total Errors=%d\n",errors);

	return 0;
}
