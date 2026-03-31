class DemoSession {
  static String? currentUid;
  static String? currentEmail;
  static String? currentRole;
  
  static void setSession(String uid, String email, String role) {
    currentUid = uid;
    currentEmail = email;
    currentRole = role;
  }

  static void clear() {
    currentUid = null;
    currentEmail = null;
    currentRole = null;
  }
}
