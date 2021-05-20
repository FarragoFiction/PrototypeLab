import "package:build/build.dart";
import "package:glob/glob.dart";
import "package:path/path.dart" as p;

class TestBuilder extends Builder {
    @override
    Map<String, List<String>> get buildExtensions {
        return const <String,List<String>>{
            ".level": <String>[".txt"]
        };
    }

    @override
    Future<void> build(BuildStep buildStep) async {
        final AssetId input = buildStep.inputId;

        final String name = p.basenameWithoutExtension(input.path);
        final String directory = p.dirname(input.path);

        final String dataDir = <String>[...p.split(directory), "level_$name"].join("/");

        final Glob assetPath = new Glob("$dataDir/**");

        log.warning(assetPath);

        final List<String> files = <String>[];

        await for (final AssetId input in buildStep.findAssets(assetPath)) {
            final String rel = p.split(p.relative(input.path, from: dataDir)).join("/");
            log.warning(rel);
            files.add("$rel -> ${await buildStep.readAsString(input)}");
        }

        final AssetId output = input.changeExtension(".txt");

        await buildStep.writeAsString(output, files.join("\n"));
    }
}