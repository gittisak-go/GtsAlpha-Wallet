/// Digital card model – นามบัตรดิจิทัล.
class DigitalCard {
  const DigitalCard({
    required this.id,
    required this.userId,
    required this.name,
    this.title,
    this.company,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.socialLinks,
    this.qrCodeUrl,
    this.nfcTagId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? title;
  final String? company;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final Map<String, String>? socialLinks;
  final String? qrCodeUrl;
  final String? nfcTagId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DigitalCard.fromJson(Map<String, dynamic> json) {
    final links = json['social_links'];
    return DigitalCard(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      title: json['title'] as String?,
      company: json['company'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      socialLinks: links is Map
          ? Map<String, String>.from(links as Map)
          : null,
      qrCodeUrl: json['qr_code_url'] as String?,
      nfcTagId: json['nfc_tag_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'title': title,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'social_links': socialLinks,
      'qr_code_url': qrCodeUrl,
      'nfc_tag_id': nfcTagId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DigitalCard copyWith({
    String? id,
    String? userId,
    String? name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
    Map<String, String>? socialLinks,
    String? qrCodeUrl,
    String? nfcTagId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DigitalCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      socialLinks: socialLinks ?? this.socialLinks,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
