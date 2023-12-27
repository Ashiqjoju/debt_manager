import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class TabOneContent extends StatefulWidget {
  @override
  _TabOneContentState createState() => _TabOneContentState();
}

class _TabOneContentState extends State<TabOneContent> {
  List<Map<String, dynamic>> entries1 = [];
  List<Map<String, dynamic>> entries2 = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entriesJson1 = prefs.getStringList('entries1') ?? [];
    List<String> entriesJson2 = prefs.getStringList('entries2') ?? [];

    setState(() {
      entries1 = entriesJson1.map((entryJson) {
        return Map<String, dynamic>.from(entryJsonDecode(entryJson));
      }).toList();

      entries2 = entriesJson2.map((entryJson) {
        return Map<String, dynamic>.from(entryJsonDecode(entryJson));
      }).toList();
    });
  }

  void _saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entriesJson1 = entries1.map((entry) {
      return entryJsonEncode(entry);
    }).toList();

    List<String> entriesJson2 = entries2.map((entry) {
      return entryJsonEncode(entry);
    }).toList();

    prefs.setStringList('entries1', entriesJson1);
    prefs.setStringList('entries2', entriesJson2);
  }

  void addEntry(String name, String amount, String date, String description) {
    DateTime currentTime = DateTime.now();
    String currentTimeString = DateFormat('HH:mm:ss').format(currentTime);

    setState(() {
      entries1.add({
        'Name': name,
        'Amount': amount,
        'Date': date,
        'Time': currentTimeString,
        'Action': 'Lent',
        'Description': description,
        'isPaid': false,
      });

      entries2.add({
        'Name': name,
        'Amount': amount,
        'Date': date,
        'Time': currentTimeString,
        'Action': 'Lent',
        'Description': description,
        'isPaid': false,
      });

      _saveEntries();
    });
  }

  double getTotalSum(List<Map<String, dynamic>> entries) {
    return entries
        .map((entry) => double.tryParse(entry['Amount'].toString() ?? '0') ?? 0)
        .fold(0, (sum, amount) => sum + amount);
  }

  void _showDetailsDialog(Map<String, dynamic> entry, int index, List<Map<String, dynamic>> entries) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Details',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', entry['Name'] ?? ''),
              _buildDetailRow('Amount', '₹${entry['Amount'] ?? ''}'),
              _buildDetailRow('Date', entry['Date'] ?? ''),
              _buildDetailRow('Time', entry['Time'] ?? ''),
              _buildDetailRow('Action', entry['Action'] ?? ''),
              _buildDetailRow('Description', entry['Description'] ?? ''),
            ],
          ),
        ),

        actions: [
          _buildDialogAction('Not Paid', Colors.red, () {
            Navigator.of(context).pop();
          }),
          _buildDialogAction('Mark as Paid', Colors.green, () {
            _markAsPaidAndDelete(index, entries);
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogAction(String label, Color textColor, VoidCallback onPressed) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      isDefaultAction: true,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 18.0,
        ),
      ),
    );
  }

  void _markAsPaidAndDelete(int index, List<Map<String, dynamic>> entries) {
    setState(() {
      double amount = double.tryParse(entries[index]['Amount'].toString() ?? '0') ?? 0;
      entries[index]['isPaid'] = true; // Mark the entry as paid
      entries.removeAt(index);
      _saveEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = getTotalSum(entries1) ;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display grand total
          Padding(
            padding: const EdgeInsets.only(top: 70.0), // Only add top padding
            child: Container(
              alignment: Alignment.centerRight, // Align to the right
              padding: const EdgeInsets.only(bottom: 8.0, right: 16.0), // Add bottom and right padding
              decoration: BoxDecoration(
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$grandTotal',
                    style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(
                    'Total Lent',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),




          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              ),
              child: ListView.builder(
                itemCount: entries1.length,
                itemBuilder: (context, index) {
                  final entry = entries1[entries1.length - index - 1];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showDetailsDialog(entry, entries1.length - index - 1, entries1),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.person,
                                color: CupertinoColors.systemGrey,
                                size: 30.0,
                              ),
                              SizedBox(width: 30.0), // Adjust the spacing
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['Name'] ?? '',
                                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '${entry['Date'] ?? ''}',
                                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₹${entry['Amount'] ?? ''}',
                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0, right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900], // Light background color
                  borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius
                ),
                padding: const EdgeInsets.all(8.0), // Optional: Add padding to the container
                child: CupertinoButton(
                  padding: const EdgeInsets.all(5.0),
                  onPressed: () async {
                    await showCupertinoDialog(
                      context: context,
                      builder: (context) => _AddEntryDialog(addEntry),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.add,
                    size: 35.0, // Increase the size of the icon
                    color: Colors.blue, // Optional: Change the icon color
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... rest of the code


class _AddEntryDialog extends StatefulWidget {
  final Function(String, String, String, String) onAddEntry;

  _AddEntryDialog(this.onAddEntry);

  @override
  __AddEntryDialogState createState() => __AddEntryDialogState();
}

class __AddEntryDialogState extends State<_AddEntryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      // Show an error message or handle the validation failure
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Add Entry'),
      content: Column(
        children: [
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Name',
          ),
          CupertinoTextField(
            controller: _amountController,
            placeholder: 'Amount',
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              CupertinoButton(
                onPressed: () => _selectDate(context),
                child: const Text('Select Date'),
              ),
            ],
          ),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Description (Optional)',
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: const Text('Submit'),
          onPressed: () {
            if (_validateForm()) {
              widget.onAddEntry(
                _nameController.text,
                _amountController.text,
                DateFormat('MM/dd/yyyy').format(_selectedDate),
                _descriptionController.text,
              );
              Navigator.of(context).pop();
            } else {
              // Handle the validation failure, show an error message, etc.
              // You can show a SnackBar or a custom error message widget.
              // For simplicity, a print statement is used here.
              print("Please fill in all required fields.");
            }
          },
        ),
      ],
    );
  }
}

String entryJsonEncode(Map<String, dynamic> entry) {
  return jsonEncode(entry);
}

Map<String, dynamic> entryJsonDecode(String entryJson) {
  return jsonDecode(entryJson);
}
