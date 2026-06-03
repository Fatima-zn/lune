class LookingFor {
  final bool? guests;
  final bool? cohosts;
  final bool? sponsors;
  final bool? crossPromotion;

  const LookingFor({
    this.guests,
    this.cohosts,
    this.sponsors,
    this.crossPromotion,
  });

  factory LookingFor.fromJson(Map<String, dynamic> json) {
    return LookingFor(
      guests: json['guests'] as bool?,
      cohosts: json['cohosts'] as bool?,
      sponsors: json['sponsors'] as bool?,
      crossPromotion: json['cross_promotion'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (guests != null) 'guests': guests,
      if (cohosts != null) 'cohosts': cohosts,
      if (sponsors != null) 'sponsors': sponsors,
      if (crossPromotion != null) 'cross_promotion': crossPromotion,
    };
  }
}