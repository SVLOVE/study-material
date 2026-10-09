import 'dart:async';

import '../../domain/models/service_capability_state.dart';

class BusinessContinuityService {
  final Map<String, ServiceCapabilityState> _capabilities = {};
  final _stateController = StreamController<Map<String, ServiceCapabilityState>>.broadcast();

  Stream<Map<String, ServiceCapabilityState>> get capabilityStateStream => _stateController.stream;

  void initialize() {
    _registerInitialCapabilities();
  }

  void dispose() {
    _stateController.close();
    _capabilities.clear();
  }

  void _registerInitialCapabilities() {
    final defaultCapabilities = [
      'AUTHENTICATION',
      'EXAM_BROWSING',
      'QUESTION_RETRIEVAL',
      'PRACTICE',
      'MOCK_TEST',
      'RESULTS',
      'PERFORMANCE',
      'REVISION',
      'STUDY_PLAN',
      'SEARCH',
      'CURRENT_AFFAIRS',
      'LEADERBOARD',
      'NOTIFICATIONS',
      'SUBSCRIPTION',
      'BILLING',
      'STUDY_MATERIALS',
    ];

    final now = DateTime.now();
    for (final cap in defaultCapabilities) {
      _capabilities[cap] = ServiceCapabilityState(
        capability: cap,
        availability: CapabilityAvailability.available,
        updatedAt: now,
      );
    }
    _broadcast();
  }

  ServiceCapabilityState getCapabilityState(String capability) {
    return _capabilities[capability] ?? 
      ServiceCapabilityState(
        capability: capability, 
        availability: CapabilityAvailability.unknown, 
        updatedAt: DateTime.now()
      );
  }

  bool isAvailable(String capability) {
    return getCapabilityState(capability).availability == CapabilityAvailability.available;
  }

  /// Maps an incident to capability degradation.
  /// This bridges Phase 78 Incident Detection to Phase 82 Business Continuity.
  void degradeCapabilityDueToIncident(String capability, String reason) {
    if (!_capabilities.containsKey(capability)) return;

    _capabilities[capability] = ServiceCapabilityState(
      capability: capability,
      availability: CapabilityAvailability.unavailable,
      reason: reason,
      updatedAt: DateTime.now(),
    );
    _broadcast();
  }

  /// Marks a capability as recovering.
  void markCapabilityRecovering(String capability) {
    if (!_capabilities.containsKey(capability)) return;

    _capabilities[capability] = ServiceCapabilityState(
      capability: capability,
      availability: CapabilityAvailability.recovering,
      reason: 'Validation in progress',
      updatedAt: DateTime.now(),
    );
    _broadcast();
  }

  /// Revalidates and restores a capability to fully available.
  void restoreCapability(String capability) {
    if (!_capabilities.containsKey(capability)) return;

    _capabilities[capability] = ServiceCapabilityState(
      capability: capability,
      availability: CapabilityAvailability.available,
      reason: null,
      updatedAt: DateTime.now(),
    );
    _broadcast();
  }

  void _broadcast() {
    _stateController.add(Map.unmodifiable(_capabilities));
  }
}

final businessContinuityService = BusinessContinuityService();
