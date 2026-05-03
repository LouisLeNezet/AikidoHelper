import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/rating_emoticon.dart';
import 'package:aikido_helper/functions/utils.dart';
import 'package:aikido_helper/functions/learn_json.dart';

class LearnMenuScreen extends StatefulWidget {
  final String fileName;

  const LearnMenuScreen({
    required this.fileName,
    super.key
  });

  @override
  State<LearnMenuScreen> createState() => _LearnMenuScreenState();
}


class _LearnMenuScreenState extends State<LearnMenuScreen> {
  late Future<Map<String, dynamic>> _learnData;
  String _searchQuery = '';
  String _sortField = 'grade';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _learnData = getJsonData(fileName: widget.fileName);
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending; // Toggle order if same field
      } else {
        _sortField = field;
        _ascending = true; // Default to ascending on new field
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _learnData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading exam: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }
          var learnList = List<Map<String, dynamic>>.from(snapshot.data!.values);

          if (_searchQuery.isNotEmpty) {
            final queryWords = _searchQuery
                .toLowerCase()
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .toList();

            learnList = learnList.where((technique) {
              final text = [
                technique['waza'],
                technique['attack'],
                technique['technique'],
                technique['form'],
              ].where((e) => e != null).join(' ').toLowerCase();

              return queryWords.every((word) => text.contains(word));
            }).toList();
          }

          learnList.sort((a, b) => compareTechniques(a, b, _sortField, _ascending));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search techniques',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    const Text('Order by:'),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: _setSort,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'rating', child: Text('Rating')),
                        const PopupMenuItem(value: 'grade', child: Text('Grade')),
                        const PopupMenuItem(value: 'waza', child: Text('Waza')),
                        const PopupMenuItem(value: 'attack', child: Text('Attack')),
                        const PopupMenuItem(value: 'technique', child: Text('Technique')),
                      ],
                      child: Row(
                        children: [
                          Text(_sortField[0].toUpperCase() + _sortField.substring(1)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _ascending = !_ascending;
                              });
                            },
                            child: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text('Techniques:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...learnList.map((technique) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('${technique['waza']} - ${technique['attack']} - ${technique['technique']}'),
                        subtitle: Text(
                          '${(technique['form'] ?? '').toString().isNotEmpty ? 'Form: ${technique['form']} | ' : ''}'
                          'Grade: ${technique['techniqueGrade']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RatingEmoticon(
                              rating: (technique['progression'].isNotEmpty
                                ? (technique['progression'].last['rating'] as num?)?.toInt() ?? 0
                                : 0),
                              showValue: false,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/learn/technique-detail',
                            arguments: technique,
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
