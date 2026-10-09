import 'dart:async';

import '../../domain/models/release_exposure_state.dart';

class ReleaseExposureService {
  ReleaseExposureContext? _currentExposure;

  void initialize() {}

  void dispose() {}

  ReleaseExposureContext? get currentExposure => _currentExposure;

  /// Phase 89: Evaluates and orchestrates the exposure of a deployment.
  /// Consumes signals from Phase 88 (Compatibility), Phase 86 (Readiness), and Phase 87 (Verification).
  Future<ReleaseExposureContext> evaluateExposure({
    required String releaseId,
    required bool isCompatible,
    required bool isVerified,
    required bool isStable,
  }) async {
    
    // 1. Evaluate Eligibility
    if (!isCompatible) {
      return _updateExposure(
        releaseId: releaseId,
        status: ReleaseExposureStatus.blocked,
        eligible: false,
        reason: 'Blocked: Release is incompatible with current constraints.',
      );
    }

    if (!isVerified) {
      return _updateExposure(
        releaseId: releaseId,
        status: ReleaseExposureStatus.held,
        eligible: false,
        reason: 'Held: Post-deployment validation is incomplete or failed.',
      );
    }

    // 2. Determine Exposure Action
    ReleaseExposureStatus finalStatus;
    ReleaseExposureScope finalScope;
    String reason;

    if (!isStable) {
      finalStatus = ReleaseExposureStatus.reduced;
      finalScope = ReleaseExposureScope.internal;
      reason = 'Reduced: Release shows instability; exposure constrained to internal safety scope.';
    } else {
      finalStatus = ReleaseExposureStatus.active;
      finalScope = ReleaseExposureScope.general;
      reason = 'Eligible: Release is compatible, verified, and stable. Full exposure authorized.';
    }

    return _updateExposure(
      releaseId: releaseId,
      status: finalStatus,
      scope: finalScope,
      eligible: isStable,
      reason: reason,
    );
  }

  ReleaseExposureContext _updateExposure({
    required String releaseId,
    required ReleaseExposureStatus status,
    required bool eligible,
    required String reason,
    ReleaseExposureScope scope = ReleaseExposureScope.internal,
  }) {
    _currentExposure = ReleaseExposureContext(
      releaseId: releaseId,
      status: status,
      scope: scope,
      eligible: eligible,
      reason: reason,
      evaluatedAt: DateTime.now(),
    );
    return _currentExposure!;
  }
}

final releaseExposureService = ReleaseExposureService();
