import "dart:html";

import "package:CommonLib/Workers.dart";

Element output = querySelector("#stuff");

Future<void> main() async {
    final WorkerHandler worker = createWebWorker("testworker.worker.dart");

    worker.sendCommand<void>("forever").then((void v) => print("forever returned somehow?"));

    worker.sendCommand("error").catchError((dynamic error) => print("error: $error"));

    worker.sendCommand<String>("delay", payload: "hello").then((String s) => print("test: $s"));

    worker.sendCommand<String>("test", payload: "hello").then((String s) => print("test: $s"));

    doSomething(TestEnum.poot);
}

void doSomething<T>(T value) {
    dynamic v = value;
    print(v.index);
    print(value.runtimeType);
    dynamic t = T;
    print(t.values);
}

enum TestEnum {
    poot,
    boot
}