import "dart:async";
import "dart:html";

import "package:CommonLib/Workers.dart";

import "../cache.dart";
import '../main.dart';

class Dungeon {
    static const int extraTileGenerationRadius = 1;

    late final WorkerHandler worker;
    final int seed;

    int cameraX = 0;
    int cameraY = 0;
    int tileX = 0;
    int tileY = 0;

    late int viewWidth;
    late int viewHeight;
    late int halfWidth;
    late int halfHeight;

    late final CanvasElement canvas;
    late final CanvasRenderingContext2D context;

    final Map<int,DungeonTile> tiles = <int,DungeonTile>{};

    Dungeon(int width, int height, int this.seed, {bool isWorker = false}) {
        if (!isWorker) {
            canvas = new CanvasElement(width: width, height: height);
            context = canvas.context2D;

            worker = createWebWorker("endlessdungeon/tileworker.worker.dart");
            worker.sendInstantCommand(WorkerCommands.initialise, seed);

            resize(width, height);

            canvas.onMouseDown.listen(mouseDown);
            canvas.onMouseMove.listen(mouseMove);
            window.onMouseUp.listen(mouseUp);
        }
    }

    bool mouseHeld = false;
    late Point<num> dragStart;
    late CoordPair dragCoord;
    late Point<num> mousePos;

    void mouseDown(MouseEvent event) {
        mouseHeld = true;
        dragStart = event.offset;
        dragCoord = new CoordPair(cameraX, cameraY);

        //print("mouseDown at offset $dragStart, world $dragCoord");

        mouseMove(event);
    }

    void mouseUp(MouseEvent event) {
        mouseHeld = false;
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
        redraw();
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

        redraw();
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

    void redraw() {
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

class DungeonTile {
    static const int tileSize = 300;
    static const int halfSize = tileSize ~/ 2;

    final Dungeon dungeon;

    final int x;
    final int y;
    final int worldX;
    final int worldY;

    bool generated = false;

    DungeonTile(Dungeon this.dungeon, int this.x, int this.y, {bool isWorker = false}) : worldX = x * tileSize, worldY = y * tileSize {
        if (!isWorker) {
            requestGeneration().then((void _) {
                generated = true;
            });
        }
    }

    void draw(CanvasRenderingContext2D ctx) {
        if (!generated) {
            ctx
                ..fillStyle="silver"
                ..fillRect(worldX - halfSize + 0.5, worldY - halfSize + 0.5, tileSize, tileSize)
            ;
        }

        ctx
            ..strokeStyle = "black"
            ..strokeRect(worldX - halfSize + 0.5, worldY - halfSize + 0.5, tileSize, tileSize)
            ..fillStyle = "black"
            ..textAlign = "center"
            ..fillText("Tile $x,$y", worldX, worldY)
        ;
    }

    Future<void> requestGeneration() async {
        // this isn't the same as serialise because it's the info for starting generation, not the generated data
        final Map<String,dynamic> payload = <String,dynamic>{
            "x" : x,
            "y" : y,
        };

        deserialise(await dungeon.worker.sendCommand(WorkerCommands.generate, payload: payload));
    }

    Future<void> generate() async {
        await Future<void>.delayed(const Duration(seconds: 1));
    }

    /// Used on the worker side to pack the generated data
    Map<String,dynamic> serialise() {
        final Map<String,dynamic> payload = <String,dynamic>{};

        return payload;
    }

    /// Used on the client side to unpack the generated data
    void deserialise(dynamic rawPayload) {
        final Map<String,dynamic> payload = rawPayload;
    }
}

abstract class WorkerCommands {
    static const String generate = "gen";
    static const String initialise = "init";
}