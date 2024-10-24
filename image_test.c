#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "image.h"

// all

uint16_t code128[] = {  0x6cc, 0x66c, 0x666, 0x498, 0x48c, 0x44c,
			            0x4c8, 0x4c4, 0x464, 0x648, 0x644, 0x624,
			            0x59c, 0x4dc, 0x4ce, 0x5cc, 0x4ec, 0x4e6,
			            0x672, 0x65c, 0x64e, 0x6e4, 0x674, 0x76e,
			            0x74c, 0x72c, 0x726, 0x764, 0x734, 0x732,
			            0x6d8, 0x6c6, 0x636, 0x518, 0x458, 0x446,
			            0x588, 0x468, 0x462, 0x688, 0x628, 0x622,
			            0x5b8, 0x58e, 0x46e, 0x5d8, 0x5c6, 0x476,
			            0x776, 0x68e, 0x62e, 0x6e8, 0x6e2, 0x6ee,
			            0x758, 0x746, 0x716, 0x768, 0x762, 0x71a,
			            0x77a, 0x642, 0x78a, 0x530, 0x50c, 0x4b0,
			            0x486, 0x42c, 0x426, 0x590, 0x584, 0x4d0,
			            0x4c2, 0x434, 0x432, 0x612, 0x650, 0x7ba,
			            0x614, 0x47a, 0x53c, 0x4bc, 0x49e, 0x5e4,
			            0x4f4, 0x4f2, 0x7a4, 0x794, 0x792, 0x6de,
			            0x6f6, 0x7b6, 0x578, 0x51e, 0x45e, 0x5e8,
			            0x5e2, 0x7a8, 0x7a2, 0x5de, 0x5ee, 0x75e};

ImageInfo* draw_pattern(ImageInfo *pImg, unsigned int x, uint16_t pattern, unsigned int lineWidth);
ImageInfo* draw_stop(ImageInfo *pImg, unsigned int x, unsigned int lineWidth);
ImageInfo* fill_white(ImageInfo *pImg);

uint16_t find_pattern(char c) { return code128[c-32]; }

uint16_t find_checksum(char *str) {
    int checksum_counter = 0;

    for (int i = 0; str[i] != '\0'; i++) {
        checksum_counter += (str[i] - 32)*(i+1);    // (character code - 32) * position
    }

    checksum_counter += 1;
    checksum_counter %= 103;

    return code128[checksum_counter];
}

bool check_lenght(ImageInfo *pImg, unsigned int lineWidth, char *str)
{
    int stringLength = 0;
    const char* sCopy = str;

    while (*sCopy != '\0') {
        stringLength++;
        sCopy++;
    }

    int totalPixels = (10 + 11 + stringLength*11 + 11 + 13)*lineWidth;

    if (totalPixels <= pImg->width) { return true; }

    return false;
}

void generate_code128(ImageInfo *pImg, unsigned int lineWidth, char *str)
{
    if (!check_lenght(pImg, lineWidth, str)) {
        printf("Failed to generate the barcode.\n");
        return;
    }
    else {
        fill_white(pImg);
        printf("Succesfully generated the barcode.\n");
    }
    
    uint16_t startCode = 0x690;
    uint16_t checksum = find_checksum(str);

    unsigned int x = 10 * lineWidth;    // quiet zone
    
    draw_pattern(pImg, x, startCode, lineWidth);
    x += 11 * lineWidth;

    for (int i = 0; str[i] != '\0'; i++) {
        uint16_t pattern = find_pattern(str[i]);
        draw_pattern(pImg, x, pattern, lineWidth);
        x += 11 * lineWidth;
    }

    draw_pattern(pImg, x, checksum, lineWidth);
    x += 11 * lineWidth;

    draw_stop(pImg, x, lineWidth);
}

int main(int argc, char *argv[])
{
    if (sizeof(bmpHdr) != 54)
    {
        printf("Size of the bitmap header is invalid (%d). Please, check compiler options.\n", sizeof(bmpHdr));
        return 1;
    }

    ImageInfo *pImg = readBmp("code128_white.bmp");     // code128_black.bmp to test if fill_white function works properly
    if (pImg == NULL)
    {
        printf("Error opening input file.\n");
        return 1;
    }

    char str[] = "ARKO x86 code128";                    // example
    unsigned int lineWidth = 1;                         // single line width

    generate_code128(pImg, lineWidth, str);
    saveBmp("result.bmp", pImg);
    freeImage(pImg);

    return 0;
}
