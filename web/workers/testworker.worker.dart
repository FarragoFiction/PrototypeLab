import "dart:html";

void main() {
    print("worker loaded");

    final DedicatedWorkerGlobalScope scope = DedicatedWorkerGlobalScope.instance;

    scope.onMessage.listen((MessageEvent e) {
        print("message received in worker");

        scope.postMessage("worker message return: ${e.data}");
    });
}