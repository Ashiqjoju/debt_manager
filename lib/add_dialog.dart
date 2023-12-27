import 'package:flutter/material.dart';

class AddDialog extends StatelessWidget {
  final String title;

  AddDialog(this.title);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Enter name'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
