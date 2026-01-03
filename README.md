# HyperLog

## Key and Certificate Management in HyperLog

HyperLog ensures users always have access to their logbooks and supports interoperability with other apps running on the Hyperledger Fabric network. The following setup is implemented to manage keys, certificates, and data securely:

### 1. **Public Keys on the Blockchain**
- Each user's **public keys** are stored on the blockchain.
- Public keys are used to verify the authenticity of all historical transactions.
- When a user rotates their key pair (e.g., due to key loss), a new public key is added to the blockchain for future transactions. Older transactions remain verifiable with the previous public keys.

### 2. **Private Keys on the Device**
- Private keys are generated and stored locally on the user's device.
- Platform-specific secure storage is used:
  - **iOS**: Keychain
  - **Android**: Keystore
- Private keys are never stored on the blockchain or shared externally.

### 3. **Key Loss and Recovery**
- **Private Key Loss**: If a private key is lost, users will no longer be able to sign new transactions. However:
  - Historical logbook entries remain accessible and verifiable using their public keys stored on the blockchain.
  - Users can generate a new key pair, update their public key on the blockchain, and continue logging new entries.

### 4. **Certificates and Authentication**
- CA certificates are verified when users log transactions but are not stored on the blockchain.
- This ensures efficient validation without unnecessary storage overhead.

### Benefits
- **Data Integrity**: Public keys on the blockchain enable verification of all historical transactions.
- **Key Management Simplicity**: By not relying on centralized key recovery, users retain full control of their private keys.
- **Interoperability**: Users can connect to other apps in the network and retain their identity.

