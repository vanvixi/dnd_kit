import 'dart:io';

const _packages = [
  'packages/dnd_kit',
  'packages/dnd_kit_flutter',
  'packages/dnd_kit_jaspr',
];

Future<void> main(List<String> args) async {
  final root = _resolveRootDir();

  await _runCommand('dart', ['pub', 'get'], workingDirectory: root);
  await _runCommand(
    'fvm',
    ['dart', 'run', 'melos', 'run', 'validate'],
    workingDirectory: root,
  );

  for (final package in _packages) {
    final packageDir = _join(root, package);
    final result = await _publishDryRun(packageDir);

    stdout.write(result.output);

    if (result.exitCode == 0) {
      continue;
    }

    if (_isDirtyTreeWarningOnly(result.output)) {
      continue;
    }

    stderr.writeln(
      '[verify_family_release] $package failed publish dry-run with an '
      'unexpected error.',
    );
    exit(1);
  }

  stdout.writeln('[verify_family_release] All packages verified.');
}

/// Resolves the repository root as the parent of this script's `tool/`
/// directory so the script can be invoked from any working directory.
String _resolveRootDir() {
  final scriptFile = Platform.script.toFilePath();
  return File(scriptFile).parent.parent.absolute.path;
}

String _join(String base, String segment) {
  final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return '$normalizedBase/$segment';
}

Future<_DryRunResult> _publishDryRun(String packageDir) async {
  stdout.writeln('\$ (cd $packageDir && fvm dart pub publish --dry-run)');

  final result = await Process.run(
    'fvm',
    ['dart', 'pub', 'publish', '--dry-run'],
    workingDirectory: packageDir,
  );

  final output = '${result.stdout}${result.stderr}';
  return _DryRunResult(exitCode: result.exitCode, output: output);
}

/// Mirrors the legacy shell check: a dry-run failure is tolerated only when the
/// sole warning is the expected dirty git tree before commit.
bool _isDirtyTreeWarningOnly(String output) {
  return output.contains('checked-in files are modified in git') &&
      output.contains('Package has 1 warning.');
}

Future<void> _runCommand(
  String executable,
  List<String> args, {
  String? workingDirectory,
}) async {
  stdout.writeln('\$ $executable ${args.join(' ')}');

  final process = await Process.start(
    executable,
    args,
    workingDirectory: workingDirectory,
  );
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    exit(exitCode);
  }
}

class _DryRunResult {
  _DryRunResult({
    required this.exitCode,
    required this.output,
  });

  final int exitCode;
  final String output;
}
