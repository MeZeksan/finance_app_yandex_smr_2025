import 'package:finance_app_yandex_smr_2025/features/articles/data/repository/mock_articles_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_event.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final MockArticlesRepository _repository;

  ArticlesBloc({required MockArticlesRepository repository})
      : _repository = repository,
        super(const ArticlesState()) {
    on<LoadArticles>(_onLoadArticles);
    on<SearchArticles>(_onSearchArticles);
    on<ToggleSearchMode>(_onToggleSearchMode);
  }

  void _onLoadArticles(
    LoadArticles event,
    Emitter<ArticlesState> emit,
  ) {
    emit(state.copyWith(status: ArticlesStatus.loading));

    try {
      final articles = _repository.getAllArticles();
      emit(state.copyWith(
        status: ArticlesStatus.success,
        articles: articles,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Ошибка загрузки статей: ${error.toString()}',
      ));
    }
  }

  void _onSearchArticles(
    SearchArticles event,
    Emitter<ArticlesState> emit,
  ) {
    emit(state.copyWith(
      status: ArticlesStatus.loading,
      searchQuery: event.query,
    ));

    try {
      final articles = state.searchMode == SearchMode.regular
          ? _repository.searchArticles(event.query)
          : _repository.fuzzySearchArticles(event.query);

      emit(state.copyWith(
        status: ArticlesStatus.success,
        articles: articles,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        errorMessage: 'Ошибка поиска статей: ${error.toString()}',
      ));
    }
  }

  void _onToggleSearchMode(
    ToggleSearchMode event,
    Emitter<ArticlesState> emit,
  ) {
    emit(state.copyWith(
      searchMode: event.searchMode,
    ));

    // Re-run search with new mode
    add(SearchArticles(state.searchQuery));
  }
} 