import "package:CommonLib/Collection.dart";

import 'tile.dart';

typedef BiomeConnectionGenerator = Iterable<BiomeConnection> Function(int x, int y, bool rightEdge);

class Biome {
    static final WeightedList<Biome> biomeList = new WeightedList<Biome>();

    static int _nextID = 0;
    static void initBiomes() {
        biomeList.add(new Biome("Test Biome 1", "#709070"), 1.0);
        biomeList.add(new Biome("Test Biome 2", "#909070"), 0.5);
        biomeList.add(new Biome("Test Biome 3", "#907070"), 0.5);
        biomeList.add(new Biome("Test Biome 4", "#709090"), 0.05);
    }

    final int id;
    final String name;
    final String colour;

    final Map<Biome, BiomeConnectionGenerator> connectionGenerators = <Biome, BiomeConnectionGenerator>{};

    Biome(String this.name, String this.colour) : id = _nextID++;

    BiomeConnectionGenerator getConnectionForBiome(Biome otherBiome) => connectionGenerators[otherBiome] ?? BiomeConnection.defaultConnection;
}

class BiomeConnection {
    final double position;
    final double size;

    BiomeConnection(num position, num size): this.position = position.toDouble(), this.size = size.toDouble();

    static Iterable<BiomeConnection> defaultConnection(int x, int y, bool rightEdge) sync* {
        yield new BiomeConnection(DungeonTile.halfSize, 10);
    }
}