import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sample/service/auth_service.dart';
import 'package:sample/widgets/initial_page.dart';
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
  late AuthService authService;
  UserProfile? _user;
  final bool _loading = true;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    credentialsManager = auth0.credentialsManager;
    authService =
        AuthService(auth0: auth0, credentialsManager: credentialsManager);

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
      home: InitialPage(),
      routes: {
        '/loading': (context) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        '/login': (context) => LoginPage(),
        '/gameList': (context) {
          return GameListPage();
        },
        '/wordle': (context) => const WordlePage(),
        '/user': (context) {
          return UserPage();
        },
      },
    );
  }
}
