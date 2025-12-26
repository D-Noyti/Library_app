import 'package:dio/dio.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/services/api/api_exceptions.dart';
import 'package:library_app/utils/api_config.dart';

class GoogleBooksService {
  final Dio _dio;

  GoogleBooksService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.googleBooksBaseUrl,
          connectTimeout: ApiConfig.requestTimeout,
          receiveTimeout: ApiConfig.requestTimeout,
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['key'] = ApiConfig.googleBooksApiKey;
        return handler.next(options);
      },
    ));
  }

  Future<List<Book>> searchBooks(String query, {int maxResults = ApiConfig.defaultMaxResults}) async {
    try {
      final response = await _dio.get(
        'volumes',
        queryParameters: {
          'q': query,
          'maxResults': maxResults,
          'printType': 'books',
        },
      );

      if (response.statusCode == 200) {
        final items = response.data['items'] as List?;
        if (items == null) return [];
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw ApiException('Failed to fetch books');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException('API key invalid or quota exceeded');
      }
      throw ApiException(e.message ?? 'Network error');
    }
  }

  Future<Book?> getBookDetails(String bookId) async {
    try {
      final response = await _dio.get('volumes/$bookId');
      
      if (response.statusCode == 200) {
        return Book.fromJson(response.data);
      } else {
        throw ApiException('Failed to fetch book details');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException('API key invalid or quota exceeded');
      }
      throw ApiException(e.message ?? 'Network error');
    }
  }
}