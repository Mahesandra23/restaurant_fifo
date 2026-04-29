extension ObjectWidgetExt<T> on T? {
  bool isNull() {
    return this == null;
  }

  bool isNotNull() {
    return this != null;
  }
}
