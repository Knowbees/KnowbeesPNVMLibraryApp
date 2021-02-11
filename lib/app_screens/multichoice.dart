import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MultiSelectChip extends StatefulWidget {
  List<String> reportList;
  Function(String) onSelectionChanged;


  MultiSelectChip(this.reportList, {this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}
class _MultiSelectChipState extends State<MultiSelectChip> {
  String selectedChoice = "";
  bool isSelected = true ;

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.reportList.forEach((item) {
      choices.add(
          Container(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: <Widget>[
                Container(
                    child: ChoiceChip(
                      label: Text(item),
                      selectedColor: Colors.blueAccent,
                      selected: selectedChoice == item ,
                      onSelected: ( selectedItem) {
                        setState(() {
                          isSelected = selectedItem;
                          selectedChoice = item  ;
                          widget.onSelectionChanged(selectedChoice);
                        });
                      },
                    ),
                  ),

                ],
              )
          ));
    });


    return choices;
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

