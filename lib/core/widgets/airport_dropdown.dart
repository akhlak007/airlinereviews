import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../constants/airport_list.dart';

class AirportDropdown extends StatelessWidget {
  final Airport? selectedAirport;
  final String hintText;
  final Function(Airport?) onChanged;

  const AirportDropdown({
    super.key,
    this.selectedAirport,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Airport>(
      items: AirportList.airports,
      selectedItem: selectedAirport,
      onChanged: onChanged,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search airports...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      itemAsString: (Airport airport) => airport.toString(),
    );
  }
}