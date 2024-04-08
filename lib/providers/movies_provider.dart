import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/helpers/debouncer.dart';
import 'package:flutter_application_3/models/models.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier{
  final _apiKey = '28555aad597cffdd79275f032ef3d488';
  final _baseUrl = 'api.themoviedb.org';
  final _languaje = 'es-ES';

  int _popularPage = 0;

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500)
  );

  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;

  MoviesProvider(){
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future <String> _getJsonData(String segment, [int page = 1]) async{
    final url = Uri.https(_baseUrl, segment, {
      'api_key': _apiKey,
      'language': _languaje,
      'page': '$page'
    });
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async{
    final nowPlayingResponse = NowPlayingResponse.fromJson( await _getJsonData('3/movie/now_playing'));
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies()async{
    _popularPage++;
    final popularResponse = PopularResponse.fromJson( await _getJsonData('3/movie/popular', _popularPage));
    popularMovies = [...popularMovies,...popularResponse.results];
    notifyListeners();
  }

  Future <List<Cast>> getMovieCast(int movieId) async{
    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    final creditsResponse = CreditsResponse.fromJson( await _getJsonData('3/movie/$movieId/credits'));
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async{
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _languaje,
      'query': query
    });


    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm){
    debouncer.value = '';
    debouncer.onValue = (value) async{
      final results = await searchMovies(searchTerm);
      _suggestionStreamController.add(results);
    };

    final timer = Timer(const Duration(milliseconds: 300), () {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());

  }
}