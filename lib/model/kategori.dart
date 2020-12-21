class Kategori {
  String categoryId;
  String lngTitle;
  String lngContent;
  String categoryThumb;

  Kategori(
      {this.categoryId, this.lngTitle, this.lngContent, this.categoryThumb});

  Kategori.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    lngTitle = json['lng_title'];
    lngContent = json['lng_content'];
    categoryThumb = json['category_thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['lng_title'] = this.lngTitle;
    data['lng_content'] = this.lngContent;
    data['category_thumb'] = this.categoryThumb;
    return data;
  }
}
