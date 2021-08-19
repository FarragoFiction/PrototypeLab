import "dart:html";
import "dart:math" as Math;

import "package:CommonLib/Random.dart";

import "cache.dart";
import "drawing.dart";
import "world/dungeon.dart";

Element output = querySelector("#stuff")!;

Future<void> main() async {
    final Dungeon dungeon = new Dungeon(window.innerWidth!, window.innerHeight!, 123);

    dungeon.canvas.style
        ..position="absolute"
        ..left="0"
        ..top="0";

    window.onResize.listen((Event e) {
        dungeon.resize(window.innerWidth!, window.innerHeight!);
    });

    output.append(dungeon.canvas);
}



class Blobs {
    final ValueCache<CoordPair> cache = new ValueCache<CoordPair>(1000);

    final int size;
    final int seed;

    Blobs(int this.size, int this.seed);

    double blob(int x, int y, double Function(int x, int y) valueGen) {
        final CoordPair? cached = cache.getValue(x, y);
        if (cached != null) {
            return valueGen(cached.x, cached.y);
        }

        CoordPair coords = new CoordPair(x,y);

        for (int i=0; i<size; i++) {
            coords = zoom(coords, seed);
        }

        final double value = valueGen(coords.x, coords.y);
        cache.addValue(x,y,coords);

        return value;
    }

    static CoordPair zoom(CoordPair coords, int seed) {
        // are the coords even
        final bool ex = (coords.x & 1) == 0;
        final bool ey = (coords.y & 1) == 0;

        final int hx = coords.x ~/ 2;
        final int hy = coords.y ~/ 2;

        if (ex && ey) {
            return new CoordPair(hx, hy);
        } else {
            final Random rand = new Random(hashPair(coords.x,coords.y) + seed);
            final int ox = rand.nextBool() ? (coords.x < 0 ? -1 : 1) : 0;
            final int oy = rand.nextBool() ? (coords.y < 0 ? -1 : 1) : 0;

            if (ex) {
                return new CoordPair(hx, hy + oy);
            } else if (ey) {
                return new CoordPair(hx + ox, hy);
            } else {
                return new CoordPair(hx + ox, hy + oy);
            }
        }
    }
}

class Noise {
    static final ValueCache<double> cache = new ValueCache<double>(1000);

    static double noise(int x, int y) {
        final double? cached = cache.getValue(x, y);

        if (cached != null) {
            return cached;
        }

        final Random rand = new Random(hashPair(x, y));
        final double value = rand.nextDouble();
        cache.addValue(x, y, value);

        return value;
    }
}

Iterable<CoordPair> spiralGrid(int startX, int startY, int minX, int minY, int maxX, int maxY) sync* {
    final int maxXDifference = Math.max(startX - minX, maxX - startX);
    final int maxYDifference = Math.max(startY - minY, maxY - startY);
    final int maxRadius = maxXDifference + maxYDifference;

    // centre point
    if (startX >= minX && startX <= maxX && startY >= minY && startY <= maxY) {
        yield new CoordPair(startX, startY);
    }

    // iterate through rings outward
    int x,y;
    for(int radius=1; radius<=maxRadius; radius++) {
        // top left quadrant
        for(int i=0; i<radius; i++) {
            x = startX - radius + i;
            y = startY - i;

            if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
                yield new CoordPair(x, y);
            }
        }
        // top right quadrant
        for(int i=0; i<radius; i++) {
            x = startX + i;
            y = startY - radius + i;

            if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
                yield new CoordPair(x, y);
            }
        }
        // bottom right quadrant
        for(int i=0; i<radius; i++) {
            x = startX + radius - i;
            y = startY + i;

            if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
                yield new CoordPair(x, y);
            }
        }
        // bottom left quadrant
        for(int i=0; i<radius; i++) {
            x = startX - i;
            y = startY + radius - i;

            if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
                yield new CoordPair(x, y);
            }
        }
    }
}

Iterable<CoordPair> circleGrid(int startX, int startY, int minX, int minY, int maxX, int maxY) sync* {
    final List<CoordPair> coords = <CoordPair>[];

    for(int y=minY; y<=maxY; y++) {
        for(int x=minX; x<=maxX; x++) {
            coords.add(new CoordPair(x,y));
        }
    }

    coords.sort((CoordPair a, CoordPair b) {
        final int dxA = a.x - startX;
        final int dyA = a.y - startY;
        final int sqDistA = dxA*dxA + dyA*dyA;

        final int dxB = b.x - startX;
        final int dyB = b.y - startY;
        final int sqDistB = dxB*dxB + dyB*dyB;

        return sqDistA.compareTo(sqDistB);
    });

    yield* coords;
}

CanvasElement spiralTest() {
    final CanvasElement canvas = new CanvasElement(width:500, height:500);
    final CanvasRenderingContext2D ctx = canvas.context2D;

    int i=0;
    //for(final CoordPair coord in spiralGrid(0, 0, -5, -3, 10, 8)) {
    for(final CoordPair coord in circleGrid(0, 0, -5, -3, 10, 8)) {
        final int greyVal = (i * 5) % 255;
        ctx.fillStyle = "rgb($greyVal,$greyVal,$greyVal)";

        ctx.fillRect(coord.x * 10 + 100, coord.y * 10 + 100, 9,9);

        i++;
    }

    return canvas;
}