// import 'package:bubonelka/const_parameters.dart';
// import 'package:bubonelka/utilites/csv_data_manager.dart';
// import 'package:flutter/widgets.dart';

// class AppLifecycleObserver with WidgetsBindingObserver {
//   static void init() {
//     WidgetsBinding.instance.addObserver(AppLifecycleObserver());
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       CsvDataManager.getInstance().uploadCsvData(noPath);
//       // SettingsAndStateManager().saveSettingsAndState();
//     }
//   }
// }
