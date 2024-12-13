import 'package:flutter/widgets.dart';
import 'package:gb_media/routes/routes.dart';
import 'package:gb_media/routes/routes_generator.dart';

class Glassbox extends StatelessWidget {
  const Glassbox({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      onGenerateRoute: RoutesGenerator.generateRoute,
      builder: (context, child) => child ?? const SizedBox(),
    );
  }
}
