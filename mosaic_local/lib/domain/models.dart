import 'dart:convert';

class BrandProfile {
  const BrandProfile({
    required this.name,
    required this.product,
    required this.audience,
    required this.voice,
    required this.goal,
    this.region = 'Guyana and the Caribbean',
  });

  final String name;
  final String product;
  final String audience;
  final String voice;
  final String goal;
  final String region;

  Map<String, dynamic> toJson() => {
        'name': name,
        'product': product,
        'audience': audience,
        'voice': voice,
        'goal': goal,
        'region': region,
      };

  factory BrandProfile.fromJson(Map<String, dynamic> json) => BrandProfile(
        name: json['name'] as String,
        product: json['product'] as String,
        audience: json['audience'] as String,
        voice: json['voice'] as String,
        goal: json['goal'] as String,
        region: json['region'] as String? ?? 'Guyana and the Caribbean',
      );
}

class CampaignPost {
  const CampaignPost({
    required this.day,
    required this.pillar,
    required this.hook,
    required this.caption,
    required this.cta,
    required this.visual,
    required this.hashtags,
    this.approved = false,
    this.imagePath,
  });

  final int day;
  final String pillar;
  final String hook;
  final String caption;
  final String cta;
  final String visual;
  final List<String> hashtags;
  final bool approved;
  final String? imagePath;

  CampaignPost copyWith({bool? approved, String? caption, String? imagePath}) => CampaignPost(
        day: day,
        pillar: pillar,
        hook: hook,
        caption: caption ?? this.caption,
        cta: cta,
        visual: visual,
        hashtags: hashtags,
        approved: approved ?? this.approved,
        imagePath: imagePath ?? this.imagePath,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'pillar': pillar,
        'hook': hook,
        'caption': caption,
        'cta': cta,
        'visual': visual,
        'hashtags': hashtags,
        'approved': approved,
        'imagePath': imagePath,
      };

  factory CampaignPost.fromJson(Map<String, dynamic> json) => CampaignPost(
        day: (json['day'] as num).toInt(),
        pillar: json['pillar'] as String,
        hook: json['hook'] as String,
        caption: json['caption'] as String,
        cta: json['cta'] as String,
        visual: json['visual'] as String,
        hashtags: List<String>.from(json['hashtags'] as List),
        approved: json['approved'] as bool? ?? false,
        imagePath: json['imagePath'] as String?,
      );
}

class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.strategy,
    required this.posts,
    required this.createdAt,
    this.version = 1,
  });

  final String id;
  final String name;
  final String strategy;
  final List<CampaignPost> posts;
  final DateTime createdAt;
  final int version;

  Campaign copyWith({List<CampaignPost>? posts, int? version}) => Campaign(
        id: id,
        name: name,
        strategy: strategy,
        posts: posts ?? this.posts,
        createdAt: createdAt,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'strategy': strategy,
        'posts': posts.map((post) => post.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'version': version,
      };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        name: json['name'] as String,
        strategy: json['strategy'] as String,
        posts: (json['posts'] as List)
            .map((post) => CampaignPost.fromJson(post as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        version: json['version'] as int? ?? 1,
      );
}

Map<String, dynamic> decodeObject(String response) {
  final start = response.indexOf('{');
  final end = response.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw const FormatException('The model did not return a JSON object.');
  }
  return jsonDecode(response.substring(start, end + 1)) as Map<String, dynamic>;
}
