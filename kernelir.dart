import 'dart:io';
import 'package:kernel/kernel.dart' as kernel;
import 'package:front_end/src/api_prototype/front_end.dart' as fe;
import 'package:front_end/src/api_prototype/standard_file_system.dart';
import 'package:front_end/src/api_unstable/vm.dart' show CompilerOptions, Verbosity;

Future<kernel.Component> loadKernel(String source) async {
  final options = CompilerOptions()
    ..sdkRoot = Uri.base.resolve('path/to/sdk/')
    ..fileSystem = StandardFileSystem.instance
    ..compileSdk = true
    ..verbosity = Verbosity.verbose;

  final input = fe.InputData(source, await File(source).readAsString());
  return fe.compileToKernel(input, options);
}

void main() async {
  final kernelComponent = await loadKernel('hello.dart');
  printKernel(kernelComponent);
}

void printKernel(kernel.Component component) {
  for (var library in component.libraries) {
    print('Library: ${library.importUri}');
    for (var procedure in library.procedures) {
      print('Procedure: ${procedure.name}');
    }
  }
}