import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String _uid;
  String _username;
  String _name;
  String _imageUrl;
  bool _fillDetails;
  String _provider;
  String _locationname;
  double _userlat;
  double _userlong;

  UserData(
    this._uid,
    this._username,
    this._name,
    this._imageUrl,
    this._fillDetails,
    this._provider,
    this._locationname,
    this._userlat,
    this._userlong,
  );

  // Getter methods for accessing individual fields
  String get uid => _uid;
  String get username => _username;
  String get name => _name;
  String get imageurl => _imageUrl;
  bool get fillDetails => _fillDetails;
  String get provider => _provider;
  String get locationname => _locationname;
  double get userlat => _userlat;
  double get userlong => _userlong;

  // Factory method to create UserData instance from a Firestore snapshot
  factory UserData.fromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      snapshot['uid'] ?? '',
      snapshot['username'] ?? '',
      snapshot['name'] ?? '', // Default to empty string if the field is null
      snapshot['image_url'] ?? '',
      snapshot['isfilled'] ?? '',
      snapshot['provider'] ?? '',
      snapshot['location_name'] ?? '',
      snapshot['user_lat'] ?? '',
      snapshot['user_long'] ?? '',
    );
  }
}
