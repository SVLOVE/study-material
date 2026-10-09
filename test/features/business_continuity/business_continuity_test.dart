import 'package:flutter_test/flutter_test.dart';

import 'package:govprep/features/business_continuity/domain/models/service_capability_state.dart';
import 'package:govprep/features/business_continuity/application/services/business_continuity_service.dart';

void main() {
  group('Business Continuity & Graceful Degradation (Phase 82)', () {
    
    setUpAll(() {
      businessContinuityService.initialize();
    });

    tearDownAll(() {
      businessContinuityService.dispose();
    });

    test('Initializes with default capabilities as available', () {
      expect(businessContinuityService.isAvailable('AUTHENTICATION'), isTrue);
      expect(businessContinuityService.isAvailable('PRACTICE'), isTrue);
      expect(businessContinuityService.isAvailable('LEADERBOARD'), isTrue);
    });

    test('Feature isolation: Degrades specific capability without affecting others', () {
      // Degrade Leaderboard
      businessContinuityService.degradeCapabilityDueToIncident('LEADERBOARD', 'Service Timeout');

      final leaderboardState = businessContinuityService.getCapabilityState('LEADERBOARD');
      expect(leaderboardState.availability, CapabilityAvailability.unavailable);
      expect(leaderboardState.reason, 'Service Timeout');

      // Verify Practice remains functional
      expect(businessContinuityService.isAvailable('PRACTICE'), isTrue);
      
      // Verify Authentication remains functional
      expect(businessContinuityService.isAvailable('AUTHENTICATION'), isTrue);
    });

    test('Recovery Lifecycle: unavailable -> recovering -> available', () {
      const capability = 'SEARCH';
      
      businessContinuityService.degradeCapabilityDueToIncident(capability, 'Incident Detected');
      expect(businessContinuityService.isAvailable(capability), isFalse);
      
      businessContinuityService.markCapabilityRecovering(capability);
      final recoveringState = businessContinuityService.getCapabilityState(capability);
      expect(recoveringState.availability, CapabilityAvailability.recovering);

      businessContinuityService.restoreCapability(capability);
      expect(businessContinuityService.isAvailable(capability), isTrue);
    });
    
    test('Handles unknown capability safely', () {
      final unknownState = businessContinuityService.getCapabilityState('NON_EXISTENT_FEATURE');
      expect(unknownState.availability, CapabilityAvailability.unknown);
      expect(businessContinuityService.isAvailable('NON_EXISTENT_FEATURE'), isFalse);
    });
  });
}
