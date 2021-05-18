import "dart:html";

import "package:CommonLib/Random.dart";

import "graph/graph.dart";

Element output = querySelector("#stuff")!;

void main() {
    /*print("It begins!");

    final Graph graph = randomShipGraph(4, 10, 3);//randomGraph(30);//, 1); //basicGraph();

    print("graph made, drawing");

    output.append(graph.drawGraph());*/
}

/*Graph basicGraph() {
    final Graph graph = new Graph();

    final GraphNode node1 = new GraphNode(); graph.add(node1);
    final GraphNode node2 = new GraphNode(); graph.add(node2);
    final GraphNode node3 = new GraphNode(); graph.add(node3);
    final GraphNode node4 = new GraphNode(); graph.add(node4);
    final GraphNode node5 = new GraphNode(); graph.add(node5);
    final GraphNode node6 = new GraphNode(); graph.add(node6);
    final GraphNode node7 = new GraphNode(); graph.add(node7);
    final GraphNode node8 = new GraphNode(); graph.add(node8);
    final GraphNode node9 = new GraphNode(); graph.add(node9);

    node1.addChild(node2);
    node2.addChild(node3);
    node4.addChild(node3);
    node7.addChild(node3);
    node8.addChild(node3);
    node9.addChild(node3);
    node3.addChild(node5);
    node3.addChild(node6);

    return graph;
}

Graph randomGraph(int nodecount, [int? seed]) {
    final Graph graph = new Graph();
    final Random rand = new Random(seed);

    for (int i=0; i<nodecount; i++) {
        graph.add(new GraphNode());
    }

    final Set<GraphNode> open = new Set<GraphNode>.from(graph.nodes);
    final Set<GraphNode> closed = <GraphNode>{};
    final GraphNode first = rand.pickFrom(open)!;
    open.remove(first);
    closed.add(first);

    while(!open.isEmpty) {
        final GraphNode node = rand.pickFrom(open)!;
        open.remove(node);
        node.addChild(rand.pickFrom(closed)!);
        closed.add(node);
    }

    return graph;
}

Graph randomShipGraph(int layers, int countperlayer, int shipcount, [int? seed]) {
    final Graph graph = new Graph();
    final Random rand = new Random(seed);

    late List<GraphNode> ships;

    int loop_countperlayer;
    int loop_shipcount;

    for (int layer = 0; layer<layers; layer++) {
        loop_countperlayer = layer == 0 ? 2 : countperlayer;
        loop_shipcount = layer == 0 ? 1 : shipcount;

        final List<GraphNode> layernodes = <GraphNode>[];
        for (int i=0; i<loop_countperlayer; i++) {
            final GraphNode n = new GraphNode();
            layernodes.add(n);
            graph.add(n);
        }

        if (layer != 0) {
            for (final GraphNode n in layernodes) {
                rand.pickFrom(ships)!.addChild(n);
            }
        }

        ships = <GraphNode>[];
        if (layer != layers-1) {
            for (int i=0; i<loop_shipcount; i++) {
                final GraphNode ship = new GraphNode();
                ships.add(ship);
                graph.add(ship);

                final GraphNode parent1 = rand.pickFrom(layernodes)!;
                parent1.addChild(ship);
                final GraphNode parent2 = rand.pickFrom(layernodes.where((GraphNode n) => n != parent1))!;
                parent2.addChild(ship);
            }
        }/* else {
            GraphNode end = new GraphNode();
            graph.add(end);
            for (GraphNode n in layernodes) {
                n.addChild(end);
            }
        }*/
    }

    return graph;
}*/
