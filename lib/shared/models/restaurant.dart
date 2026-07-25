import 'package:flutter/material.dart';

/// Identity, contact details and service rules for one tenant.
///
/// Everything a screen needs to brand itself lives here, so onboarding a new
/// restaurant is a data change rather than a code change.
@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.slug,
    required this.name,
    required this.legalName,
    required this.tagline,
    required this.description,
    required this.logo,
    required this.cuisines,
    required this.rating,
    required this.ratingCount,
    required this.priceForTwo,
    required this.ownerName,
    required this.contact,
    required this.address,
    required this.service,
    required this.hours,
    required this.highlights,
  });

  final String id;
  final String slug;
  final String name;
  final String legalName;
  final String tagline;
  final String description;
  final String logo;
  final List<String> cuisines;
  final double rating;
  final int ratingCount;
  final int priceForTwo;
  final String ownerName;
  final RestaurantContact contact;
  final RestaurantAddress address;
  final ServiceSettings service;
  final List<OpeningHours> hours;
  final List<RestaurantHighlight> highlights;

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        legalName: json['legalName'] as String? ?? json['name'] as String,
        tagline: json['tagline'] as String? ?? '',
        description: json['description'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
        cuisines: (json['cuisines'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
        priceForTwo: (json['priceForTwo'] as num?)?.toInt() ?? 0,
        ownerName: json['ownerName'] as String? ?? '',
        contact: RestaurantContact.fromJson(
          json['contact'] as Map<String, dynamic>? ?? const {},
        ),
        address: RestaurantAddress.fromJson(
          json['address'] as Map<String, dynamic>? ?? const {},
        ),
        service: ServiceSettings.fromJson(
          json['service'] as Map<String, dynamic>? ?? const {},
        ),
        hours: (json['hours'] as List<dynamic>? ?? const [])
            .map((e) => OpeningHours.fromJson(e as Map<String, dynamic>))
            .toList(),
        highlights: (json['highlights'] as List<dynamic>? ?? const [])
            .map((e) => RestaurantHighlight.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Whether the kitchen is taking orders at [now], per today's opening hours.
  bool isOpenAt(DateTime now) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final today = names[now.weekday - 1];
    for (final slot in hours) {
      if (slot.day != today) continue;
      final minutes = now.hour * 60 + now.minute;
      return minutes >= slot.opensAtMinutes && minutes <= slot.closesAtMinutes;
    }
    return false;
  }

  OpeningHours? hoursFor(String day) {
    for (final slot in hours) {
      if (slot.day == day) return slot;
    }
    return null;
  }
}

@immutable
class RestaurantContact {
  const RestaurantContact({
    required this.phonePrimary,
    required this.phoneSecondary,
    required this.email,
    required this.instagram,
  });

  final String phonePrimary;
  final String phoneSecondary;
  final String email;
  final String instagram;

  factory RestaurantContact.fromJson(Map<String, dynamic> json) =>
      RestaurantContact(
        phonePrimary: json['phonePrimary'] as String? ?? '',
        phoneSecondary: json['phoneSecondary'] as String? ?? '',
        email: json['email'] as String? ?? '',
        instagram: json['instagram'] as String? ?? '',
      );
}

@immutable
class RestaurantAddress {
  const RestaurantAddress({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.landmark,
  });

  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final String landmark;

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) =>
      RestaurantAddress(
        line1: json['line1'] as String? ?? '',
        line2: json['line2'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        landmark: json['landmark'] as String? ?? '',
      );

  String get short => [line1, line2].where((s) => s.isNotEmpty).join(', ');

  String get full => [line1, line2, city, state, postalCode]
      .where((s) => s.isNotEmpty)
      .join(', ');
}

/// Ordering rules — what the restaurant offers and what it charges.
@immutable
class ServiceSettings {
  const ServiceSettings({
    required this.dineIn,
    required this.takeaway,
    required this.delivery,
    required this.deliveryRadiusKm,
    required this.deliveryMinimumOrder,
    required this.deliveryFee,
    required this.freeDeliveryNote,
    required this.averagePrepMinutes,
    required this.packagingCharge,
    required this.taxPercent,
  });

  final bool dineIn;
  final bool takeaway;
  final bool delivery;
  final double deliveryRadiusKm;
  final int deliveryMinimumOrder;
  final int deliveryFee;
  final String freeDeliveryNote;
  final int averagePrepMinutes;
  final int packagingCharge;
  final double taxPercent;

  factory ServiceSettings.fromJson(Map<String, dynamic> json) =>
      ServiceSettings(
        dineIn: json['dineIn'] as bool? ?? true,
        takeaway: json['takeaway'] as bool? ?? true,
        delivery: json['delivery'] as bool? ?? false,
        deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toDouble() ?? 0,
        deliveryMinimumOrder:
            (json['deliveryMinimumOrder'] as num?)?.toInt() ?? 0,
        deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 0,
        freeDeliveryNote: json['freeDeliveryNote'] as String? ?? '',
        averagePrepMinutes: (json['averagePrepMinutes'] as num?)?.toInt() ?? 20,
        packagingCharge: (json['packagingCharge'] as num?)?.toInt() ?? 0,
        taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 0,
      );
}

@immutable
class OpeningHours {
  const OpeningHours({
    required this.day,
    required this.opensAt,
    required this.closesAt,
  });

  final String day;
  final String opensAt;
  final String closesAt;

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        day: json['day'] as String? ?? '',
        opensAt: json['opensAt'] as String? ?? '00:00',
        closesAt: json['closesAt'] as String? ?? '00:00',
      );

  static int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  int get opensAtMinutes => _minutes(opensAt);
  int get closesAtMinutes => _minutes(closesAt);

  String get range => '$opensAt – $closesAt';
}

/// A short selling point shown as a chip on the customer hero.
@immutable
class RestaurantHighlight {
  const RestaurantHighlight({
    required this.icon,
    required this.label,
    required this.value,
  });

  /// Semantic icon key, mapped to an [IconData] by the presentation layer so
  /// tenant data never imports Flutter symbols.
  final String icon;
  final String label;
  final String value;

  factory RestaurantHighlight.fromJson(Map<String, dynamic> json) =>
      RestaurantHighlight(
        icon: json['icon'] as String? ?? 'star',
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );
}
