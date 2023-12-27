class BusinessReviewsData {
  BusinessReviewsData({
    this.id = '',
    this.url = '',
    this.text = '',
    this.rating = 0,
    this.time_created = "",
    this.user_id = "",
    this.user_profile_url = "",
    this.user_image_url = "",
    this.user_name = "",
  });

  String id;
  String url;
  String text;
  int rating;
  String time_created;
  String user_id;
  String user_profile_url;
  String user_image_url;
  String user_name;

  static List<BusinessReviewsData> businessReviewsList = <BusinessReviewsData>[];
}
