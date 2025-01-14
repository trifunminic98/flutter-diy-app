import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// (Opciono) Za integraciju Google Sign-In
// import 'package:google_sign_in/google_sign_in.dart';

// (Opciono) Za integraciju Apple Sign-In
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// (Opciono) Za Firebase Auth
// import 'package:firebase_auth/firebase_auth.dart';

// (Opciono) Za internacionalizaciju
import 'package:flutter_localizations/flutter_localizations.dart';

/// ------------------------------------------------------------------------
/// POČETAK - Lokalne baze i offline pretraga
/// ------------------------------------------------------------------------
class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._internal();
  LocalDatabase._internal();

  // U realnoj aplikaciji učitavate JSON iz assets fajla (offline_data.json).
  // Ovde samo primerom definišemo lokalni niz u memoriji:
  final List<Map<String, String>> _localData = [
    {
      "question": "How to fix a leaking faucet?",
      "answer": "Turn off water supply, replace gasket, etc. (Offline data)"
    },
    {
      "question": "Kako popraviti slavinu koja curi?",
      "answer": "Zatvorite vodu, zamenite gumicu... (Offline data)"
    },
  ];

  Future<void> init() async {
    // U pravoj aplikaciji učitavate JSON iz assets:
    // final String response = await rootBundle.loadString('assets/offline_data.json');
    // _localData = json.decode(response);
    // Za sada samo simulacija da su podaci vec tu.
  }

  List<Map<String, String>> get localData => _localData;
}

class LocalSearch {
  // Vraća prvi pronađeni odgovor iz lokalne baze
  static String? searchOffline(String query) {
    final db = LocalDatabase.instance.localData;
    for (var item in db) {
      if (item['question']!.toLowerCase().contains(query.toLowerCase())) {
        return item['answer'];
      }
    }
    return null;
  }
}

/// ------------------------------------------------------------------------
/// POČETAK - Online mod (ChatGPT, Bing, Google API)
/// ------------------------------------------------------------------------
class ChatGPTApi {
  // U praksi zamenite vašim API key-em i endpoint-om
  static const String _apiKey = 'YOUR_CHATGPT_API_KEY';
  static const String _endpoint = 'https://api.openai.com/v1/completions';

  Future<String> getAIAnswer(String query) async {
    // Pre nego što se obratimo ChatGPT, možemo probati lokalnu bazu:
    final offlineResult = LocalSearch.searchOffline(query);
    if (offlineResult != null) {
      // Ako smo pronašli offline, odmah vratimo
      return 'OFFLINE REŠENJE:\n$offlineResult';
    }

    // U suprotnom, idemo na ChatGPT (fiktivno, treba vam pravi API ključ).
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': query,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['text'];
      } else {
        return 'Greška pri pozivanju AI servisa. Kod: ${response.statusCode}';
      }
    } catch (e) {
      return 'Došlo je do greške: $e';
    }
  }
}

// Fiktivni Bing API
class BingAPI {
  Future<String> getLocalPrice(String material, String city) async {
    // Napravite pravi REST poziv Bing-u ili drugom servisu
    // Ovde samo simuliramo
    return 'Cena materijala $material u gradu $city iznosi ~10\$ (Bing API fiktivno).';
  }
}

// Fiktivni Google API
class GoogleAPI {
  Future<String> getLocalStores(String material, String city) async {
    // Napravite pravi REST poziv Google-u
    // Ovde samo simuliramo
    return 'Dostupne prodavnice za $material u gradu $city: Store1, Store2... (Google API fiktivno).';
  }
}

/// ------------------------------------------------------------------------
/// POČETAK - (Opciono) Autentifikacija
/// ------------------------------------------------------------------------
// class AuthenticationService {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   Future<User?> signInWithCredential(AuthCredential credential) async {
//     UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
//     return userCredential.user;
//   }
//
//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }
// }
//
// class GoogleSignInService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final AuthenticationService _authService = AuthenticationService();
//
//   Future<User?> signInWithGoogle() async {
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) {
//       return null; // Korisnik je otkazao
//     }
//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     return _authService.signInWithCredential(credential);
//   }
// }
//
// class AppleSignInService {
//   final AuthenticationService _authService = AuthenticationService();
//
//   Future<User?> signInWithApple() async {
//     final credential = await SignInWithApple.getAppleIDCredential(scopes: [
//       AppleIDAuthorizationScopes.email,
//       AppleIDAuthorizationScopes.fullName,
//     ]);
//     final oAuthProvider = OAuthProvider('apple.com');
//     final authCredential = oAuthProvider.credential(
//       accessToken: credential.authorizationCode,
//       idToken: credential.identityToken,
//     );
//     return _authService.signInWithCredential(authCredential);
//   }
// }

/// ------------------------------------------------------------------------
/// POČETAK - Višejezičnost (lokalizacija)
/// ------------------------------------------------------------------------
// Ovde je minimalan primer. Za punu implementaciju lokalizacije,
// koristite ARB fajlove ili slično.

// Ako želite, možete ostaviti klasu AppLocalizations ovde i iskoristiti je:
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello!',
      'settings': 'Settings',
      'search': 'Search',
      'home': 'Home',
    },
    'sr': {
      'hello': 'Zdravo!',
      'settings': 'Podešavanja',
      'search': 'Pretraga',
      'home': 'Početna',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

/// ------------------------------------------------------------------------
/// POČETAK - Glavni widget aplikacije
/// ------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicijalizacija lokalne baze (ako imate offline_data.json, učitavate je)
  await LocalDatabase.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

///
/// Ovde radimo setup MaterialApp, localizations, rute, init page, itd.
///
class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Podrazumevani jezik

  void _setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIY App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('sr', ''),
      ],
      locale: _locale,
      // Definišemo rute
      routes: {
        '/': (context) => HomePage(onChangeLanguage: _setLocale),
        '/categories': (context) => const CategoriesPage(),
        '/subcategories': (context) => const SubcategoriesPage(),
        '/search-ai': (context) => const SearchAIPage(),
        '/diagnostika': (context) => const DiagnostikaPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/settings': (context) => SettingsPage(onChangeLanguage: _setLocale),
      },
      initialRoute: '/',
    );
  }
}

/// ------------------------------------------------------------------------
/// 1. Home Page
/// ------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  final Function(Locale) onChangeLanguage;

  const HomePage({Key? key, required this.onChangeLanguage}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/', // Home
    '/categories', // Kategorije
    '/search-ai', // Search AI
    '/diagnostika', // Diagnostika
    '/settings', // Settings
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('home')),
        // Search bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (value) {
                // Kad unese query, šaljemo ga na /search-ai
                Navigator.pushNamed(context, '/search-ai', arguments: value);
              },
              decoration: InputDecoration(
                hintText: loc.translate('search') + '...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          '${loc.translate('hello')}!\n\n'
          'Ovo je početna stranica.\n'
          'Odavde možete pristupiti svim funkcionalnostima.',
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: loc.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: 'Kategorije',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: 'Search AI',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: 'Diagnostika',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: loc.translate('settings'),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// 2. Categories Page
/// ------------------------------------------------------------------------
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Elektrika',
      'Vodovod',
      'Zidanje',
      'Farbanje',
      'Stolarija',
      'Bastenski radovi',
      'Krov',
      'Podovi',
      'Dekoracija',
      'Ostalo',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kategorije')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/subcategories',
                arguments: categories[index],
              );
            },
          );
        },
      ),
    );
  }
}

/// Subcategories Page
class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainCategory = ModalRoute.of(context)!.settings.arguments as String;

    // Primer potkategorija
    final subcategories = [
      '$mainCategory - Problem 1',
      '$mainCategory - Problem 2',
      '$mainCategory - Problem 3',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('$mainCategory - Potkategorije')),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcat = subcategories[index];
          return ListTile(
            title: Text(subcat),
            onTap: () {
              // Ovde biste prikazali detaljno rešenje problema:
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Rešenje za $subcat'),
                  content: SingleChildScrollView(
                    child: Text(
                      'Korak po korak rešenje...\n\n'
                      'Potrebni alati: ...\n'
                      'Potrebni materijali: ...\n'
                      'Cena lokalnog materijala (preko Google/Bing API)...\n'
                      'Ukupni troškovi: ...',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Zatvori'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// 3. Search AI Page
/// ------------------------------------------------------------------------
class SearchAIPage extends StatefulWidget {
  const SearchAIPage({Key? key}) : super(key: key);

  @override
  State<SearchAIPage> createState() => _SearchAIPageState();
}

class _SearchAIPageState extends State<SearchAIPage> {
  final TextEditingController _controller = TextEditingController();
  String _answer = '';
  final ChatGPTApi _chatGPTApi = ChatGPTApi();

  @override
  void initState() {
    super.initState();
    // Ako je prosleđen argument (npr. sa HomePage pretragom), popuni polje:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg is String) {
        _controller.text = arg;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Unesite pitanje'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await _chatGPTApi.getAIAnswer(_controller.text);
                setState(() => _answer = result);
              },
              child: const Text('Pošalji AI-u'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_answer),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logika za slanje slike (kamera ili gallery),
          // npr. putem package: image_picker
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

/// Diagnostika Page
class DiagnostikaPage extends StatefulWidget {
  const DiagnostikaPage({Key? key}) : super(key: key);

  @override
  State<DiagnostikaPage> createState() => _DiagnostikaPageState();
}

class _DiagnostikaPageState extends State<DiagnostikaPage> {
  String _diagnosisResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostika')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rezultat dijagnostike: $_diagnosisResult'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logika za otvaranje kamere, slanje slike AI-u, itd.
                setState(() {
                  _diagnosisResult =
                      'Pretpostavljamo da je problem u... (AI output)';
                });
              },
              child: const Text('Pokreni kameru'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logika za unos teksta
                setState(() {
                  _diagnosisResult =
                      'Uneli ste tekstualni problem... (AI output)';
                });
              },
              child: const Text('Unesi problem tekstom'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// 4. My Favorites Page
/// ------------------------------------------------------------------------
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // U pravoj implementaciji, ovo bi dolazilo iz lokalne baze ili Cloud-a
  List<String> _favorites = [
    'Rešenje za Vodovod #1',
    'Rešenje za Elektrika #2'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moji Favoriti')),
      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _favorites.removeAt(index);
                });
              },
            ),
            onTap: () {
              // Logika za deljenje rešenja (share plugin itd.)
            },
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// 5. Settings Page (izbor jezika i dr.)
//  U realnoj app: menja se (context as Element).markNeedsBuild() ili
//  stateful widget da bi se refreshovao jezik u celom app-u.
/// ------------------------------------------------------------------------
class SettingsPage extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  const SettingsPage({Key? key, required this.onChangeLanguage})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentLanguageCode = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podešavanja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Izaberite jezik:'),
            DropdownButton<String>(
              value: _currentLanguageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'sr', child: Text('Srpski')),
              ],
              onChanged: (value) {
                setState(() {
                  _currentLanguageCode = value ?? 'en';
                  widget.onChangeLanguage(Locale(_currentLanguageCode));
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Ovde možete dodati i druga podešavanja aplikacije.',
            ),
          ],
        ),
      ),
    );
  }
}
