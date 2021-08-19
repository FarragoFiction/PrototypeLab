import "package:CommonLib/Workers.dart";

import 'world/dungeon.dart';

class TileWorker extends WorkerBase {

    late final Dungeon dungeon;

    TileWorker() {
        print("Loaded tile generation worker");
    }

    @override
    Future<dynamic> handleCommand(String command, dynamic payload) async {
        switch(command) {
            case WorkerCommands.initialise:
                return init(payload);
            case WorkerCommands.generate:
                return generateTile(payload);
        }

        return null;
    }

    void init(int seed) {
        dungeon = new Dungeon(0,0, seed, isWorker: true);
    }

    Future<Map<String,dynamic>> generateTile(dynamic payload) async {
        final Map<dynamic,dynamic> payloadMap = payload;

        final int x = payloadMap["x"]!;
        final int y = payloadMap["y"]!;

        final DungeonTile tile = new DungeonTile(dungeon, x, y, isWorker: true);

        await tile.generate();

        return tile.serialise();
    }
}

void main() {
    new TileWorker();
}