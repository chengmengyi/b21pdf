class AppEvent {
  int type;
  int? intValue;
  String? stringValue;
  bool? boolValue;
  AppEvent({
    required this.type,
    this.intValue,
    this.stringValue,
    this.boolValue,
  });
}
