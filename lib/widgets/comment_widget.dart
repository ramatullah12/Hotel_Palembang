import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommentWidget extends StatefulWidget {
  final String hotelId;

  const CommentWidget({super.key, required this.hotelId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentCtrl = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isSubmitting = false;
  int _selectedRating = 0;
  String? _replyingToName;
  String? _replyingToId;
  String? _editingCommentId;
  Set<String> _expandedComments = {};

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _user == null) return;
    
    if (_selectedRating == 0 && _replyingToName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rating bintang terlebih dahulu!')));
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String authorName = "User";
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        authorName = userDoc.data()?['name'] ?? "User";
      }

      final finalTextInput = _replyingToName != null ? '@$_replyingToName $text' : text;

      final commentRef = FirebaseFirestore.instance
          .collection('hotels')
          .doc(widget.hotelId)
          .collection('comments');

      if (_editingCommentId != null) {
        await commentRef.doc(_editingCommentId).update({
          'text': text,
          if (_selectedRating > 0) 'rating': _selectedRating,
          'isEdited': true,
        });
      } else {
        await commentRef.add({
          'uid': _user!.uid,
          'authorName': authorName,
          'text': finalTextInput,
          'timestamp': FieldValue.serverTimestamp(),
          if (_selectedRating > 0) 'rating': _selectedRating,
          if (_replyingToId != null) 'replyToId': _replyingToId,
        });
      }

      _commentCtrl.clear();
      setState(() {
        _replyingToName = null;
        _replyingToId = null;
        _editingCommentId = null;
        _selectedRating = 0;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komentar?'),
        content: const Text('Komentar yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(widget.hotelId)
            .collection('comments')
            .doc(commentId)
            .delete();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Widget _buildCommentItem(BuildContext context, DocumentSnapshot doc, {bool isReply = false, required String rootId}) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isMyComment = data['uid'] == _user?.uid;
    
    DateTime? date;
    if (data['timestamp'] != null) date = (data['timestamp'] as Timestamp).toDate();
    String timeAgo = '';
    if (date != null) timeAgo = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Container(
      margin: isReply ? const EdgeInsets.only(top: 12, left: 12) : EdgeInsets.zero,
      padding: isReply ? const EdgeInsets.only(left: 12) : EdgeInsets.zero,
      decoration: isReply 
        ? BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.3), width: 2)))
        : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  (data['authorName'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(data['authorName'] ?? 'User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isReply ? 13 : 14)),
                        if (isMyComment)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Anda', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(timeAgo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              if (!isReply && data['rating'] != null)
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < (data['rating'] as num).toInt() ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['text'] ?? '',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: isReply ? 13 : 14, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (data['isEdited'] == true) ...[
                const Text('(Diedit)', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                const Spacer(),
              ],
              if (data['isEdited'] != true) const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _replyingToName = data['authorName'];
                    _replyingToId = rootId; // Tempelkan balasan ke thread utama
                    _editingCommentId = null;
                    FocusScope.of(context).unfocus();
                  });
                },
                child: const Text('Balas', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              if (isMyComment) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingCommentId = doc.id;
                      _commentCtrl.text = data['text'] ?? '';
                      _selectedRating = data['rating'] ?? 0;
                      _replyingToName = null;
                      _replyingToId = null;
                    });
                  },
                  child: const Text('Edit', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _deleteComment(doc.id),
                  child: const Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  Stream<QuerySnapshot>? _commentsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }
  
  void _initStream() {
    _commentsStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotelId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _commentsStream ??= FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotelId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Gagal memuat komentar.'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        
        final List<DocumentSnapshot> rootComments = [];
        final Map<String, List<DocumentSnapshot>> repliesMap = {};
        bool hasReviewed = false;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final replyToId = data['replyToId'] as String?;
          if (replyToId == null) {
            rootComments.add(doc);
            if (data['uid'] == _user?.uid) {
              hasReviewed = true;
            }
          } else {
            if (!repliesMap.containsKey(replyToId)) repliesMap[replyToId] = [];
            repliesMap[replyToId]!.add(doc);
          }
        }

        for (var list in repliesMap.values) {
          list.sort((a, b) {
            final tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tA.compareTo(tB);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Text(
                "Ulasan Pengunjung",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            
            if (rootComments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Belum ada komentar. Jadilah yang pertama!', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rootComments.length,
                itemBuilder: (context, index) {
                  final rootDoc = rootComments[index];
                  final replies = repliesMap[rootDoc.id] ?? [];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommentItem(context, rootDoc, isReply: false, rootId: rootDoc.id),
                        
                        if (replies.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_expandedComments.contains(rootDoc.id)) {
                                  _expandedComments.remove(rootDoc.id);
                                } else {
                                  _expandedComments.add(rootDoc.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _expandedComments.contains(rootDoc.id) 
                                        ? 'Sembunyikan balasan' 
                                        : 'Lihat ${replies.length} balasan',
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          ),
                          
                          if (_expandedComments.contains(rootDoc.id))
                            ...replies.map((replyDoc) => _buildCommentItem(context, replyDoc, isReply: true, rootId: rootDoc.id)),
                        ]
                      ],
                    ),
                  );
                },
              ),

            // Input Komentar Box / Status Review
            if (_user != null)
              if (!hasReviewed || _replyingToId != null || _editingCommentId != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_replyingToId != null || _editingCommentId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(_editingCommentId != null ? Icons.edit : Icons.reply, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _editingCommentId != null 
                                      ? 'Mengedit ulasan Anda' 
                                      : 'Membalas ${_replyingToName ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _replyingToName = null;
                                    _replyingToId = null;
                                    _editingCommentId = null;
                                    _commentCtrl.clear();
                                    _selectedRating = 0;
                                  });
                                },
                                child: const Icon(Icons.close, size: 18, color: Colors.grey),
                              )
                            ],
                          ),
                        ),

                      if (_replyingToId == null) // Jangan tampilkan rating jika sedang reply
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              const Text("Rating Anda: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRating = index + 1;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: Icon(
                                        index < _selectedRating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                filled: true,
                                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: _isSubmitting 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send, color: Colors.white),
                              onPressed: _isSubmitting ? null : _postComment,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Anda telah memberikan ulasan untuk properti ini. Gunakan fitur Balas atau Edit pada ulasan.",
                          style: TextStyle(color: Colors.blue, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
