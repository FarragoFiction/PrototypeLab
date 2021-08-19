
import "dart:collection";

import "main.dart";

int hashPair(int x, int y) {
    int hash = 31;
    hash = ((hash + x) << 13) - (hash + x);
    hash = ((hash + y) << 13) - (hash + y);
    return hash;
}

class CoordPair {
    final int x;
    final int y;

    const CoordPair(int this.x, int this.y);

    @override
    int get hashCode  => hashPair(x, y);

    @override
    bool operator ==(Object other) {
        if (other is CoordPair) {
            return (x == other.x) && (y == other.y);
        }
        return false;
    }

    @override
    String toString() => "($x,$y)";
}

class CoordCache<T extends CoordPair> {
    int collisions = 0;
    final int size;
    final LinkedHashMap<int, T> map = new LinkedHashMap<int, T>();

    CoordCache(int this.size);

    void add(T item) {
        if (map.length >= size) {
            map.remove(map.keys.first);
        }
        map[hashPair(item.x, item.y)] = item;
    }

    T? get(int x, int y) {
        final T? item = map[hashPair(x, y)];

        if (item != null) {
            if (item.x != x || item.y != y) {
                collisions++;
                return null;
            }
        }

        return item;
    }
}

class ValueCoord<T> extends CoordPair {
    final T value;

    ValueCoord(int x, int y, T this.value) : super(x,y);
}

class ValueCache<T> extends CoordCache<ValueCoord<T>> {
    ValueCache(int size) : super(size);

    void addValue(int x, int y, T value) => add(new ValueCoord<T>(x, y, value));
    T? getValue(int x, int y) => get(x,y)?.value;
}