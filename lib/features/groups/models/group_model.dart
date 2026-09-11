class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? ownerId;
  final int memberCount;
  final DateTime? createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.ownerId,
    this.memberCount = 0,
    this.createdAt,
  });

  factory GroupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description:
          json['description']?.toString(),
      image: json['image']?.toString() ??
          json['group_image']?.toString(),
      ownerId:
          (json['owner_id'] as num?)?.toInt(),
      memberCount:
          (json['member_count'] as num?)?.toInt() ??
              (json['members_count'] as num?)?.toInt() ??
              0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'].toString(),
            )
          : null,
    );
  }
}