import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/screens/events/EventDetailScreen.dart';
import 'package:sd_kids/screens/events/EventsListScreen.dart';
import 'package:sd_kids/screens/food_deals/FoodDealDetailScreen.dart';
import 'package:sd_kids/screens/food_deals/FoodDealListScreen.dart';
import 'package:sd_kids/screens/parks_and_pools/ParksAndPoolsDetailScreen.dart';
import 'package:sd_kids/screens/parks_and_pools/ParksAndPoolsListScreen.dart';
import 'package:sd_kids/screens/rec_centers/RecCenterDetailsScreen.dart';
import 'package:sd_kids/screens/rec_centers/RecCentersListScreen.dart';
import 'package:sd_kids/screens/resources/ResourceDetailScreen.dart';
import 'package:sd_kids/screens/resources/ResourcesListScreen.dart';
import 'package:sd_kids/screens/schools/SchoolDetailScreen.dart';
import 'package:sd_kids/screens/schools/SchoolsListScreen.dart';
import 'package:sd_kids/screens/things_to_do/ThingsToDoDetailScreen.dart';
import 'package:sd_kids/screens/things_to_do/ThingsToDoListScreen.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> with TickerProviderStateMixin {
  final navKey = GlobalKey<NavigatorState>();
  bool selected = false;
  late HeroController _heroController;
  late AnimationController _animationControler;
  late AnimationController _animControler;
  late Animation heightAnimation;
  late Animation animation;
  late Animation scaleAnimation;
  late Animation roundCornerAnimation;

  @override
  void initState() {
    _heroController = HeroController();
    _animationControler = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(() {
        setState(() {});
      });
    _animControler = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..addListener(() {
        setState(() {});
      });
    heightAnimation = Tween<double>(begin: 1, end: .15).animate(
        CurvedAnimation(parent: _animControler, curve: Curves.easeInOut));
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationControler, curve: Curves.fastOutSlowIn));
    scaleAnimation = Tween<double>(begin: 1, end: .9).animate(CurvedAnimation(
        parent: _animationControler, curve: Curves.fastOutSlowIn));
    roundCornerAnimation = Tween<double>(begin: 0, end: 20).animate(
        CurvedAnimation(
            parent: _animationControler, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  bool _isAppBarWithNav = true;

  void appBarChange() {
    setState(() {
      print('change app bar');
      _isAppBarWithNav = !_isAppBarWithNav;
    });
  }

  AppBar _appBarWithNav(BuildContext context, Function changeAppBar) {
    return AppBar(
      title: Text(
        'SD Kids',
        style: TextStyle(
            color: MyApp.themeNotifier.value == ThemeMode.light
                ? Colors.white
                : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: MyApp.themeNotifier.value == ThemeMode.light
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            if (!selected)
              _animationControler.forward();
            else
              _animationControler.reverse();
            setState(() {
              selected = !selected;
            });
          }),
      actions: [
        IconButton(
            icon: Icon(
              MyApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: MyApp.themeNotifier.value == ThemeMode.light
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              MyApp.themeNotifier.value =
                  MyApp.themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            })
      ],
    );
  }

  AppBar _appBarWithBack(BuildContext context, Function changeAppBar) {
    return AppBar(
        title: Text(
          'SD Kids',
          style: TextStyle(
              color: MyApp.themeNotifier.value == ThemeMode.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: Icon(
                MyApp.themeNotifier.value == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: MyApp.themeNotifier.value == ThemeMode.light
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () {
                MyApp.themeNotifier.value =
                    MyApp.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              })
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: MyApp.themeNotifier.value == ThemeMode.light
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            appBarChange();
            navKey.currentState!.pop();
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (!_isAppBarWithNav) appBarChange();
          navKey.currentState!.maybePop();
          return false;
        },
        child: Scaffold(
            appBar: _isAppBarWithNav
                ? _appBarWithNav(context, appBarChange)
                : _appBarWithBack(context, appBarChange),
            body: selectedScreenStackOnDrawer()));
  }

  Widget selectedScreenStackOnDrawer() {
    return Container(
      color: Colors.blue.shade800,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.map,
                    color: MyApp.themeNotifier.value == ThemeMode.light
                        ? Colors.white
                        : Colors.black,
                    size: 100,
                  )),
              Divider(
                endIndent: 150,
                color: MyApp.themeNotifier.value == ThemeMode.light
                    ? Colors.white
                    : Colors.black,
              ),
              _navDrawerItem(
                  Icons.calendar_month, 'Events', NavRoutes.eventsRoute),
              _navDrawerItem(
                  Icons.fastfood, 'Food Deals', NavRoutes.foodDealsRoute),
              _navDrawerItem(
                  Icons.business, 'Rec Centers', NavRoutes.recCentersRoute),
              _navDrawerItem(
                  Icons.park, 'Parks and Pools', NavRoutes.parksAndPoolsRoute),
              _navDrawerItem(
                  Icons.attractions, 'Things To Do', NavRoutes.thingsToDoRoute),
              _navDrawerItem(Icons.school, 'Schools', NavRoutes.schoolsRoute),
              _navDrawerItem(
                  Icons.sensor_occupied, 'Resources', NavRoutes.resourcesRoute),
            ],
          ),
        ),
        Stack(children: <Widget>[
          AnimatedPositioned(
              left: !selected ? 0.0 : 150.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateY(animation.value - 30 * animation.value * pi / 180)
                    ..translate(animation.value * 100, 0, 0),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(roundCornerAnimation.value))),
                      width: MediaQuery.of(context).size.width,
                      height: !animHeight
                          ? MediaQuery.of(context).size.height *
                              scaleAnimation.value
                          : MediaQuery.of(context).size.height *
                              heightAnimation.value,
                      child: Navigator(
                        observers: [_heroController],
                        key: navKey,
                        initialRoute: NavRoutes.eventsRoute,
                        onGenerateRoute: (settings) {
                          print(settings.name);
                          switch (settings.name) {
                            case NavRoutes.eventsRoute:
                              return MaterialPageRoute(builder: (context) {
                                return EventsListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.eventDetailsRoute:
                              var args =
                                  settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return EventDetailScreen(
                                    event: args['event'],
                                    category: args['category'],
                                    index: args['index']);
                              });
                            case NavRoutes.foodDealsRoute:
                              return MaterialPageRoute(builder: (context) {
                                return FoodDealsListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.foodDealDetailsRoute:
                              var args =
                                  settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return FoodDealDetailScreen(
                                  foodDeal: args['food_deal'],
                                  dayOfWeek: args['dayOfWeek'],
                                  index: args['index'],
                                );
                              });
                            case NavRoutes.parksAndPoolsRoute:
                              return MaterialPageRoute(builder: (context) {
                                return ParksAndPoolsListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.parkAndPoolDetailsRoute:
                              var args =
                                  settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return ParksAndPoolsDetailScreen(
                                  parkAndPool: args['park_and_pool'],
                                  index: args['index'],
                                );
                              });
                            case NavRoutes.recCentersRoute:
                              return MaterialPageRoute(builder: (context) {
                                return RecCentersListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.recCenterDetailsRoute:
                              var args =
                                  settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return RecCenterDetailScreen(
                                  recCenter: args['rec_center'],
                                  index: args['index'],
                                );
                              });
                            case NavRoutes.thingsToDoRoute:
                              return MaterialPageRoute(builder: (context) {
                                return ThingsToDoListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.thingToDoDetailsRoute:
                              var args =
                                  settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return ThingsToDoDetailScreen(
                                  thingToDo: args['thing_to_do'],
                                  category: args['category'],
                                  index: args['index'],
                                );
                              });
                            case NavRoutes.resourcesRoute:
                              return MaterialPageRoute(builder: (context) {
                                return ResourcesListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.resourceDetailsRoute:
                              var args =
                              settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return ResourceDetailScreen(
                                  resource: args['resource'],
                                  type: args['type'],
                                  index: args['index'],
                                );
                              });
                            case NavRoutes.schoolsRoute:
                              return MaterialPageRoute(builder: (context) {
                                return SchoolsListScreen(
                                  appBarChange: appBarChange,
                                  navKey: navKey,
                                );
                              });
                            case NavRoutes.schoolDetailsRoute:
                              var args =
                              settings.arguments as Map<String, dynamic>;
                              return MaterialPageRoute(builder: (context) {
                                return SchoolDetailScreen(
                                  school: args['school'],
                                  type: args['type'],
                                  index: args['index'],
                                );
                              });
                            default:
                              return MaterialPageRoute(builder: (context) {
                                return EventsListScreen(
                                    appBarChange: appBarChange, navKey: navKey);
                              });
                          }
                        },
                      ))))
        ])
      ]),
    );
  }

  bool animHeight = false;

  Widget _navDrawerItem(IconData icon, String title, String route) {
    return InkWell(
      child: ListTile(
        leading: Icon(
          icon,
          color: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: MyApp.themeNotifier.value == ThemeMode.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        setState(() {
          if (!selected) {
            _animationControler.forward();
          } else {
            _animationControler.reverse().whenComplete(() {
              animHeight = true;
              _animControler.forward().whenComplete(() {
                navKey.currentState!.pushNamed(route);
                _animControler.reverse().whenComplete(() {
                  animHeight = false;
                });
              });
            });
          }
          selected = !selected;
        });
      },
    );
  }
}

// Future<void> setupInteractedMessage() async {
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     _handleMessage(initialMessage);
//   }
//   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
// }
//
// void _handleMessage(RemoteMessage message) {
//   print(message.data['type']);
//   if (message.data['type'] == 'event_detail') {
//     Event event = Event.fromJson(json.decode(message.data['event']));
//     print(event.toString());
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WillPopScope(
//           onWillPop: _onWillPop,
//           child: Scaffold(
//             appBar: AppBar(
//               title: const Text("SD Kids"),
//             ),
//             body: EventDetailScreen(),
//           ),
//         ),
//         settings: RouteSettings(arguments: {'event': event}),
//       ),
//     );
//   }
// }
//
// Future<bool> _onWillPop() async {
//   MyApp();
//   return true;
// }
//
// @override
// void initState() {
//   super.initState();
//   setupInteractedMessage();
// }
