import "dart:html";
import "dart:math" as Math;

import "package:CommonLib/Utility.dart";

class Graph {

    Set<GraphNode> nodes;
    List<List<GraphNode>> _layers;

    Graph() {
        nodes = new Set<GraphNode>();
    }

    bool add(GraphNode node) => nodes.add(node);
    bool remove(GraphNode node) => nodes.remove(node);

    Element drawGraph() {
        Element container = new DivElement();

        _calculateDepth();
        _sortIntoLayers();

        int i = 0;
        for (GraphNode node in nodes) {
            i++;
            Element e = node.createElement();
            e.style
                ..position="absolute"
                ..left = "${20 + 200 * node.depth}px"
                ..top = "${40 * node.position}px";
            container.append(e);
        }

        return container;
    }

    void _sortIntoLayers() {
        int count = 0;
        for (GraphNode node in nodes) {
            count = Math.max(count, node.depth);
        }

        _layers = new List<List<GraphNode>>(count+1);
        for (int i=0; i<count+1; i++) {
            _layers[i] = <GraphNode>[];
        }

        for (GraphNode node in nodes) {
            _layers[node.depth].add(node);
        }
        int size = 0;
        for (List<GraphNode> layer in _layers) {
            size = Math.max(size, layer.length);
        }

        for (List<GraphNode> layer in _layers) {
            bool flop = false;
            while(layer.length < size) {
                flop = !flop;
                if (flop) {
                    layer.add(new DummyGraphNode());
                } else {
                    layer.insert(0, new DummyGraphNode());
                }
            }
            //layer.shuffle();
            for (int i=0; i < size; i++) {
                layer[i]..position = i..layersize = size;
            }
        }

        int iter = 0;
        bool done = false;
        while (!done) {
            iter++;
            if (iter > 100) { break; }
            //print("Start #################################################################################################");
            for (List<GraphNode> layer in _layers) {
                //print("Layer ------------------");
                for (int i=0; i < size; i++) {
                    layer[i].position = i;
                }

                layer.sort((GraphNode a, GraphNode b) {
                    double na = a.averagepos();
                    double nb = b.averagepos();
                    //print("a${a is DummyGraphNode ? "D" : ""}: $na, b${b is DummyGraphNode ? "D" : ""}: $nb");
                    return na.compareTo(nb);
                });
            }
        }

        for (List<GraphNode> layer in _layers) {
            for (int i=0; i < size; i++) {
                layer[i].position = i;
                //print(i);
            }
        }
    }

    void _calculateDepth() {
        for (GraphNode node in nodes) {
            node.depth = 0;
        }

        Set<GraphNode> open = new Set<GraphNode>();
        Set<GraphNode> closed = new Set<GraphNode>();
        int lowest = 0;
        open.add(nodes.first);
        GraphNode node;

        while (!open.isEmpty) {
            node = open.first;
            open.remove(node);
            closed.add(node);

            lowest = Math.min(node.depth, lowest);

            for (GraphNode n in node.parents) {
                if (!closed.contains(n)) {
                    open.add(n);
                    n.depth = node.depth - 1;
                }
            }

            for (GraphNode n in node.children) {
                if (!closed.contains(n)) {
                    open.add(n);
                    n.depth = node.depth + 1;
                }
            }
        }

        for (GraphNode n in nodes) {
            n.depth -= lowest;
        }
    }
}

class GraphNode {
    Set<GraphNode> parents = new Set<GraphNode>();
    Set<GraphNode> children = new Set<GraphNode>();

    int depth = 0;
    int position = 0;
    int layersize = 0;

    Element createElement() => new DivElement()
        ..style.border="1px solid black"
        ..style.padding="5px"
        ..text="0x${this.hashCode.toRadixString(16).padLeft(8,"0")}";

    void addChild(GraphNode node) {
        children.add(node);
        node.parents.add(this);
    }
    void removeChild(GraphNode node) {
        children.remove(node);
        node.parents.remove(this);
    }

    double averagepos() {
        double dpos = this.position / layersize;
        double ppos = parents.isEmpty ? -1 : joinCollection(parents, convert:(GraphNode n) => n.position / n.layersize, combine:(double a, double b) => a+b) / parents.length;
        double cpos = children.isEmpty ? -1 : joinCollection(children, convert:(GraphNode n) => n.position / n.layersize, combine:(double a, double b) => a+b) / children.length;

        double pweight = parents.isEmpty ? 0.0 : 0.3;
        double cweight = children.isEmpty ? 0.0 : 0.5;
        double posweight = 0.2;

        double totalweight = pweight + cweight + posweight;
        pweight /= totalweight;
        cweight /= totalweight;
        posweight /= totalweight;

        //print("dpos: $dpos, ppos: $ppos, cpos: $cpos (p: ${parents.length}, c: ${children.length})");

        return ppos * pweight + cpos * cweight + dpos * posweight;
    }
}

class DummyGraphNode extends GraphNode {
    @override
    double averagepos() {
        double pos = position / layersize;
        return pos - (pos < 0.5 ? -0.1 : 0.1);
    }
}