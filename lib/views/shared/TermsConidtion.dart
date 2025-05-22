import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class TermsCondition extends StatelessWidget {
  TermsCondition({super.key});
  final List<String> items = [
    "banana",
    "mango",
    "apple",
    "cars",
    "trees",
    "walls",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownSearch<String>(
          items: (filter, loadProps) {
            return items;
          },
          selectedItem: "menu",
          onChanged: (value) {
            print("selected value is $value");
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: "search course",
              hintText: "search and select",
              border: OutlineInputBorder(),
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: "search",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
