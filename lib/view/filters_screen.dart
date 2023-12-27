import 'package:enamduatekno/model/popular_filter_list.dart';
import 'package:enamduatekno/view/slider_price_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'slider_view.dart';
import '../app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiltersScreen extends StatefulWidget {
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  List<PopularFilterListData> popularFilterListData =
      PopularFilterListData.popularFList;
  List<PopularFilterListData> opennowListData =
      PopularFilterListData.OpenNowList;

  double pricevalue = 2.0;
  bool _valuesopennow = false;
  double distValue = 40.0;
  int distValueConverter = 0;
  int priceValueConverter = 0;
  late List dataSortBy=['best_match','rating','review_count','distance'];
  var sortbyvalue;
  var categorydata;
  final List<String> datalistcategory = [];
  TextEditingController textLocation = TextEditingController();
  TextEditingController textLatitude = TextEditingController();
  TextEditingController textLongitude = TextEditingController();
  late SharedPreferences pref;

  void initial() async {
    pref = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initial();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.buildLightTheme().backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            getAppBarUI(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    locationBarFilter(),
                    const Divider(
                      height: 1,
                    ),
                    sortBarFilter(),
                    const Divider(
                      height: 1,
                    ),
                    priceBarFilter(),
                    const Divider(
                      height: 1,
                    ),
                    popularFilter(),
                    const Divider(
                      height: 1,
                    ),
                    distanceViewUI(),
                    const Divider(
                      height: 1,
                    ),
                    allAccommodationUI()
                  ],
                ),
              ),
            ),
            const Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.mainColor,
                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    highlightColor: Colors.transparent,
                    onTap: () {
                      distValueConverter = (distValue * 100).toInt();
                      priceValueConverter = (pricevalue).toInt();
                      pref.setString('searchlocation', textLocation.text);
                      pref.setString('searchlatitude', textLatitude.text);
                      pref.setString('searchlongitude', textLongitude.text);
                      if(sortbyvalue==null){
                        sortbyvalue = "";
                      }
                      pref.setString('sortby', sortbyvalue);
                      pref.setString('searchdistance', distValueConverter.toString());
                      pref.setString('searchprices', priceValueConverter.toString());
                      pref.setString('opennow', _valuesopennow.toString());
                      datalistcategory.clear();
                      for (int i = 0; i < popularFilterListData.length; i++) {
                        final PopularFilterListData date = popularFilterListData[i];
                        if(date.isSelected)
                        datalistcategory.add(date.titleTxt);
                      }
                      pref.setStringList('searchcategory', datalistcategory);

                      Navigator.of(context, rootNavigator: true).pop("load_data");
                    },
                    child: Center(
                      child: Text(
                        'Apply',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget allAccommodationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'Open',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: getAccomodationListUI(),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  List<Widget> getAccomodationListUI() {
    final List<Widget> noList = <Widget>[];
    for (int i = 0; i < opennowListData.length; i++) {
      final PopularFilterListData date = opennowListData[i];
      noList.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            onTap: () {
              setState(() {
                checkAppPosition(i);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      date.titleTxt,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  CupertinoSwitch(
                    activeColor: date.isSelected
                        ? AppTheme.mainColor
                        : Colors.grey.withOpacity(0.6),
                    onChanged: (bool value) {
                      setState(() {
                        checkAppPosition(i);
                        _valuesopennow = value;
                      });
                    },
                    value: date.isSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (i == 0) {
        noList.add(const Divider(
          height: 1,
        ));
      }
    }
    return noList;
  }

  void checkAppPosition(int index) {
    if (index == 0) {
      if (opennowListData[0].isSelected) {
        opennowListData.forEach((d) {
          d.isSelected = false;
        });
      } else {
        opennowListData.forEach((d) {
          d.isSelected = true;
        });
      }
    } else {
      opennowListData[index].isSelected =
          !opennowListData[index].isSelected;

      int count = 0;
      for (int i = 0; i < opennowListData.length; i++) {
        if (i != 0) {
          final PopularFilterListData data = opennowListData[i];
          if (data.isSelected) {
            count += 1;
          }
        }
      }

      if (count == opennowListData.length - 1) {
        opennowListData[0].isSelected = true;
      } else {
        opennowListData[0].isSelected = false;
      }
    }
  }

  Widget distanceViewUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'Distance from city center',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        SliderView(
          distValue: distValue,
          onChangedistValue: (double value) {
            distValue = value;

          },
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget popularFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'Categories',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Column(
            children: getPList(),
          ),
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  List<Widget> getPList() {
    final List<Widget> noList = <Widget>[];
    int count = 0;
    const int columnCount = 2;
    for (int i = 0; i < popularFilterListData.length / columnCount; i++) {
      final List<Widget> listUI = <Widget>[];
      for (int i = 0; i < columnCount; i++) {
        try {
          final PopularFilterListData date = popularFilterListData[count];
          listUI.add(Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      setState(() {
                        date.isSelected = !date.isSelected;
                        datalistcategory.add(date.titleTxt);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            date.isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: date.isSelected
                                ? AppTheme.mainColor
                                : Colors.grey.withOpacity(0.6),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            date.titleTxt,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
          if (count < popularFilterListData.length - 1) {
            count += 1;
          } else {
            break;
          }
        } catch (e) {
          print(e);
        }
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ));
    }
    return noList;
  }
  Widget locationBarFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Location & Latitude, Longitude',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: textLocation,
            decoration: InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                  borderRadius: BorderRadius.circular(10.0)),
              enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: AppTheme.grey),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: AppTheme.mainColor),
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: textLatitude,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                          borderRadius: BorderRadius.circular(10.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: AppTheme.grey),
                          borderRadius: BorderRadius.circular(10.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: AppTheme.mainColor),
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 4, bottom: 4),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: textLongitude,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                          borderRadius: BorderRadius.circular(10.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: AppTheme.grey),
                          borderRadius: BorderRadius.circular(10.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: AppTheme.mainColor),
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ),


            ],
          )
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget sortBarFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 4, bottom: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Sort By',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 4, bottom: 4),
                    child: Column(
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children: <Widget> [
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: new BorderSide(color: AppTheme.grey),
                                    borderRadius: BorderRadius.circular(10.0)),
                                border: OutlineInputBorder( borderSide: new BorderSide(color: AppTheme.grey),
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: new BorderSide(color: AppTheme.mainColor),
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                              hint: Text("Sort By"),
                              value: sortbyvalue,
                              items: dataSortBy.map((label) {
                                return DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  sortbyvalue = value;
                                });
                              },
                            ),
                          ),
                        ]
                    ),
                  ),
                ),


              ],
            )
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget priceBarFilter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Price',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        SliderPriceView(
          priceValue: pricevalue,
          onChangepriceValue: (double value) {
            pricevalue = value;

          },
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.buildLightTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 4.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Container(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
            )
          ],
        ),
      ),
    );
  }
}
