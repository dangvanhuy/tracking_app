import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tracker_run/app/data/local/best_record.dart';
import 'package:tracker_run/app/database/database_local.dart';
import 'package:tracker_run/app/modules/login/model/login_model.dart';
import 'package:tracker_run/app/modules/tracking-drink_water/drinkWaterReminder/models/Preference.dart';
import 'package:tracker_run/app/modules/tracking-drink_water/models/app_prefs.dart';
import 'package:tracker_run/app/modules/tracking_step/model/step_tracking_day.dart';
import 'package:tracker_run/generated/locales.g.dart';

import 'app/modules/tracking_map_v2/model/data_model_strava.dart';
import 'app/modules/tracking_map_v2/model/streamdata.dart';
import 'app/routes/app_pages.dart';

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// // this will be used as notification channel id
// const notificationChannelId = 'my_foreground';

// // this will be used for notification id, So you can update your custom notification with this id.
// const notificationId = 888;

// Future<void> onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 1), (timer) async {

//     if (service is ServiceInstance) {
//       flutterLocalNotificationsPlugin.show(
//         notificationId,
//         'TestBackground SERVICE',
//         'Awesome ${DateTime.now()}',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             notificationChannelId,
//             'MY FOREGROUND SERVICE',
//             icon: 'ic_bg_service_small',
//             ongoing: true,
//           ),
//         ),
//       );
//       if (await service is AndroidForegroundService) {
//         flutterLocalNotificationsPlugin.show(
//           notificationId,
//           'COOL SERVICE',
//           'Awesome ${DateTime.now()}',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               notificationChannelId,
//               'MY FOREGROUND SERVICE',
//               icon: 'ic_bg_service_small',
//               ongoing: true,
//             ),
//           ),
//         );
//       }
//     }
//   });
// }

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     notificationChannelId, // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,

//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,

//       notificationChannelId:
//           notificationChannelId, // this must match with notification channel you created above.
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: notificationId,
//     ),
//     iosConfiguration: IosConfiguration(),
//   );
// }


String? selectedNotificationPayload;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {

  HttpOverrides.global = new PostHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await Preference().instance();
  Directory dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter<DataModelStrava>(DataModelStravaAdapter());
  Hive.registerAdapter<MapClass>(MapClassAdapter());
  Hive.registerAdapter<SplitsMetric>(SplitsMetricAdapter());
  Hive.registerAdapter<LoginModel>(LoginModelAdapter());
  Hive.registerAdapter<BestRecord>(BestRecordAdapter());
  Hive.registerAdapter<StreamData>(StreamDataAdapter());
  Hive.registerAdapter<StepTrackingDay>(StepTrackingDayAdapter());

  await AppPrefs.instance.initListener();
  tz.initializeTimeZones();
  var detroit = tz.getLocation('Asia/Bangkok');
  tz.setLocalLocation(detroit);
  Locale language = await DatabaseLocal.instance.getLocale();


  runApp(
    GetMaterialApp(
      translationsKeys: AppTranslation.translations,
      title: "Application",
      locale: language,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
