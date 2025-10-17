int asInt(dynamic v, {int defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? defaultValue;
  return defaultValue;
}

num asNum(dynamic v, {num defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? defaultValue;
  return defaultValue;
}

String asString(dynamic v, {String defaultValue = ""}) {
  if (v == null) return defaultValue;
  return v.toString();
}
