import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository] using Firebase Authentication
/// and Firestore.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final userDoc = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User data not found in Firestore.');
      }

      return UserModel.fromJson({
        'id': credential.user!.uid,
        ...userDoc.data()!,
      });
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'Sign in failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a new UserModel
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(
          darkMode: false,
          units: 'metric',
          dailyCalorieGoal: 2000,
          dailyProteinGoal: 150,
          workoutReminders: [],
        ),
        stats: const UserStats(
          totalWorkouts: 0,
          currentStreak: 0,
          longestStreak: 0,
          totalWeightLifted: 0,
          totalCaloriesLogged: 0,
        ),
      );

      // Save user data to Firestore
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(user.id)
          .set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else {
        message = 'Sign up failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final userDoc = await _firestore
          .collection(AppConfig.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        return null;
      }

      return UserModel.fromJson({
        'id': currentUser.uid,
        ...userDoc.data()!,
      });
    } catch (e) {
      // Log the error for debugging, but return null for unauthenticated state
      print('Error getting current user: $e');
      return null;
    }
  }
}
