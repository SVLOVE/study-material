import 'dart:async';
import '../../domain/models/learning_state_snapshot.dart';
import '../../../learning_state_consistency/domain/models/learning_state_consistency.dart';

class LearningStateSnapshotService {
  final Map<String, LearningStateSnapshot> _cachedSnapshots = {};
  
  // Stream controller to notify UI of freshness changes without full reloads
  final _snapshotController = StreamController<LearningStateSnapshot>.broadcast();
  Stream<LearningStateSnapshot> get snapshotStream => _snapshotController.stream;

  Future<LearningStateSnapshot> getSnapshot({
    required String userId,
    String scopeType = 'global',
    String? scopeId,
  }) async {
    final key = '${userId}_${scopeType}_$scopeId';
    
    // In a real app, this would fetch from backend/Supabase
    await Future.delayed(const Duration(milliseconds: 100));

    if (_cachedSnapshots.containsKey(key)) {
      return _cachedSnapshots[key]!;
    }

    final snapshot = LearningStateSnapshot(
      id: 'snap-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      scopeType: scopeType,
      scopeId: scopeId,
      stateVersion: 1,
      generatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: LearningStateFreshness.current,
    );

    _cachedSnapshots[key] = snapshot;
    return snapshot;
  }

  Future<void> invalidateState({
    required String userId,
    String scopeType = 'global',
    String? scopeId,
    required DateTime latestEvidenceAt,
  }) async {
    final key = '${userId}_${scopeType}_$scopeId';
    
    // Mark as stale because new evidence exists that is not yet incorporated into version
    if (_cachedSnapshots.containsKey(key)) {
      final current = _cachedSnapshots[key]!;
      final updated = LearningStateSnapshot(
        id: current.id,
        userId: current.userId,
        scopeType: current.scopeType,
        scopeId: current.scopeId,
        stateVersion: current.stateVersion,
        generatedAt: current.generatedAt,
        latestEvidenceAt: latestEvidenceAt,
        status: LearningStateFreshness.stale,
      );
      _cachedSnapshots[key] = updated;
      _snapshotController.add(updated);
    }
  }

  Future<void> markUpdating({
    required String userId,
    String scopeType = 'global',
    String? scopeId,
  }) async {
    final key = '${userId}_${scopeType}_$scopeId';
    
    if (_cachedSnapshots.containsKey(key)) {
      final current = _cachedSnapshots[key]!;
      final updated = LearningStateSnapshot(
        id: current.id,
        userId: current.userId,
        scopeType: current.scopeType,
        scopeId: current.scopeId,
        stateVersion: current.stateVersion,
        generatedAt: current.generatedAt,
        latestEvidenceAt: current.latestEvidenceAt,
        status: LearningStateFreshness.updating,
      );
      _cachedSnapshots[key] = updated;
      _snapshotController.add(updated);
    }
  }

  Future<void> publishNewVersion({
    required String userId,
    String scopeType = 'global',
    String? scopeId,
    required DateTime latestEvidenceAt,
  }) async {
    final key = '${userId}_${scopeType}_$scopeId';
    
    int newVersion = 1;
    if (_cachedSnapshots.containsKey(key)) {
      newVersion = _cachedSnapshots[key]!.stateVersion + 1;
    }

    final updated = LearningStateSnapshot(
      id: 'snap-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      scopeType: scopeType,
      scopeId: scopeId,
      stateVersion: newVersion,
      generatedAt: DateTime.now(),
      latestEvidenceAt: latestEvidenceAt,
      status: LearningStateFreshness.current,
    );
    
    _cachedSnapshots[key] = updated;
    _snapshotController.add(updated);
  }
}

final learningStateSnapshotService = LearningStateSnapshotService();
