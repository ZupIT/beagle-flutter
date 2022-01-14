import 'package:beagle/beagle.dart';

abstract class LocalContextsManager {
  LocalContext? getContext(String id);

  void setContext(String id, dynamic value, [String? path]);

  List<BeagleDataContext> getAllAsDataContext();

  BeagleDataContext? getContextAsDataContext(String id);

  void removeContext(String id);

  void clearAll();
}
