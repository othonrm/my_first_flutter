import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 4, 53, 144)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: ('Home'),
              enabled: true,
            ),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: ('Favorites')),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) => setState(() {
            selectedIndex = value;
          }),
        ),
        body: SafeArea(
          child: page,
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var count = 0;
  // var current = 1;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    print('Favorites ${favorites}');
    notifyListeners();
  }

  void deleteFavorite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    }
    notifyListeners();
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // appState.count = 1;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Starting a new idea is\nAWESOME!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          BigCard(pair: pair),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: appState.toggleFavorite,
                      icon: Icon(icon),
                      label: Text("Like"),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        appState.count = appState.count + 1;

                        print('button pressed! ${appState.count}');

                        appState.getNext();
                      },
                      child: Text('Next'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Text(
                        'Word count at: ${appState.count}',
                        style: TextStyle(
                            fontSize: theme.textTheme.bodySmall!.fontSize),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Favorites: ${appState.favorites.length}',
                        style: TextStyle(
                            fontSize: theme.textTheme.bodySmall!.fontSize),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      // fontSize: 30,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase,
            style: textStyle, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              [
                'This is your favorite list.',
                '',
                'You currently have ${appState.favorites.length} favorite${appState.favorites.length == 1 ? '' : 's'}.',
              ].join('\n'),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          ...appState.favorites
              .map(
                (pair) => ListTile(
                    leading: IconButton(
                      onPressed: () => appState.deleteFavorite(pair),
                      icon: Icon(Icons.delete),
                    ),
                    title: Text(pair.asLowerCase)),
              )
              .toList()
        ],
      ),
    );
  }
}
