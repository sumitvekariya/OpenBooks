class RentedBook {
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
  final String rentedusername;
  final String renteduserimage;
  final String renteduseruid;
  final String renteduserlocation;
  final double renteduserlat;
  final double renteduserlong;
  RentedBook({
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
    required this.rentedusername,
    required this.renteduserimage,
    required this.renteduseruid,
    required this.renteduserlocation,
    required this.renteduserlat,
    required this.renteduserlong,
  });

  factory RentedBook.fromMap(Map<String, dynamic> data, String documentId) {
    return RentedBook(
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
      rentedusername: data['rentedusername'],
      renteduserimage: data['renteduserimage'],
      renteduseruid: data['renteduseruid'],
      renteduserlocation: data['renteduserlocation'],
      renteduserlat: (data['renteduserlat'] ?? 0.0).toDouble(),
      renteduserlong: (data['renteduserlong'] ?? 0.0).toDouble(),
    );
  }
}
