import 'dart:async';

import 'package:code_base/bloc/easy_locale/locale_bloc.dart';
import 'package:code_base/bloc/session/session_bloc.dart';
import 'package:code_base/config/app_config_adapter.dart';
import 'package:code_base/core/helpers/remote_asset_loader.dart';
import 'package:code_base/core/local_storage/session_manager.dart';
import 'package:code_base/core/utils/import_util.dart';
import 'package:code_base/pages/authentication/bloc/authentication_bloc.dart';
import 'package:code_base/pages/login_page/bloc/login_bloc.dart';
import 'package:code_base/pages/notification/bloc/notification_bloc.dart';
import 'package:code_base/pages/splash_page/bloc/splash_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'application.dart';
import 'bloc/theme/theme_bloc.dart';
import 'core/enums/app_environment.dart';
import 'core/utils/local_notice_service.dart';
import 'core/utils/localization_util.dart';
import 'firebase_options.dart';

void mainCommon(AppEnvironment environment) {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await AppConfigAdapter.loadConfig(environment);
      await EasyLocalization.ensureInitialized();
      await NotificationService.initialize();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await registerCommonDependencies();
      await registerDependencies(environment);
      await getIt.allReady();
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      usePathUrlStrategy();
      await SessionManager.instance.initialize();
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<SplashBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<ThemeBloc>(),
            ),
            BlocProvider.value(
              value: getIt<SessionBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<NotificationBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<LoginBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<AuthenticationBloc>(),
            ),
            BlocProvider(
              create: (context) => getIt<LocaleBloc>()..getSavedLanguage(),
            ),
          ],
          child: EasyLocalization(
            supportedLocales: LocalizationUtil.supportedLocales,
            path: 'assets/translations',
            fallbackLocale: LocalizationUtil.defaultLocale,
            startLocale: LocalizationUtil.defaultLocale,
            assetLoader: const RemoteAssetLoader(),
            child: Application(router: getIt<AppRouter>()),
          ),
        ),
      );
    },
    (error, stack) {
      print(error.toString());
    },
  );
}
