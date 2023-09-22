import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:sd_kids/util/constants.dart' as Constants;
import 'package:sd_kids/util/locator.dart';
import 'package:sd_kids/viewModel/EventListViewModel.dart';
import 'package:sd_kids/viewModel/FoodDealListViewModel.dart';
import 'package:sd_kids/viewModel/ParksAndPoolsListViewModel.dart';
import 'package:sd_kids/viewModel/RecCenterListViewModel.dart';
import 'package:sd_kids/viewModel/ResourcesListViewModel.dart';
import 'package:sd_kids/viewModel/SchoolsListViewModel.dart';
import 'package:sd_kids/viewModel/ThingsToDoListViewModel.dart';
import 'NavDrawer.dart';

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  final fcmToken = await messaging.getToken();
  Constants.myFcmToken = fcmToken!;

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Message also contained a notification: '
          '${"${message.notification!.title!}\n${message.notification!.body!}"}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("${message.notification!.title!}\n${message.notification!.body!}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupFirebaseMessaging();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => EventListViewModel()),
          ChangeNotifierProvider(create: (context) => ThingsToDoListViewModel()),
          ChangeNotifierProvider(create: (context) => FoodDealListViewModel()),
          ChangeNotifierProvider(create: (context) => ParksAndPoolsListViewModel()),
          ChangeNotifierProvider(create: (context) => RecCenterListViewModel()),
          ChangeNotifierProvider(create: (context) => ResourcesListViewModel()),
          ChangeNotifierProvider(create: (context) => SchoolsListViewModel()),
        ],
        child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, ThemeMode currentMode, __) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                      appBarTheme: AppBarTheme(
                          color: Colors.blue,
                          titleTextStyle: TextStyle(color: themeNotifier.value == ThemeMode.light
                              ? Colors.white
                              : Colors.black,),
                          iconTheme: IconThemeData(color: Colors.white)),
                      scaffoldBackgroundColor: Colors.white,
                      colorScheme: const ColorScheme.light(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                      ),
                      buttonTheme:
                          const ButtonThemeData(buttonColor: Colors.red),

                      useMaterial3: true),
                  darkTheme: ThemeData(
                      appBarTheme: const AppBarTheme(
                          color: Colors.blue,
                          titleTextStyle: TextStyle(color: Colors.white),
                          iconTheme: IconThemeData(color: Colors.white)),
                      scaffoldBackgroundColor: Color(0xFF00172D),
                      colorScheme: const ColorScheme.dark(
                          primary: Colors.blue, onPrimary: Colors.white),
                      buttonTheme:
                          const ButtonThemeData(buttonColor: Colors.blue),
                      bottomSheetTheme: const BottomSheetThemeData(
                          modalBackgroundColor: Color(0xFF23395D)),
                      useMaterial3: true),
                  themeMode: currentMode,
                  home: NavDrawer(),
                  );
            }));
  }
}

class NavRoutes {
  static const eventsRoute = 'events';
  static const eventDetailsRoute = 'event_detail';
  static const recCentersRoute = 'rec_centers';
  static const recCenterDetailsRoute = 'rec_center_details';
  static const parksAndPoolsRoute = 'parks_and_pools';
  static const parkAndPoolDetailsRoute = 'park_and_pool_details';
  static const foodDealsRoute = 'food_deals';
  static const foodDealDetailsRoute = 'food_deal_detail';
  static const thingsToDoRoute = 'things_to_do';
  static const thingToDoDetailsRoute = 'thing_to_do_details';
  static const schoolsRoute = 'schools';
  static const schoolDetailsRoute = 'school_details';
  static const resourcesRoute = 'resources';
  static const resourceDetailsRoute = 'resource_details';
  static const submitEventRoute = 'submit_event';
}
