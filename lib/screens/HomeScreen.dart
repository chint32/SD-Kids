import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sd_kids/NavDrawer.dart';
import 'package:sd_kids/main.dart';
import 'package:sd_kids/util/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;

  List<String> navOptions = [
    'Events',
    'Rec Centers',
    'Food Deals',
    'Parks and Pools',
    'Things to Do'
  ];
  bool _visible1 = false;
  bool _visible2 = false;
  bool _visible3 = false;
  bool _visible4 = false;
  bool _visible5 = false;

  void animationDelay1(int delay) {
    Future.delayed(Duration(milliseconds: 2000 + delay), () {
      setState(() {
        _visible1 = true;
      });
    });
  }

  void animationDelay2(int delay) {
    Future.delayed(Duration(milliseconds: 2000 + delay), () {
      setState(() {
        _visible2 = true;
      });
    });
  }

  void animationDelay3(int delay) {
    Future.delayed(Duration(milliseconds: 2000 + delay), () {
      setState(() {
        _visible3 = true;
      });
    });
  }

  void animationDelay4(int delay) {
    Future.delayed(Duration(milliseconds: 2000 + delay), () {
      setState(() {
        _visible4 = true;
      });
    });
  }

  void animationDelay5(int delay) {
    Future.delayed(Duration(milliseconds: 2000 + delay), () {
      setState(() {
        _visible5 = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    animationDelay1(0);
    animationDelay2(200);
    animationDelay3(400);
    animationDelay4(600);
    animationDelay5(800);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget navItemWidget(
      bool visible,
      String name,
      double widthFactor,
      double heightFactor,
      Color cardColor,
      Widget icon,
      String navRoute,
      int index) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, navRoute);
        },
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1600),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: AnimatedContainer(
                width: width * widthFactor,
                height: height * heightFactor,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: cardColor.withOpacity(.6),
                        blurRadius: 15,
                        spreadRadius: -10,
                        offset: const Offset(0, 20.0)),
                  ],
                ),
                duration: Duration(milliseconds: 500),
                child: Card(
                    color: cardColor,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        icon
                      ],
                    )))),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Lottie.asset('assets/lottie/home_screen_anim.json',
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height *.4,
            controller: _controller, onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..reverse()
            ..repeat();
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItemWidget(
                _visible1,
                navOptions[1],
                .45,
                .15,
                MyConstants.cardBgColors[0],
                const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 40,
                ),
                NavRoutes.recCentersRoute,
                1),
            navItemWidget(
                _visible2,
                navOptions[3],
                .45,
                .15,
                MyConstants.cardBgColors[1],
                const Icon(
                  Icons.pool,
                  color: Colors.white,
                  size: 40,
                ),
                NavRoutes.parksAndPoolsRoute,
                2)
          ],
        ),
        navItemWidget(
            _visible3,
            navOptions[0],
            .85,
            .15,
            MyConstants.cardBgColors[3],
            const Icon(
              Icons.event,
              color: Colors.white,
              size: 40,
            ),
            NavRoutes.eventsRoute,
            3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItemWidget(
                _visible4,
                navOptions[2],
                .45,
                .15,
                MyConstants.cardBgColors[4],
                const Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 40,
                ),
                NavRoutes.foodDealsRoute,
                4),
            navItemWidget(
                _visible5,
                navOptions[4],
                .45,
                .15,
                MyConstants.cardBgColors[5],
                const Icon(
                  Icons.light_mode_sharp,
                  color: Colors.white,
                  size: 40,
                ),
                NavRoutes.thingsToDoRoute,
                5)
          ],
        ),
      ],
    );
  }
}
