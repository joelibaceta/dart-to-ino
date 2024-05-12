import 'package:kernel/ast.dart' as kernel;

void main() async {
  final kernelComponent = await loadKernel('hello.dart');
  String cppCode = convertKernelToCpp(kernelComponent);
  print(cppCode);
}

String convertKernelToCpp(kernel.Component component) {
  StringBuffer buffer = StringBuffer();

  for (var library in component.libraries) {
    buffer.writeln('// Library: ${library.importUri}');
    for (var class_ in library.classes) {
      buffer.writeln('class ${class_.name} {');
      for (var procedure in class_.procedures) {
        buffer.writeln('  ${generateFunction(procedure)}');
      }
      buffer.writeln('};');
    }

    for (var procedure in library.procedures) {
      buffer.writeln(generateFunction(procedure));
    }
  }

  return buffer.toString();
}

String generateFunction(kernel.Procedure procedure) {
  var returnType = 'void';
  if (procedure.function.returnType is kernel.VoidType) {
    returnType = 'void';
  } else if (procedure.function.returnType is kernel.IntType) {
    returnType = 'int';
  }

  var functionName = procedure.name.name;
  var parameters = procedure.function.positionalParameters
      .map((param) => 'int ${param.name}')
      .join(', ');

  var body = generateBody(procedure.function.body);

  return '$returnType $functionName($parameters) {\n$body\n}';
}

String generateBody(kernel.Statement body) {
  if (body is kernel.ReturnStatement) {
    var expression = body.expression;
    if (expression is kernel.MethodInvocation) {
      var left = (expression.receiver as kernel.VariableGet).variable.name;
      var right = (expression.arguments.positional[0] as kernel.VariableGet).variable.name;
      return '  return $left + $right;';
    }
  }
  return '';
}