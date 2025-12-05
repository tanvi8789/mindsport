import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart'; // Import our clean ApiClient

/// AuthService
/// This class handles all authentication-related API calls.
/// It acts as the bridge between your UserProvider and the ApiClient.
class AuthService {
  final ApiClient _apiClient = ApiClient(); // Create an instance of our client
  final _storage = const FlutterSecureStorage();

  // Storage keys
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';
  final String _userIdKey = 'user_id'; // For chat sessions

  /// Registers a new user.
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    // The endpoint is '/auth/register'. The ApiClient will add the base URL.
    final response = await _apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    // If the server's response contains a token and user data, we save them.
    if (response['token'] != null && response['user'] != null) {
      await _storage.write(key: _tokenKey, value: response['token']);

      // Store user data as a string
      await _storage.write(key: _userKey, value: response['user'].toString());

      // Store user ID separately for chat sessions
      if (response['user']['_id'] != null) {
        await _storage.write(key: _userIdKey, value: response['user']['_id']);
      } else if (response['user']['id'] != null) {
        await _storage.write(key: _userIdKey, value: response['user']['id']);
      }

      return {'success': true, 'user': response['user']};
    }

    // Otherwise, report failure and pass along the server's message.
    return {'success': false, 'message': response['message'] ?? 'Registration failed.'};
  }

  /// Logs in an existing user.
  Future<Map<String, dynamic>> login(String email, String password) async {
    // The endpoint is '/auth/login'.
    final response = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    // We check for both 'token' and 'user' from the server
    if (response['token'] != null && response['user'] != null) {
      await _storage.write(key: _tokenKey, value: response['token']);

      // Store user data as a string
      await _storage.write(key: _userKey, value: response['user'].toString());

      // Store user ID separately for chat sessions
      if (response['user']['_id'] != null) {
        await _storage.write(key: _userIdKey, value: response['user']['_id']);
      } else if (response['user']['id'] != null) {
        await _storage.write(key: _userIdKey, value: response['user']['id']);
      }

      // This is the critical fix: We return the user object to the provider
      return {'success': true, 'user': response['user']};
    }

    // Pass on the error message (e.g., "Invalid credentials.")
    return {'success': false, 'message': response['message'] ?? 'Login failed.'};
  }

  /// Fetches the logged-in user's profile data.
  /// This is used when the app starts up to get the user's info.
  Future<Map<String, dynamic>?> getUserData() async {
    // The endpoint is '/auth/me'. ApiClient adds the token header.
    final response = await _apiClient.get('/auth/me');

    // If the response doesn't contain an 'error' key, it was a successful data fetch.
    if (response['error'] == null) {
      // Update stored user ID if present in response
      if (response['_id'] != null) {
        await _storage.write(key: _userIdKey, value: response['_id']);
      } else if (response['id'] != null) {
        await _storage.write(key: _userIdKey, value: response['id']);
      }

      // We return the full user object (which is a Map<String, dynamic>)
      return response;
    }

    // If there was an error (like an expired token), we return null.
    return null;
  }

  /// Updates the user's profile data.
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    // The endpoint is '/auth/me'.
    final response = await _apiClient.put('/auth/me', data);

    // The backend sends back a 'user' object on success. We check for it.
    if (response['user'] != null) {
      // Update stored user data
      await _storage.write(key: _userKey, value: response['user'].toString());
      return true;
    }

    return false;
  }

  // --- Local Storage Methods ---

  /// Deletes the token and user data from storage.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _userIdKey); // Clear user ID for chat sessions
  }

  /// Checks if a token exists in storage.
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  /// Gets the token (if ApiClient needs it for non-standard calls).
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Gets the user ID for chat sessions.
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Gets stored user data as string (for debugging or quick access).
  Future<String?> getStoredUserData() async {
    return await _storage.read(key: _userKey);
  }

  /// Verifies if the current token is valid by making a test API call.
  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.get('/auth/verify');
      return response['error'] == null && response['valid'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Refreshes the authentication token.
  Future<bool> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh', {});

      if (response['token'] != null) {
        await _storage.write(key: _tokenKey, value: response['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Request password reset email.
  Future<bool> requestPasswordReset(String email) async {
    final response = await _apiClient.post('/auth/forgot-password', {
      'email': email,
    });

    return response['success'] == true;
  }

  /// Reset password with token.
  Future<bool> resetPassword(String token, String newPassword) async {
    final response = await _apiClient.post('/auth/reset-password', {
      'token': token,
      'password': newPassword,
    });

    return response['success'] == true;
  }

  /// Clear all authentication data (for testing or debugging).
  Future<void> clearAllAuthData() async {
    await _storage.deleteAll();
  }
}