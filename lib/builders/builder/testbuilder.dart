import "package:build/build.dart";
import "package:glob/glob.dart";
import "package:path/path.dart" as p;

class TestBuilder extends Builder {
    static final Glob _inputAsset = new Glob("web/builders/**");

    static AssetId _outputAsset(BuildStep buildStep) {
        return new AssetId(buildStep.inputId.package, p.join("lib", "test.txt"));
    }

    @override
    Map<String, List<String>> get buildExtensions {
        return const <String,List<String>>{
            //r'$lib$': <String>["test.txt"]
            ".level": <String>[".txt"]
        };
    }

    @override
    Future<void> build(BuildStep buildStep) async {
        //log.warning("TestBuilder run on $buildStep");
        /*final List<String> files = <String>[];

        await for(final AssetId input in buildStep.findAssets(_inputAsset)) {
            log.warning(input.path);
            files.add(input.path);
        }*/

        //final AssetId output = _outputAsset(buildStep);
        final AssetId input = buildStep.inputId;

        log.warning("TestBuilder run on ${input.path}");

        final AssetId output = input.changeExtension(".txt");

        return buildStep.writeAsString(output, "poot");

    }
}