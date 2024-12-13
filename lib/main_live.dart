

import 'package:gb_media/env/environment_variables.dart';
import 'package:gb_media/main.dart';

void main() async {
  final environmentVariables = EnvironmentVariables(
    baseUrl: 'https://api.glassbox.id',

  );
  mainCommon(environmentVariables);
}
