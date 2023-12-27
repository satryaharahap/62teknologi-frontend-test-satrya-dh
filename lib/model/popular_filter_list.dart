class PopularFilterListData {
  PopularFilterListData({
    this.titleTxt = '',
    this.isSelected = false,
  });

  String titleTxt;
  bool isSelected;

  static List<PopularFilterListData> popularFList = <PopularFilterListData>[
    PopularFilterListData(
      titleTxt: 'bakeries',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'desserts',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'fooddeliveryservices',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'foodtrucks',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'mexican',
      isSelected: false,
    ),
  ];

  static List<PopularFilterListData> OpenNowList = [
    PopularFilterListData(
      titleTxt: 'Open Now',
      isSelected: false,
    )
  ];
}
