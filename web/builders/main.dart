import "dart:html";

import "package:LoaderLib/Loader.dart";

Element output = querySelector("#stuff")!;

Future<void> main() async {
    print("hi");

    final String text = await Loader.getResource("builders/testfiles/test1.txt");

    output.setInnerHtml(text.replaceAll("\n", "<br>"));
}
