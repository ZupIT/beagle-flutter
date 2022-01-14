class NavigationContext {
  final String? path;
  final dynamic value;

  NavigationContext(this.value, this.path);

  factory NavigationContext.fromJson(Map<String, dynamic>? json) {
    return NavigationContext(json?['value'], json?['path']);
  }
}
