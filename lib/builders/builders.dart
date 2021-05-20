
import "package:build/build.dart";

import "builder/testbuilder.dart";

Builder testBuilder(BuilderOptions options) {
    //log.warning("Instantiate TestBuilder");
    return new TestBuilder();
}

PostProcessBuilder testCleanup(BuilderOptions options) {
    return new FileDeletingBuilder(<String>[""], isEnabled: (options.config["enabled"] as bool?) ?? false);
}