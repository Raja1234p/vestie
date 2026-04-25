/// Model for the full risk disclaimer status and guidelines.
class RiskDisclaimerModel {
  final String version;
  final List<String> guidelines;
  final bool accepted;

  const RiskDisclaimerModel({
    required this.version,
    required this.guidelines,
    required this.accepted,
  });

  factory RiskDisclaimerModel.fromJson(Map<String, dynamic> json) {
    return RiskDisclaimerModel(
      version: json['version'] as String? ?? '1.0',
      guidelines: (json['guidelines'] as List?)?.map((e) => e.toString()).toList() ?? [],
      accepted: json['accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'guidelines': guidelines,
        'accepted': accepted,
      };
}
