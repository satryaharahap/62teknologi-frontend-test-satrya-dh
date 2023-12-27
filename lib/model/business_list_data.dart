class BusinessData {
  BusinessData({
    this.id = '',
    this.alias = '',
    this.name = '',
    this.image_url = '',
    this.is_closed = '',
    this.url = '',
    this.review_count = 0,
    this.categories = '',
    this.rating = 0.0,
    this.coordinates = '',
    this.transactions = '',
    this.price = '',
    this.location = '',
    this.display_phone = '',
    this.distance = ''
  });

  String id;
  String alias;
  String name;
  String image_url;
  String is_closed;
  String url;
  int review_count;
  String categories;
  double rating;
  String coordinates;
  String transactions;
  String price;
  String location;
  String display_phone;
  String distance;

  static List<BusinessData> businessList = <BusinessData>[];
}
