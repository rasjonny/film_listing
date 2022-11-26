import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(
    child: MaterialApp(
      title: 'Home page',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    ),
  ));
}

class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavourite;

  Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavourite,
  });

  Film copied({required Film film, required bool isFavourite}) {
    return Film(
        description: description,
        title: title,
        id: id,
        isFavourite: isFavourite);
  }

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavourite == other.isFavourite;

  @override
  int get hashCode => Object.hashAll([
        id,
        isFavourite,
      ]);
}

final allFilms = [
  Film(
      id: "1",
      title: "Love",
      description: 'Love story based on',
      isFavourite: false),
  Film(
      id: "2",
      title: "Heart",
      description: 'Heart story based on',
      isFavourite: false),
  Film(
      id: "3",
      title: "Good",
      description: 'Good story based on',
      isFavourite: false),
  Film(
      id: "4",
      title: "One",
      description: 'One story based on',
      isFavourite: false)
];

enum FavouriteStatus {
  all,
  favourite,
  notFavourite,
}

class FilmNotifier extends StateNotifier<List<Film>> {
  FilmNotifier() : super(allFilms);

  void update(Film film, bool isFavourite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copied(film: thisFilm, isFavourite: isFavourite)
            : thisFilm)
        .toList();
  }
}

final allFilmsProvider = StateNotifierProvider<FilmNotifier, List<Film>>(
  ((ref) => FilmNotifier()),
);
final favouriteStatusProvider = StateProvider<FavouriteStatus>(
  ((ref) => FavouriteStatus.all),
);
final favouriteFilmProvider = Provider<Iterable<Film>>(
    ((ref) => ref.watch(allFilmsProvider).where((film) => film.isFavourite)));
final notfavouriteFilmProvider = Provider<Iterable<Film>>(
    ((ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavourite)));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Films")),
      body: Column(
        children: [
          const FavouriteStatusWidget(),
          Consumer(builder: ((context, ref, child) {
            final filter = ref.watch(favouriteStatusProvider);
            switch (filter) {
              case FavouriteStatus.all:
                return FilmWidget(provider: allFilmsProvider);
              case FavouriteStatus.favourite:
                return FilmWidget(provider: favouriteFilmProvider);

              case FavouriteStatus.notFavourite:
                return FilmWidget(provider: notfavouriteFilmProvider);
            }
          }))
        ],
      ),
    );
  }
}

class FilmWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmWidget({required this.provider, super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allFilms = ref.watch(provider);

    return Expanded(
        child: ListView.builder(
            itemCount: allFilms.length,
            itemBuilder: ((context, index) {
              final film = allFilms.elementAt(index);
              final isFavourited = film.isFavourite
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border);
              return ListTile(
                title: Text(film.title),
                subtitle: Text(film.description),
                trailing: IconButton(
                  onPressed: (() {
                    final favourited = !film.isFavourite;

                    ref
                        .read(allFilmsProvider.notifier)
                        .update(film, favourited);
                  }),
                  icon: isFavourited,
                ),
              );
            })));
  }
}

class FavouriteStatusWidget extends StatelessWidget {
  const FavouriteStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      ref.watch(favouriteStatusProvider);
      return DropdownButton(
        items: FavouriteStatus.values
            .map(
              (fs) => DropdownMenuItem(
                value: fs,
                child: Text(fs.toString().split('.').last),
              ),
            )
            .toList(),
        onChanged: ((value) =>
            ref.read(favouriteStatusProvider.notifier).state = value!),
      );
    }));
  }
}
