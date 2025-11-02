class AppSecrets {
  // Match Facebook App configured in Firebase Auth provider and Android strings.xml
  static const String facebookAppId = '1881845609435665';
  // Optional: Set to the Client Token of the same Facebook App in Meta console
  // Keeping previous value may cause warnings; replace with real token when available
  static const String facebookClientToken = 'f95d026048c6b12974492c04908892fc';

  // Web SDK version to initialize. Use a supported Graph API version string.
  static const String facebookWebSdkVersion = 'v20.0';
}
