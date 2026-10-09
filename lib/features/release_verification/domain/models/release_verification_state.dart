enum ReleaseVerificationStatus {
  notRequired,
  pending,
  validating,
  partiallyValidated,
  passed,
  blocked,
  failed,
  accepted,
  partiallyAccepted,
  rejected,
  rolledBack,
  unknown,
}

class ReleaseVerificationResult {
  final String releaseId;
  final ReleaseVerificationStatus status;
  final bool applicationVerified;
  final bool authVerified;
  final bool authorizationVerified;
  final bool databaseVerified;
  final bool apiVerified;
  final bool learningStateVerified;
  final bool paymentVerified;
  final bool storageVerified;
  final bool routingVerified;
  final bool localizationVerified;
  final bool securityVerified;
  final DateTime? verifiedAt;

  const ReleaseVerificationResult({
    required this.releaseId,
    this.status = ReleaseVerificationStatus.unknown,
    this.applicationVerified = false,
    this.authVerified = false,
    this.authorizationVerified = false,
    this.databaseVerified = false,
    this.apiVerified = false,
    this.learningStateVerified = false,
    this.paymentVerified = false,
    this.storageVerified = false,
    this.routingVerified = false,
    this.localizationVerified = false,
    this.securityVerified = false,
    this.verifiedAt,
  });

  ReleaseVerificationResult copyWith({
    ReleaseVerificationStatus? status,
    bool? applicationVerified,
    bool? authVerified,
    bool? authorizationVerified,
    bool? databaseVerified,
    bool? apiVerified,
    bool? learningStateVerified,
    bool? paymentVerified,
    bool? storageVerified,
    bool? routingVerified,
    bool? localizationVerified,
    bool? securityVerified,
    DateTime? verifiedAt,
  }) {
    return ReleaseVerificationResult(
      releaseId: releaseId,
      status: status ?? this.status,
      applicationVerified: applicationVerified ?? this.applicationVerified,
      authVerified: authVerified ?? this.authVerified,
      authorizationVerified: authorizationVerified ?? this.authorizationVerified,
      databaseVerified: databaseVerified ?? this.databaseVerified,
      apiVerified: apiVerified ?? this.apiVerified,
      learningStateVerified: learningStateVerified ?? this.learningStateVerified,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      storageVerified: storageVerified ?? this.storageVerified,
      routingVerified: routingVerified ?? this.routingVerified,
      localizationVerified: localizationVerified ?? this.localizationVerified,
      securityVerified: securityVerified ?? this.securityVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
