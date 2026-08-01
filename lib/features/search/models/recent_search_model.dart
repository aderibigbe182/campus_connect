class RecentSearchModel {
  final String id;

  final String searchText;

  final DateTime searchedAt;

  RecentSearchModel({
    required this.id,
    required this.searchText,
    required this.searchedAt,
  });

  factory RecentSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentSearchModel(
      id: json["id"].toString(),
      searchText:
          json["search_text"] ?? "",
      searchedAt: DateTime.parse(
        json["searched_at"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "search_text": searchText,
      "searched_at":
          searchedAt.toIso8601String(),
    };
  }
}