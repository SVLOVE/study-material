enum CapabilityAvailability {
  available,
  degraded,
  unavailable,
  recovering,
  unknown,
}

class ServiceCapabilityState {
  final String capability;
  final CapabilityAvailability availability;
  final String? reason;
  final DateTime updatedAt;

  const ServiceCapabilityState({
    required this.capability,
    required this.availability,
    this.reason,
    required this.updatedAt,
  });

  ServiceCapabilityState copyWith({
    String? capability,
    CapabilityAvailability? availability,
    String? reason,
    DateTime? updatedAt,
  }) {
    return ServiceCapabilityState(
      capability: capability ?? this.capability,
      availability: availability ?? this.availability,
      reason: reason ?? this.reason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
