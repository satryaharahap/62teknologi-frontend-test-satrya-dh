import 'dart:convert';

import 'package:enamduatekno/business/businessSearchPage.dart';
import 'package:enamduatekno/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
var AuthKey = Api.ApiKey;
final List<String> searchList = [];
Future getBusiness(search) async {

  var url;
  url = 'https://api.yelp.com/v3/autocomplete?text='+search;

  print('url'+url);
  final responce = await http.get(Uri.parse(url),
      headers: {
        "Authorization": 'Bearer ${AuthKey}'
      }
  );
  final responceData = json.decode(responce.body);
  print(responceData);
  var jsonData = responceData['terms'];
  searchList.clear();
  for (var data in jsonData){
    searchList.add(data['text']);
  }

  return responceData['terms'];
}
List<String> getResults(String query) {
  // apply getting results logic here
  return [];
}
class  MySearchDelegant extends SearchDelegate{
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.clear),
        ),
      )
    ];
  }



  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      Navigator.of(context).pop();
    }, icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = getResults(query);
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          // assuming `DetailsPage` exists
          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: businessSearchPage(search:query.toLowerCase().toString())));
        },
        title: Text(results[index]),
      ),
      itemCount: results.length,
    );

  }

  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder(
      future: getBusiness(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<String> suggestionList = query.isEmpty
              ? []
              : searchList
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestionList[index]),
                onTap: () {
                  query = suggestionList[index];
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: businessSearchPage(search:query.toLowerCase().toString())));
                  // Show the search results based on the selected suggestion.
                },
              );
            },
          );
        }
        return SizedBox(height: 10);
      },
    );


  }
}