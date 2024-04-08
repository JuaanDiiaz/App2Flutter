import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/models.dart';
import 'package:provider/provider.dart';

import '../providers/movies_provider.dart';

class MovieSearchDelegate extends SearchDelegate{
  @override
  String get searchFieldLabel => 'Buscar pelicula'; 

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    return Text('Build Results');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty){
      return Container(
        child: const Center(
          child: Icon(Icons.movie_creation_outlined, color: Colors.black38, size: 130),
        ),
      );
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    moviesProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: moviesProvider.suggestionStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if(!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) => _MovieItem(movie: movies[index]),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {
  const _MovieItem({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'search-${movie.id}';
    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
            placeholder: const AssetImage('assets/no-image.jpg'), 
            image: NetworkImage(movie.fullPosterImg),
            width: 50,
            fit: BoxFit.cover,
          ),
      ),
      title: Text(movie.title),
      subtitle: Text(movie.originalTitle),
      onTap: () {
        Navigator.pushNamed(context, 'detail', arguments: movie);
      },
    );
  }
}