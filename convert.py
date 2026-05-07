import sys
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM

def convert_svg_to_png(svg_path, png_path):
    drawing = svg2rlg(svg_path)
    renderPM.drawToFile(drawing, png_path, fmt="PNG", bg=0xFFFFFF)

if __name__ == "__main__":
    convert_svg_to_png(sys.argv[1], sys.argv[2])
