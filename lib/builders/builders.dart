
import "package:build/build.dart";

import "builder/testbuilder.dart";

Builder testBuilder(BuilderOptions options) {
    //log.warning("Instantiate TestBuilder");
    return new TestBuilder();
}