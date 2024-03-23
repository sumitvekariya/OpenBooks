import 'book_model.dart';

class RecievedBook {
  final String bookId;
  final String bookName;
  final String authorName;
  final String imageCover;
  final String username;
  final String userUid;
  final String userLocation;
  final double userLat;
  final double userLong;
  final String userimage;
  final String recievedusername;
  final String recieveduserimage;
  final String recieveduseruid;
  final String recieveduserlocation;
  final double recieveduserlat;
  final double recieveduserlong;
  final String bookdesc;
  RecievedBook({
    required this.bookId,
    required this.bookName,
    required this.authorName,
    required this.imageCover,
    required this.username,
    required this.userUid,
    required this.userLocation,
    required this.userLat,
    required this.userLong,
    required this.userimage,
    required this.recievedusername,
    required this.recieveduserimage,
    required this.recieveduseruid,
    required this.recieveduserlocation,
    required this.recieveduserlat,
    required this.recieveduserlong,
    required this.bookdesc,
  });

  factory RecievedBook.fromMap(Map<String, dynamic> data, String documentId) {
    return RecievedBook(
      bookId: documentId,
      bookName: data['book_name'] ?? '',
      authorName: data['author_name'] ?? '',
      imageCover: data['image_cover'] ?? '',
      username: data['username'] ?? '',
      userUid: data['useruid'] ?? '',
      userLocation: data['user_location'] ?? '',
      userLat: (data['user_lat'] ?? 0.0).toDouble(),
      userLong: (data['user_long'] ?? 0.0).toDouble(),
      userimage: data['userimage'],
      recievedusername: data['recievedusername'],
      recieveduserimage: data['recieveduserimage'],
      recieveduseruid: data['recieveduseruid'],
      recieveduserlocation: data['recieveduserlocation'],
      recieveduserlat: (data['recieveduserlat'] ?? 0.0).toDouble(),
      recieveduserlong: (data['recieveduserlong'] ?? 0.0).toDouble(),
      bookdesc: data['bookdesc'],
    );
  }
  Book convertToBook() {
    return Book(
      bookId: this.bookId ?? '',
      bookName: this.bookName ?? '',
      authorName: this.authorName ?? '',
      imageCover: this.imageCover ?? '',
      username: this.username ?? '',
      userUid: this.userUid ?? '',
      userLocation: this.userLocation ?? '',
      userLat: this.userLat ?? 0.0,
      userLong: this.userLong ?? 0.0,
      userimage: this.userimage ?? '',
      isrented: false,
      bookdesc: this.bookdesc ?? '',
    );
  }
}
