import 'package:flutter/material.dart';
import 'package:keep_flutter/AccountDetails.dart';
import 'package:keep_flutter/AccountList.dart';
import 'package:keep_flutter/Settings.dart';
import 'package:keep_flutter/SplashScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = {
    '/account_list':(context) => AccountList(),
    '/account_details':(context, {arguments}) => AccountDetails(accountModel: arguments,),
    '/settings':(context) => Settings(),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    onGenerateRoute(RouteSettings settings) {
      final String name = settings.name!;
      final Function pageContentBuilder = routes[name]!;
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute(
          settings: settings,
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: pageContentBuilder(context, arguments: settings.arguments),
          ),
        );
        return route;
      } else {
        final Route route = MaterialPageRoute(
          settings: settings,
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: pageContentBuilder(context),
          ),
        );
        return route;
      }
    }

    return MaterialApp(
      title: 'Keep',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      onGenerateRoute: onGenerateRoute,
    );
  }
}
