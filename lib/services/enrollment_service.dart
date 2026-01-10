import 'package:hyperlog/models/blockchain_identity.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/services/key_management_service.dart';

/// Enrollment Service
///
/// Handles the enrollment flow for Official tier pilots:
/// 1. Generate key pair on device
/// 2. Create CSR (Certificate Signing Request)
/// 3. Send CSR to API for Fabric CA enrollment
/// 4. Receive signed certificate
/// 5. Store private key and certificate securely
///
/// CRITICAL: Private key NEVER leaves the device.
class EnrollmentService {
  final ApiService _apiService;
  final KeyManagementService _keyManager;

  EnrollmentService({
    ApiService? apiService,
    KeyManagementService? keyManager,
  })  : _apiService = apiService ?? ApiService(),
        _keyManager = keyManager ?? KeyManagementService();

  /// Check if the user already has a blockchain identity enrolled
  Future<bool> hasBlockchainIdentity(String userId) async {
    final enrollmentId = 'pilot-$userId';
    return await _keyManager.hasKey(enrollmentId);
  }

  /// Enroll a pilot with Fabric CA
  ///
  /// @param userId - PostgreSQL UUID of the user
  /// @param deviceId - Optional device identifier
  /// @returns BlockchainIdentity with enrollment details
  Future<BlockchainIdentity> enrollPilot(
    String userId, {
    String? deviceId,
  }) async {
    final enrollmentId = 'pilot-$userId';

    // Check if already enrolled
    if (await _keyManager.hasKey(enrollmentId)) {
      throw EnrollmentException('Pilot already enrolled on this device');
    }

    // 1. Generate key pair on device
    final keyPair = await _keyManager.generateKeyPair();
    final privateKeyPem = keyPair['privateKey']!;

    // 2. Create CSR
    final csr = await _keyManager.createCSR(enrollmentId, privateKeyPem);

    // 3. Send CSR to API
    final response = await _apiService.post(
      '/identity/enroll',
      {
        'userId': userId,
        'csr': csr,
        'deviceId': deviceId,
      },
    );

    final data = response['data'] as Map<String, dynamic>;

    // 4. Store private key and certificate securely
    await _keyManager.storePrivateKey(enrollmentId, privateKeyPem);
    await _keyManager.storeCertificate(enrollmentId, data['certificate']);

    // 5. Return blockchain identity
    return BlockchainIdentity(
      uuid: userId,
      enrollmentId: data['enrollmentId'],
      certificatePem: data['certificate'],
      attestations: [], // Attestations added separately after identity verification
      publicKeys: [],
      status: 'active',
      issuedAt: DateTime.parse(data['issuedAt']),
      expiresAt: DateTime.parse(data['expiresAt']),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Rotate key for an existing enrollment (e.g., new device)
  ///
  /// @param userId - PostgreSQL UUID of the user
  /// @param deviceId - New device identifier
  Future<BlockchainIdentity> rotateKey(
    String userId, {
    String? deviceId,
  }) async {
    final enrollmentId = 'pilot-$userId';

    // 1. Generate new key pair
    final keyPair = await _keyManager.generateKeyPair();
    final privateKeyPem = keyPair['privateKey']!;

    // 2. Create CSR
    final csr = await _keyManager.createCSR(enrollmentId, privateKeyPem);

    // 3. Send rotation request to API
    final response = await _apiService.post(
      '/identity/rotate-key',
      {
        'userId': userId,
        'csr': csr,
        'deviceId': deviceId,
      },
    );

    final data = response['data'] as Map<String, dynamic>;

    // 4. Store new private key and certificate
    await _keyManager.storePrivateKey(enrollmentId, privateKeyPem);
    await _keyManager.storeCertificate(enrollmentId, data['certificate']);

    return BlockchainIdentity(
      uuid: userId,
      enrollmentId: data['enrollmentId'],
      certificatePem: data['certificate'],
      attestations: [],
      publicKeys: [],
      status: 'active',
      issuedAt: DateTime.parse(data['issuedAt']),
      expiresAt: DateTime.parse(data['expiresAt']),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Report lost device and revoke the certificate
  Future<void> reportLostDevice(String userId) async {
    await _apiService.post(
      '/identity/revoke',
      {
        'userId': userId,
        'reason': 'lost_device',
      },
    );

    // Delete local keys
    final enrollmentId = 'pilot-$userId';
    await _keyManager.deleteKey(enrollmentId);
  }

  /// Get the blockchain identity for a user
  Future<BlockchainIdentity?> getBlockchainIdentity(String userId) async {
    try {
      final response = await _apiService.get('/identity/$userId');
      final data = response['data'] as Map<String, dynamic>;
      return BlockchainIdentity.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Sign a transaction with the enrolled identity
  Future<String> signTransaction(String userId, String payload) async {
    final enrollmentId = 'pilot-$userId';
    return await _keyManager.signTransaction(enrollmentId, payload);
  }
}

/// Exception thrown during enrollment
class EnrollmentException implements Exception {
  final String message;
  EnrollmentException(this.message);

  @override
  String toString() => 'EnrollmentException: $message';
}
