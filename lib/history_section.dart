import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class TabThreeContent extends StatefulWidget {
  @override
  _TabThreeContentState createState() => _TabThreeContentState();
}

class _TabThreeContentState extends State<TabThreeContent> {
  List<Map<String, dynamic>> entries2 = [];
  List<Map<String, dynamic>> entries4 = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entriesJson1 = prefs.getStringList('entries2') ?? [];
    List<String> entriesJson2 = prefs.getStringList('entries4') ?? [];

    setState(() {
      entries2 = entriesJson1.map((entryJson) {
        return Map<String, dynamic>.from(entryJsonDecode(entryJson));
      }).toList();

      entries4 = entriesJson2.map((entryJson) {
        return Map<String, dynamic>.from(entryJsonDecode(entryJson));
      }).toList();
    });
  }

  void _saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entriesJson1 = entries2.map((entry) {
      return entryJsonEncode(entry);
    }).toList();

    List<String> entriesJson2 = entries4.map((entry) {
      return entryJsonEncode(entry);
    }).toList();

    prefs.setStringList('entries2', entriesJson1);
    prefs.setStringList('entries4', entriesJson2);
  }

  void addEntry(String name, String amount, String date, String description) {
    DateTime currentTime = DateTime.now();
    String currentTimeString = DateFormat('HH:mm:ss').format(currentTime);

    setState(() {
      entries2.add({
        'Name': name,
        'Amount': amount,
        'Date': date,
        'Time': currentTimeString,
        'Action': 'Lent',
        'Description': description,
        'isPaid': false,
      });

      entries4.add({
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
        content: Column(
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
        actions: [
          _buildDialogAction('Close', CupertinoColors.systemGrey, () {
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
    double grandTotal = getTotalSum(entries2);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              ),
              child: ListView.builder(
                itemCount: entries2.length,
                itemBuilder: (context, index) {
                  final entry = entries2[entries2.length - index - 1];
                  Color amountColor = entry['Action'] == 'Lent' ? Colors.red : Colors.green;

                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showDetailsDialog(entry, entries2.length - index - 1, entries2),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['Name'] ?? '',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Date: ${entry['Date'] ?? ''}',
                                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            '₹${entry['Amount'] ?? ''}',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: amountColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... rest of the code

String entryJsonEncode(Map<String, dynamic> entry) {
  return jsonEncode(entry);
}

Map<String, dynamic> entryJsonDecode(String entryJson) {
  return jsonDecode(entryJson);
}
