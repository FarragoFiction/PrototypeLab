import "package:CommonLib/Collection.dart";


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

    Biome(String this.name, String this.colour) : id = _nextID++;
}