import "dart:html";

import "biome.dart";
import "dungeon.dart";

class DungeonTile {
    static const int tileSize = 300;
    static const int halfSize = tileSize ~/ 2;

    final Dungeon dungeon;
    late final Biome biome;

    final Map<TileSide,Set<BiomeConnection>> connections = <TileSide,Set<BiomeConnection>> {
        TileSide.top: <BiomeConnection>{},
        TileSide.bottom: <BiomeConnection>{},
        TileSide.left: <BiomeConnection>{},
        TileSide.right: <BiomeConnection>{}
    };

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
            ctx.fillStyle = "silver";
        } else {
            //final int val = (testValue * 255).floor();
            //ctx.fillStyle = "rgba($val,$val,$val,0.25)";
            ctx.fillStyle = biome.colour;
        }

        ctx.fillRect(worldX - halfSize, worldY - halfSize, tileSize, tileSize);

        ctx
            ..strokeStyle = "black"
            //..strokeRect(worldX - halfSize + 0.5, worldY - halfSize + 0.5, tileSize, tileSize)
            ..fillStyle = "black"
            ..textAlign = "center"
            ..fillText("Tile $x,$y: ${generated ? biome.name : "Generating"}", worldX, worldY)
        ;

        ctx
            ..fillStyle = "black"
            ..strokeStyle = "rgba(0,0,0,0.3)"
        ;
        double conX, conY, conHW, conHH;
        for (final TileSide side in TileSide.all()) {
            for (final BiomeConnection connection in connections[side]!) {
                conHW = connection.size * 0.5 * side.xDir;
                conHH = connection.size * 0.5 * side.yDir;

                conX = worldX - halfSize + (tileSize * side.xPos) + (connection.position * side.xDir);
                conY = worldY - halfSize + (tileSize * side.yPos) + (connection.position * side.yDir);

                ctx.fillRect(
                    conX - conHW - 1,
                    conY - conHH - 1,
                    conHW * 2 + 3,
                    conHH * 2 + 3
                );

                ctx
                    ..beginPath()
                    ..moveTo(conX, conY)
                    ..lineTo(worldX, worldY)
                    ..stroke()
                ;
            }
        }
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
        this.biome = Biome.biomeList.get(dungeon.blob(x,y));

        for(final TileSide side in TileSide.all()) {
            final Biome neighbourBiome = Biome.biomeList.get(dungeon.blob(x + side.xCoord,y + side.yCoord));

            final BiomeConnectionGenerator generator = biome.getConnectionForBiome(neighbourBiome);

            connections[side]!.addAll(generator(side.vertical ? side.offsetGenCoords ? x-1 : x : x, side.vertical ? y : side.offsetGenCoords ? y-1 : y, side.vertical));
        }
    }

    /// Used on the worker side to pack the generated data
    Map<String,dynamic> serialise() {
        final Map<String,dynamic> payload = <String,dynamic>{};

        payload["biome"] = biome.id;

        payload["sides"] = TileSide.all().map((TileSide side) => connections[side]!.map((BiomeConnection c) => <double>[c.position,c.size]).toList()).toList();

        return payload;
    }

    /// Used on the client side to unpack the generated data
    void deserialise(dynamic rawPayload) {
        final Map<dynamic,dynamic> payload = rawPayload;

        biome = Biome.biomeList[payload["biome"]];

        int i=0;
        for(final TileSide side in TileSide.all()) {
            connections[side]!.addAll(payload["sides"][i++].map<BiomeConnection>((dynamic data) => new BiomeConnection(data[0], data[1])));
        }
    }
}

class TileSide {
    static const TileSide top = TileSide._(0,0,1,0,0,-1,true,false);
    static const TileSide bottom = TileSide._(0,1,1,0,0,1,false,false);
    static const TileSide left = TileSide._(0,0,0,1,-1,0,true,true);
    static const TileSide right = TileSide._(1,0,0,1,1,0,false,true);

    static Iterable<TileSide> all() sync* {
        yield top;
        yield bottom;
        yield left;
        yield right;
    }

    /// multiply tile size by xPos and yPos and add to x and y
    final int xPos;
    final int yPos;
    /// multiply offsets for connection by this
    final int xDir;
    final int yDir;
    /// offset for neighbour tile in this direction
    final int xCoord;
    final int yCoord;

    final bool offsetGenCoords;
    final bool vertical;

    const TileSide._(int this.xPos, int this.yPos, int this.xDir, int this.yDir, int this.xCoord, int this.yCoord, bool this.offsetGenCoords, bool this.vertical);
}