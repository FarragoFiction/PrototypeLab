import "dart:async";

import "package:CommonLib/Workers.dart";

class TestWorker extends WorkerBase {
    TestWorker() : super();

    @override
    Future<dynamic> handleCommand(String command, dynamic payload) async {
        print("message received in worker");

        switch(command) {
            case "test":
                final String message = payload;
                return "Worker reply: $message";

            case "error":
                throw Exception("deliberate exception");

            case "delay":
                final String message = payload;
                return new Future<String>.delayed(Duration(seconds: 2), () => "2 seconds later: $message");

            case "forever":
                final Completer<void> forever = new Completer<void>();
                return forever.future;
        }

        return null;
    }
}


void main() {
    new TestWorker();
}