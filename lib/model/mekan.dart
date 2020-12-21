class Mekan {
  String placeId;
  String placeLat;
  String placeLong;
  String lngTitle;
  String lngContent;
  String likeCount;
  String thumb;

  Mekan(
      {this.placeId,
      this.placeLat,
      this.placeLong,
      this.lngTitle,
      this.lngContent,
      this.likeCount,
      this.thumb});

  Mekan.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    placeLat = json['place_lat'];
    placeLong = json['place_long'];
    lngTitle = json['lng_title'];
    lngContent = json['lng_content'];
    likeCount = json['like_count'];
    thumb = json['thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['place_lat'] = this.placeLat;
    data['place_long'] = this.placeLong;
    data['lng_title'] = this.lngTitle;
    data['lng_content'] = this.lngContent;
    data['like_count'] = this.likeCount;
    data['thumb'] = this.thumb;
    return data;
  }
}
