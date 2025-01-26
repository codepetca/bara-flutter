class AppError implements Exception {
  final String message;

  // You can use this constructor to pass a message when throwing the error.
  AppError(this.message);

  // Static factory constructors for specific errors
  static AppError authError(String message) => AppError(message);
  static AppError invalidRedirectUrl() => AppError("Invalid redirect URL.");
  static AppError fetchError(String message) => AppError(message);
  static AppError noSupabaseSession() => AppError("No Supabase session found.");
  static AppError unimplemented() => AppError("Feature is unimplemented.");
  static AppError unknown(String message) => AppError(message);
}
