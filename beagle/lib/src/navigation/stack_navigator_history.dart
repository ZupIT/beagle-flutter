import 'package:beagle/beagle.dart';

class StackNavigatorHistory {
  String routeName;
  LocalContextsManager viewLocalContextsManager;
  Function render;

  StackNavigatorHistory(this.routeName, this.viewLocalContextsManager, this.render);
}
