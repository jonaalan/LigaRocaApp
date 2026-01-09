import 'package:liga_roca/src/config/environment.dart';
import 'main_common.dart';

void main() async {
  await mainCommon(
    AppEnvironment(
      type: EnvironmentType.dev,
      appName: 'Liga Roca DEV',
      bannerMessage: 'MODO PRUEBA',
    ),
  );
}
