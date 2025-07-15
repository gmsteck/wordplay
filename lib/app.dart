import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sample/widgets/wordle.dart';
import 'widgets/game_list.dart';
import 'widgets/login.dart';
import 'widgets/user.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
} // import your new page here

class _AppState extends State<App> {
  late Auth0 auth0;
  late CredentialsManager credentialsManager;
  UserProfile? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    credentialsManager = auth0.credentialsManager;

    // _tryRestoreSession();
  }

  // Future<void> _tryRestoreSession() async {
  //   print('Attempting to restore session...');
  //   try {
  //     final hasCreds = await credentialsManager.hasValidCredentials();
  //     print('hasValidCredentials returned: $hasCreds');
  //     if (hasCreds) {
  //       final creds = await credentialsManager.credentials();
  //       print('Credentials user: ${creds.user}');
  //       setState(() {
  //         _user = creds.user;
  //         _loading = false;
  //       });
  //     } else {
  //       print('No valid credentials found.');
  //       setState(() => _loading = false);
  //     }
  //   } catch (e, st) {
  //     print('Exception in tryRestoreSession: $e');
  //     print(st);
  //     setState(() => _loading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print('Building app: loading=$_loading, user=$_user');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // or your custom theme
      initialRoute:
          //_loading ? '/loading' : (_user != null ? '/gameList' : '/login'),
          '/login',
      routes: {
        '/loading': (context) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        '/login': (context) => LoginPage(
              auth0: auth0,
              credentialsManager: credentialsManager,
            ),
        '/gameList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return GameListPage(
            auth0: args['auth0'],
            credentialsManager: args['credentialsManager'],
            user: args['user'],
          );
        },
        '/wordle': (context) => const WordlePage(),
        '/user': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return UserPage(
            auth0: args['auth0'],
            credentialsManager: args['credentialsManager'],
            user: args['user'],
          );
        },
      },
    );
  }
}
