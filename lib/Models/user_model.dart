class UserPeopleModel {
  final String uid;
  final String username;
  final String name;
  final String imageurl;
  final bool fillDetails;
  final String provider;
  final String locationname;
  final double userlat;
  final double userlong;
  final String walletAddress;

  UserPeopleModel(
      {required this.uid,
      required this.username,
      required this.name,
      required this.imageurl,
      required this.fillDetails,
      required this.provider,
      required this.locationname,
      required this.userlat,
      required this.userlong,
      required this.walletAddress});

  factory UserPeopleModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    return UserPeopleModel(
        uid: documentId,
        username: data['username'] ?? '',
        name: data['name'] ?? '',
        imageurl: data['image_url'] ?? '',
        fillDetails: data['isfilled'] ?? '',
        provider: data['provider'] ?? '',
        locationname: data['location_name'] ?? '',
        userlat: (data['user_lat'] ?? 0.0).toDouble(),
        userlong: (data['user_long'] ?? 0.0).toDouble(),
        walletAddress: data['wallet_address'] ?? '');
  }
}
