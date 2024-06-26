class RequestedBook {
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
  final String requestusername;
  final String requestuserimage;
  final String requestuseruid;
  final String requestuserlocation;
  final double requestuserlat;
  final double requestuserlong;
  RequestedBook({
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
    required this.requestusername,
    required this.requestuserimage,
    required this.requestuseruid,
    required this.requestuserlocation,
    required this.requestuserlat,
    required this.requestuserlong,
  });

  factory RequestedBook.fromMap(Map<String, dynamic> data, String documentId) {
    return RequestedBook(
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
      requestusername: data['requestusername'],
      requestuserimage: data['requestuserimage'],
      requestuseruid: data['requestuseruid'],
      requestuserlocation: data['requestuserlocation'],
      requestuserlat: (data['requestuserlat'] ?? 0.0).toDouble(),
      requestuserlong: (data['requestuserlong'] ?? 0.0).toDouble(),
    );
  }
}
