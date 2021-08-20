import "dart:html";

import "biome.dart";
import "dungeon.dart";

class DungeonTile {
    static const int tileSize = 300;
    static const int halfSize = tileSize ~/ 2;

    final Dungeon dungeon;
    late final Biome biome;

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

        ctx.fillRect(worldX - halfSize + 0.5, worldY - halfSize + 0.5, tileSize, tileSize);

        ctx
            ..strokeStyle = "black"
            ..strokeRect(worldX - halfSize + 0.5, worldY - halfSize + 0.5, tileSize, tileSize)
            ..fillStyle = "black"
            ..textAlign = "center"
            ..fillText("Tile $x,$y: ${generated ? biome.name : "Generating"}", worldX, worldY)
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
        this.biome = Biome.biomeList.get(dungeon.blob(x,y));
    }

    /// Used on the worker side to pack the generated data
    Map<String,dynamic> serialise() {
        final Map<String,dynamic> payload = <String,dynamic>{};

        payload["biome"] = biome.id;

        return payload;
    }

    /// Used on the client side to unpack the generated data
    void deserialise(dynamic rawPayload) {
        final Map<dynamic,dynamic> payload = rawPayload;

        biome = Biome.biomeList[payload["biome"]];
    }
}