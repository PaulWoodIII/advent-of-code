import 'core/registry.dart';
import 'core/run.dart';
import 'years/year2024/registry.dart' as y2024;
import 'years/year2025/registry.dart' as y2025;

SolverRunner createRunner() {
  final registry = SolverRegistry();
  y2024.registerYear2024(registry);
  y2025.registerYear2025(registry);
  return SolverRunner(registry: registry);
}
