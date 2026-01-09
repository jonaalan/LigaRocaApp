import 'package:liga_roca/src/config/environment.dart';
import 'main_common.dart';

void main() async {
  await mainCommon(
    AppEnvironment(
      type: EnvironmentType.prod,
      appName: 'Liga Roca',
      bannerMessage: null, // Sin banner en producción
    ),
  );
}
