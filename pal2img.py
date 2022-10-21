#!/usr/bin/python3
import sys
from PIL import Image

def main():
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <pallete> <image>")
        return 1

    with open(sys.argv[1], "rb") as pal:
        pallete = pal.read()
        colors_count = len(pallete) / 2
        if colors_count > 16 or colors_count != int(colors_count):
            print("Invalid pallete file")
            return 2
        colors_count = int(colors_count)
        img = Image.new('RGB', (colors_count, 1))
        for i in range(colors_count):
            b = (pallete[i * 2] & 0xE) << 4
            g = pallete[i * 2 + 1] & 0xE0
            r = (pallete[i * 2 + 1] & 0xE) << 4
            img.putpixel((i, 0), (r, g, b))
        
        with open(sys.argv[2], "wb") as img_file:
            img.save(img_file, "PNG")

ret_code = main()
if ret_code is not None:
    ret_code = 0
sys.exit(ret_code)
