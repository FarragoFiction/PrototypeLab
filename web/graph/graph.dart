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


        _calculateDepth();
        Tuple<int,int> dim = _sortIntoLayers();

        int layers = dim.first;
        int layerwidth = dim.second;
        int xgap = 80;
        int ygap = 10;

        List<int> depths = new List<int>.filled(layers+1, 0);
        int width = 0;
        
        for (GraphNode node in nodes) {
            CanvasElement img = node.getImage();
            if (img == null) { continue; }
            
            width = Math.max(width, img.height);
            depths[node.depth] = Math.max(depths[node.depth], img.width);
        }
        
        int graphwidth = joinCollection(depths, convert: (int i) => i, combine: (int a, int b) => a+b) + xgap * (layers + 1);
        int graphheight = width * layerwidth + ygap * (layerwidth + 1);

        CanvasElement canvas = new CanvasElement(width: graphwidth, height: graphheight);
        CanvasRenderingContext2D ctx = canvas.context2D;

        for (GraphNode node in nodes) {
            CanvasElement img = node.getImage();
            if (img == null) { continue; }

            Tuple<int,int> pos = _drawPos(node, xgap, ygap, depths, width);
            int x = pos.first;
            int y = pos.second;

            ctx.drawImage(node.getImage(), x,y);

            for (GraphNode child in node.children) {
                CanvasElement cimg = child.getImage();
                if (cimg == null) { continue; }

                num px = x + img.width;
                num py = y + img.height * 0.5;

                Tuple<int,int> cpos = _drawPos(child, xgap, ygap, depths, width);

                num cx = cpos.first;
                num cy = cpos.second + cimg.height * 0.5;

                ctx
                    ..beginPath()
                    ..moveTo(px, py)
                    ..lineTo(cx, cy)
                    ..stroke();
            }
        }

        return canvas;
    }

    void _drawNode(CanvasRenderingContext2D ctx, GraphNode node, int xgap, int ygap, List<int> depths, int width) {
        Tuple<int,int> pos = _drawPos(node, xgap, ygap, depths, width);

        ctx.drawImage(node.getImage(), pos.first, pos.second);
    }

    Tuple<int,int> _drawPos(GraphNode node, int xgap, int ygap, List<int> depths, int width) {
        int x = xgap;
        for (int i=0; i<node.depth; i++) {
            x += depths[i] + xgap;
        }
        int y = node.position * (width + ygap);

        return new Tuple<int,int>(x,y);
    }

    Tuple<int,int> _sortIntoLayers() {
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
        int moves;
        bool done = false;
        while (!done) {
            moves = 0;
            print("Loop $iter");
            iter++;
            if (iter > 1000) { break; }
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

                    int comparison = na.compareTo(nb);

                    if (comparison != 0) {
                        //print("${a.name()} vs ${b.name()}: $comparison");
                        moves++;
                    }

                    return comparison;
                });
            }
            print("moves: $moves");
        }

        for (List<GraphNode> layer in _layers) {
            for (int i=0; i < size; i++) {
                layer[i].position = i;
                //print(i);
            }
        }

        return new Tuple<int,int>(count, size);
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

    CanvasElement _image;

    CanvasElement getImage() {
        draw();
        return _image;
    }

    void draw() {
        if (_image != null) { return; }

        int w = 75;
        int h = 30;

        CanvasElement canvas = new CanvasElement(width: w, height: h);
        _image = canvas;

        CanvasRenderingContext2D ctx = canvas.context2D;

        ctx
            ..fillStyle="#FFFFFF"
            ..fillRect(0, 0, w, h)
            ..strokeStyle="#000000"
            ..strokeRect(0.5, 0.5, w-1, h-1)
            ..fillStyle="#000000"
            ..fillText(name(), 10, 18);
    }

    void addChild(GraphNode node) {
        children.add(node);
        node.parents.add(this);
    }
    void removeChild(GraphNode node) {
        children.remove(node);
        node.parents.remove(this);
    }

    double averagepos() {
        double dpos = this.position.toDouble();
        double ppos = parents.isEmpty ? -1 : joinCollection(parents, convert:(GraphNode n) => n.position.toDouble(), combine:(double a, double b) => a+b) / parents.length;
        double cpos = children.isEmpty ? -1 : joinCollection(children, convert:(GraphNode n) => n.position.toDouble(), combine:(double a, double b) => a+b) / children.length;

        double pweight = parents.isEmpty ? 0.0 : 0.3;
        double cweight = children.isEmpty ? 0.0 : 0.6;
        double posweight = 0.0;

        double totalweight = pweight + cweight + posweight;
        pweight /= totalweight;
        cweight /= totalweight;
        posweight /= totalweight;

        //print("dpos: $dpos, ppos: $ppos, cpos: $cpos (p: ${parents.length}, c: ${children.length})");

        return ppos * pweight + cpos * cweight + dpos * posweight;
    }

    String name() => "0x${this.hashCode.toRadixString(16).padLeft(8, "0")}";
}

class DummyGraphNode extends GraphNode {
    @override
    CanvasElement getImage() => null;

    @override
    double averagepos() {
        double pos = position.toDouble();
        return pos;// - (pos < 0.5 ? -0.1 : 0.1);
    }

    @override
    String name() => "D ${super.name()}";
}