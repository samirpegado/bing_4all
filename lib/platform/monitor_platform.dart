class MonitorInfo {
  const MonitorInfo({
    required this.id,
    required this.name,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final bool isPrimary;
}

abstract class MonitorPlatform {
  Future<List<MonitorInfo>> listMonitors();

  static MonitorPlatform create() => const LinuxMonitorPlatform();
}

class LinuxMonitorPlatform implements MonitorPlatform {
  const LinuxMonitorPlatform();

  @override
  Future<List<MonitorInfo>> listMonitors() async {
    // v1 applies to all monitors via DE APIs; detailed enumeration is v2+.
    return const [
      MonitorInfo(id: 'all', name: 'Todos os monitores', isPrimary: true),
    ];
  }
}
