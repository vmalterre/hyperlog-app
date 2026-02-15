import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for profile photo operations (pick, upload, delete)
///
/// Uses Firebase Auth UID for storage paths so security rules can
/// validate ownership (request.auth.uid == userId in path).
class PhotoService {
  final ImagePicker _picker;
  final FirebaseStorage _storage;

  PhotoService({ImagePicker? picker, FirebaseStorage? storage})
      : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance;

  String get _authUid => FirebaseAuth.instance.currentUser!.uid;

  /// Pick a photo from the gallery
  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    return xFile != null ? File(xFile.path) : null;
  }

  /// Take a photo with the camera
  Future<File?> takePhoto() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    return xFile != null ? File(xFile.path) : null;
  }

  /// Upload a profile photo to Firebase Storage
  /// Returns the download URL
  Future<String> uploadProfilePhoto(File file) async {
    final ref = _storage.ref().child('users/$_authUid/profile.jpg');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  /// Delete a profile photo from Firebase Storage
  Future<void> deleteProfilePhoto() async {
    try {
      final ref = _storage.ref().child('users/$_authUid/profile.jpg');
      await ref.delete();
    } on FirebaseException catch (e) {
      // Ignore "object not found" — already deleted
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
