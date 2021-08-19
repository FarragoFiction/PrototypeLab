import "dart:html";
import "dart:math" as Math;
import "dart:typed_data";

typedef FillFunction = int Function(int x, int y);
typedef ColourFunction = int Function(int r, int g, int b, [int a]);

int rgba(int r, int g, int b, int a) => a.clamp(0, 255) << 24 | b.clamp(0, 255) << 16 | g.clamp(0, 255) << 8 | r.clamp(0, 255);
int rgb(int r, int g, int b) => rgba(r,g,b,0xFF);
int grey(double v) {
    final int n = (v.clamp(0.0, 1.0) * 255).floor();
    return rgb(n,n,n);
}

Future<CanvasElement> createPixelTestCanvas(int width, int height, FillFunction fill, {double scaleFactor = 1.0, int originX = 0, int originY = 0}) async {
    final CanvasElement canvas = new CanvasElement(width: width, height: height);
    final CanvasRenderingContext2D ctx = canvas.context2D;
    final ImageData img = ctx.getImageData(0, 0, width, height);
    final Uint32List pixels = img.data.buffer.asUint32List();

    int index, ix, iy;
    for (int y=0; y<height; y++) {
        for (int x = 0; x < width; x++) {
            index = y * height + x;

            ix = ((x + originX - (width  ~/ 2)) / scaleFactor).round();
            iy = ((y + originY - (height ~/ 2)) / scaleFactor).round();

            pixels[index] = fill(ix,iy);
        }
    }

    ctx.putImageData(img, 0, 0);

    return canvas;
}