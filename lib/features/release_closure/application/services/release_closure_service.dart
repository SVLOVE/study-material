import 'dart:async';

import '../../domain/models/release_closure_state.dart';

class ReleaseClosureService {
  final Map<String, ReleaseLifecycleRecord> _history = {};
  String? _currentBaselineId;

  void initialize() {}

  void dispose() {}

  ReleaseLifecycleRecord? getRecord(String releaseId) => _history[releaseId];

  String? get currentBaselineId => _currentBaselineId;

  /// Phase 92: Closes the release lifecycle and establishes it as a historical baseline
  Future<ReleaseLifecycleRecord> closeRelease({
    required String releaseId,
    required bool isFinalizedKnownGood,
    required bool hasMissingPrerequisites,
  }) async {
    
    // Evaluate Pre-Closure Validation
    if (hasMissingPrerequisites) {
      final blockedRecord = ReleaseLifecycleRecord(
        releaseId: releaseId,
        status: ReleaseClosureStatus.blocked,
      );
      _history[releaseId] = blockedRecord;
      return blockedRecord;
    }

    if (!isFinalizedKnownGood) {
      final blockedRecord = ReleaseLifecycleRecord(
        releaseId: releaseId,
        status: ReleaseClosureStatus.blocked,
      );
      _history[releaseId] = blockedRecord;
      return blockedRecord;
    }

    // Process Supersession for the existing baseline
    if (_currentBaselineId != null && _currentBaselineId != releaseId) {
      final oldBaseline = _history[_currentBaselineId!];
      if (oldBaseline != null) {
        _history[_currentBaselineId!] = oldBaseline.copyWith(
          status: ReleaseClosureStatus.superseded,
          supersededAt: DateTime.now(),
        );
      }
    }

    // Close Current Release
    final closedRecord = ReleaseLifecycleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      releaseId: releaseId,
      status: ReleaseClosureStatus.closed,
      closedAt: DateTime.now(),
    );

    _history[releaseId] = closedRecord;
    _currentBaselineId = releaseId;

    return closedRecord;
  }
}

final releaseClosureService = ReleaseClosureService();
