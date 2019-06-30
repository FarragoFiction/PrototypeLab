import "dart:html";

import "package:CommonLib/Workers.dart";

class TestWorker extends WorkerBase {
    TestWorker() : super();

    @override
    void handleMainThreadMessage(String label, dynamic payload) {
        print("message received in worker");

        sendMainThreadMessage("test", "worker message return: $payload");
    }
}


void main() {
    new TestWorker();

    /*print("worker loaded");

    final DedicatedWorkerGlobalScope scope = DedicatedWorkerGlobalScope.instance;

    scope.onMessage.listen((MessageEvent e) {
        print("message received in worker");

        scope.postMessage("worker message return: ${e.data}");
    });*/
}