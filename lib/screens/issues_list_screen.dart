import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'full_screen_image_view.dart';

class IssuesListScreen extends StatefulWidget {
  const IssuesListScreen({super.key});

  @override
  State<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends State<IssuesListScreen> {
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reported Issues')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No issues reported yet.'));
          }

          final issues = snapshot.data!.docs;

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index].data() as Map<String, dynamic>;

              final imageUrl = issue['imageUrl'] ?? '';
              final title = issue['title'] ?? 'No Title';
              final address = issue['location']?['address'] ?? 'No address';
              final status = issue['status'] ?? 'Pending';
              final timestamp = issue['timestamp'];
              final upvotedBy = issue['upvotedBy'] ?? [];
              final currentUser = FirebaseAuth.instance.currentUser;
              final hasUpvoted = currentUser != null && upvotedBy.contains(currentUser.uid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (imageUrl.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FullScreenImageView(imageUrl: imageUrl),
                                  ),
                                );
                              }
                            },
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl,
                                    width: 60, height: 60, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported, size: 60),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(title,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('📍 Address: $address'),
                      if (issue['location']?['lat'] != null &&
                          issue['location']?['long'] != null)
                        Text(
                            '🌐 Coordinates: ${issue['location']['lat']}, ${issue['location']['long']}'),
                      Text('🕒 ${_formatTimestamp(timestamp)}'),
                      Text('📌 Status: $status'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: hasUpvoted ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () async {
                              if (currentUser == null) return;

                              final docId = issues[index].id;
                              final docRef = FirebaseFirestore.instance
                                  .collection('issues')
                                  .doc(docId);
                              final messenger = ScaffoldMessenger.of(context);

                              try {
                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  final snapshot =
                                      await transaction.get(docRef);
                                  if (!snapshot.exists) return;

                                  final currentUpvotes =
                                      snapshot.get('upvotes') ?? 0;
                                  final List<dynamic> currentUpvotedBy =
                                      snapshot.get('upvotedBy') ?? [];

                                  if (currentUpvotedBy
                                      .contains(currentUser.uid)) {
                                    messenger.showSnackBar(const SnackBar(
                                        content: Text(
                                            'You have already upvoted this issue.')));
                                    return;
                                  }

                                  transaction.update(docRef, {
                                    'upvotes': currentUpvotes + 1,
                                    'upvotedBy': FieldValue.arrayUnion(
                                        [currentUser.uid]),
                                  });
                                });
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(
                                    content: Text('Failed to upvote: $e')));
                              }
                            },
                          ),
                          Text(
                            '${issue['upvotes'] ?? 0}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  hasUpvoted ? Colors.blue : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
