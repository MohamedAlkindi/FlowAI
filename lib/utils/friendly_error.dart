String friendlyError(Object e) {
  final s = e.toString();
  return s.startsWith('Exception: ') ? s.replaceFirst('Exception: ', '') : s;
}
