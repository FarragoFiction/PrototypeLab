import "dart:html";

Element output = querySelector("#stuff");

void main() {
    final Worker worker = new Worker("testworker.worker.dart.js");

    worker.postMessage("hi");

    worker.onMessage.listen((MessageEvent e) => print(e.data));
}
