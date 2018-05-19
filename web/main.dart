import "dart:html";

import "package:CommonLib/Random.dart";

import "graph/graph.dart";

Element output = querySelector("#stuff");

void main() {
    print("It begins!");

    Graph graph = randomGraph(30); //basicGraph();

    output.append(graph.drawGraph());
}

Graph basicGraph() {
    Graph graph = new Graph();

    GraphNode node1 = new GraphNode(); graph.add(node1);
    GraphNode node2 = new GraphNode(); graph.add(node2);
    GraphNode node3 = new GraphNode(); graph.add(node3);
    GraphNode node4 = new GraphNode(); graph.add(node4);
    GraphNode node5 = new GraphNode(); graph.add(node5);
    GraphNode node6 = new GraphNode(); graph.add(node6);
    GraphNode node7 = new GraphNode(); graph.add(node7);
    GraphNode node8 = new GraphNode(); graph.add(node8);
    GraphNode node9 = new GraphNode(); graph.add(node9);

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

Graph randomGraph(int nodecount, [int seed = null]) {
    Graph graph = new Graph();
    Random rand = new Random(seed);

    for (int i=0; i<nodecount; i++) {
        graph.add(new GraphNode());
    }

    Set<GraphNode> open = new Set<GraphNode>.from(graph.nodes);
    Set<GraphNode> closed = new Set<GraphNode>();
    GraphNode first = rand.pickFrom(open);
    open.remove(first);
    closed.add(first);

    while(!open.isEmpty) {
        GraphNode node = rand.pickFrom(open);
        open.remove(node);
        node.addChild(rand.pickFrom(closed));
        closed.add(node);
    }

    return graph;
}
