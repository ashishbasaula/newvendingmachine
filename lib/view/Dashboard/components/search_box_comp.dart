import 'package:flutter/material.dart';

class SearchBoxComponet extends StatelessWidget {
  const SearchBoxComponet({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.black12, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          children: [Icon(Icons.search), Text("Search store..")],
        ),
      ),
    );
  }
}
