import "dart:async";
import "dart:html";

import "package:CommonLib/Workers.dart";

import "../cache.dart";
import '../main.dart';
import "biome.dart";
import "tile.dart";

class Dungeon {
    static const int extraTileGenerationRadius = 1;

    final int seed;
    final Map<int,DungeonTile> tiles = <int,DungeonTile>{};

    // Client side stuff
    int cameraX = 0;
    int cameraY = 0;
    int tileX = 0;
    int tileY = 0;

    late int viewWidth;
    late int viewHeight;
    late int halfWidth;
    late int halfHeight;

    late final Element container;
    late final Element searchBar;
    late final CanvasElement canvas;
    late final CanvasRenderingContext2D context;
    late final WorkerHandler worker;

    bool mouseHeld = false;
    late Point<num> dragStart;
    late CoordPair dragCoord;
    late Point<num> mousePos;

    late final NumberInputElement xInput;
    late final NumberInputElement yInput;

    // Worker side stuff
    late final Blobs blobs;
    late final Noise noise;

    Dungeon(int width, int height, int this.seed, {bool isWorker = false}) {
        if (isWorker) {
            // this is the worker thread, we need to set up things related to generation

            blobs = new Blobs(2, seed);
            noise = new Noise(seed + 1);
        } else {
            // this is the client thread, we need to set up things related to rendering

            container = new DivElement()..className="dungeon";

            canvas = new CanvasElement(width: width, height: height);
            container.append(canvas);
            context = canvas.context2D;

            worker = createWebWorker("endlessdungeon/tileworker.worker.dart");
            worker.sendInstantCommand(WorkerCommands.initialise, seed);

            xInput = new NumberInputElement()..valueAsNumber = cameraX;
            yInput = new NumberInputElement()..valueAsNumber = cameraY;
            searchBar = new DivElement()
                ..className="dungeonSearch"
                ..text="Go to:"
                ..append(xInput)
                ..append(yInput)
                ..append(new ButtonElement()
                    ..text="Go!"
                    ..onClick.listen((Event e) {
                        this.setCameraPos(xInput.valueAsNumber?.floor() ?? 0, yInput.valueAsNumber?.floor() ?? 0);
                    })
                );
            container.append(searchBar);

            canvas.onMouseDown.listen(mouseDown);
            canvas.onMouseMove.listen(mouseMove);
            window.onMouseUp.listen(mouseUp);

            resize(width, height);
            drawLoop();
        }
    }

    double blob(int x, int y) => blobs.blob(x, y, this.noise.noise);

    void mouseDown(MouseEvent event) {
        mouseHeld = true;
        dragStart = event.offset;
        dragCoord = new CoordPair(cameraX, cameraY);

        //print("mouseDown at offset $dragStart, world $dragCoord");

        searchBar.classes.add("dragging");

        mouseMove(event);
    }

    void mouseUp(MouseEvent event) {
        mouseHeld = false;
        searchBar.classes.remove("dragging");
    }

    void mouseMove(MouseEvent event) {
        mousePos = event.offset;

        if (mouseHeld) {
            final int dx = (mousePos.x - dragStart.x).floor();
            final int dy = (mousePos.y - dragStart.y).floor();

            setCameraPos(dragCoord.x - dx, dragCoord.y - dy);

            //print("mouseMove at offset $mousePos, delta $dx,$dy");
        }
    }

    void resize(int newWidth, int newHeight) {
        viewWidth = newWidth;
        viewHeight = newHeight;
        halfWidth = newWidth ~/2;
        halfHeight = newHeight ~/2;

        canvas.width = newWidth;
        canvas.height = newHeight;

        updateTiles();
        //redraw();
    }

    void setCameraPos(int x, int y) {
        final bool changed = x != cameraX || y != cameraY;
        if (!changed) { return; }

        final CoordPair newTile = worldToTile(x, y);

        cameraX = x;
        cameraY = y;

        if (newTile.x != tileX || newTile.y != tileY) {
            tileX = newTile.x;
            tileY = newTile.y;
            updateTiles();
        }

        xInput.valueAsNumber = x;
        yInput.valueAsNumber = y;

        //redraw();
    }

    void updateTiles() {
        final int minX = cameraX - halfWidth;
        final int maxX = minX + viewWidth;
        final int minY = cameraY - halfHeight;
        final int maxY = minY + viewHeight;

        final CoordPair minTile = worldToTile(minX, minY);
        final CoordPair maxTile = worldToTile(maxX, maxY);

        final int minTileX = minTile.x - extraTileGenerationRadius;
        final int maxTileX = maxTile.x + extraTileGenerationRadius;
        final int minTileY = minTile.y - extraTileGenerationRadius;
        final int maxTileY = maxTile.y + extraTileGenerationRadius;

        final Set<int> removals = <int>{};

        // remove out of bounds tiles
        for (final int coord in tiles.keys) {
            final DungeonTile tile = tiles[coord]!;

            if (tile.x < minTileX || tile.x > maxTileX || tile.y < minTileY || tile.y > maxTileY) {
                removals.add(coord);
                //print("removing tile at ${tile.x},${tile.y}");
            }
        }
        for(final int coord in removals) {
            tiles.remove(coord);
        }

        // add in new tiles
        int x,y;
        for(final CoordPair coordPair in circleGrid(tileX, tileY, minTileX, minTileY, maxTileX, maxTileY)) {
            x = coordPair.x;
            y = coordPair.y;

            final int coord = hashPair(x, y);

            if (!tiles.keys.contains(coord)) {
                final DungeonTile tile = new DungeonTile(this, x, y);
                tiles[coord] = tile;
                //print("adding new tile at $x,$y");
            }
        }

        //print("New Tile Count: ${tiles.length}");
    }

    void drawLoop([num dt = 1/60]) {
        redraw(dt.toDouble());
        window.requestAnimationFrame(drawLoop);
    }

    void redraw([double dt = 1/60]) {
        context.clearRect(0, 0, viewWidth, viewHeight);

        context.save();
        context.translate(halfWidth-cameraX, halfHeight-cameraY);

        for (final DungeonTile tile in tiles.values) {
            if (isTileVisible(tile)) {
                tile.draw(context);
            }
        }

        context.restore();
    }

    CoordPair worldToTile(int x, int y) {
        return new CoordPair(
            ((x / DungeonTile.tileSize) + 0.5).floor(),
            ((y / DungeonTile.tileSize) + 0.5).floor()
        );
    }

    CoordPair tileToWorld(int x, int y) {
        return new CoordPair(
            ((x + 0.5) * DungeonTile.tileSize).floor(),
            ((y + 0.5) * DungeonTile.tileSize).floor()
        );
    }

    CoordPair canvasToWorld(int x, int y) {
        return new CoordPair(
          x + cameraX - halfWidth,
          y + cameraY - halfWidth
        );
    }

    bool isTileVisible(DungeonTile tile) {
        final int minX = cameraX - halfWidth;
        final int maxX = minX + viewWidth;

        if (tile.worldX + DungeonTile.halfSize < minX || tile.worldX - DungeonTile.halfSize > maxX) {
            return false;
        }

        final int minY = cameraY - halfHeight;
        final int maxY = minY + viewHeight;

        if (tile.worldY + DungeonTile.halfSize < minY || tile.worldY - DungeonTile.halfSize > maxY) {
            return false;
        }

        return true;
    }
}



abstract class WorkerCommands {
    static const String generate = "gen";
    static const String initialise = "init";
}