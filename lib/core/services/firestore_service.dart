import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/idea_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
  }

  // --- Ideas (Startups/Investors) ---
  Future<void> publishIdea(IdeaModel idea) async {
    await _db.collection('ideas').add(idea.toMap());
  }

  Stream<List<IdeaModel>> streamPublishedIdeas() {
    return _db
        .collection('ideas')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<IdeaModel>> streamFundedIdeas() {
    return _db
        .collection('ideas')
        .where('status', isEqualTo: 'funded')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> allocateFunds(String ideaId, double amount) async {
    await _db.collection('ideas').doc(ideaId).update({
      'allocatedFunds': FieldValue.increment(amount),
      'status': 'funded' // Move status to funded once they receive money
    });
  }
}
