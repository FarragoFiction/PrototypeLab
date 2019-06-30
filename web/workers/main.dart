import "dart:html";

import "package:CommonLib/Workers.dart";

Element output = querySelector("#stuff");

void main() {
    /*final Worker worker = new Worker("testworker.worker.dart.js");

    worker.postMessage("hi");

    worker.onMessage.listen((MessageEvent e) => print(e.data));*/

    final WorkerHandler worker = createWebWorker("testworker.worker.dart");

    worker.sendMessage("test", "hi!");

    worker.listen((String label, dynamic payload) => print(payload));
}
