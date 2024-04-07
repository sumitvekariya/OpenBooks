import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://openbooks-be.vercel.app/'));

  Future<Response> removeBook(String bookId, String token) async {
    try {
      final response = await _dio.post(
        '/users/remove-book',
        data: {'bookId': bookId},
        options: Options(headers: {'Authorization': token}),
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> mintBooks(Map<String, dynamic> data, token) async {
    try {
      final response = await _dio.post(
        '/users/mint-books',
        data: data,
        options: Options(headers: {'Authorization': token}),
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> login(String username, String name, String profilePicture) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {
          'username': username,
          'name': name,
          'profilePicture': profilePicture,
        },
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> addBook(String isbn, String title, String token) async {
    try {
      final response = await _dio.post(
        '/users/add-book',
        data: {'isbn': isbn, 'title': title},
        options: Options(headers: {'Authorization': token}),
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getMyBooks(String token) async {
    try {
      final response = await _dio.get(
        '/users/my-books',
        options: Options(headers: {'Authorization': token}),
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> getBookDetails(String token, String id) async {
    try {
      final response = await _dio.get(
        '/users/book-details/$id',
        options: Options(headers: {'Authorization': token}),
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
