import "dart:html";

import "graph/graph.dart";

Element output = querySelector("#stuff");

void main() {
    print("It begins!");

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

    output.append(graph.drawGraph());
}
