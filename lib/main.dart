// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provider/provider.dart';
import 'package:meditrack_new/screens/onboarding/first_screen.dart'; // Update this to your actual splash screen
import 'package:meditrack_new/screens/auth/reset_password.dart';
import 'package:meditrack_new/services/auth_service.dart';

// Global navigator key to use for navigation from outside of context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Flag to determine if we're in test mode
bool isInTestMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Handle dynamic links for password reset
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

    runApp(MyApp(initialLink: initialLink));
  } catch (e) {
    print('Error initializing app: $e');
    runApp(MyApp(initialLink: null));
  }
}

// Process dynamic links and navigate to appropriate screens
// Process dynamic links and navigate to appropriate screens
void _handleDynamicLink(PendingDynamicLinkData? data) {
  if (data == null) {
    return;
  }

  final Uri deepLink = data.link;
  print('Got deep link: ${deepLink.toString()}');

  // Handle password reset link
  if (deepLink.pathSegments.contains('resetPassword')) {
    // Extract the OOB code from query parameters
    final oobCode = deepLink.queryParameters['oobCode'];
    print('Got oobCode from link: $oobCode');

    if (oobCode != null) {
      // We'll use a delay to ensure the app is fully initialized
      Future.delayed(Duration(milliseconds: 500), () {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(oobCode: oobCode),
            ),
          );
        } else {
          print('Navigator state is null, cannot navigate to ResetPasswordPage');
        }
      });
    }
  }
}

class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;

  const MyApp({Key? key, this.initialLink}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Handle any initial link
    if (widget.initialLink != null) {
      _handleDynamicLink(widget.initialLink!);
    }

    // Set up listener for links when app is already running
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    }).onError((error) {
      print('Error handling dynamic link: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    // For tests, return a simple counter app
    if (isInTestMode) {
      return MaterialApp(
        home: CounterTestApp(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'MediTrack',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primaryColor: Color(0xFF33D4C8),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF33D4C8),
            primary: Color(0xFF33D4C8),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF33D4C8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF33D4C8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Color(0xFFEEFBF8),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        // Use your actual first screen
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// This widget is only used for tests
class CounterTestApp extends StatefulWidget {
  const CounterTestApp({Key? key}) : super(key: key);

  @override
  State<CounterTestApp> createState() => _CounterTestAppState();
}

class _CounterTestAppState extends State<CounterTestApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}