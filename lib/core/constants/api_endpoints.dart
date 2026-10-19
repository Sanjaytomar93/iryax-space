class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://spaceapi.iryax.com';

  // ============================================================
  // AUTH
  // ============================================================

  static const String login =
      '$baseUrl/api/auth/login';

  static const String register =
      '$baseUrl/api/auth/register';

  // ============================================================
  // SPACES
  // ============================================================

  static const String cabins =
      '$baseUrl/api/cabins';

  static String cabinDetails(
      String cabinId,
      ) {
    return '$baseUrl/api/cabins/$cabinId';
  }

  static String cabinBookedSlots(
      String cabinId,
      ) {
    return '$baseUrl/api/bookings/cabin/$cabinId';
  }

  // ============================================================
  // BOOKING
  // ============================================================

  static String createBooking(
      String userId,
      ) {
    return '$baseUrl/api/bookings/createbooking/$userId';
  }

  static String createVisit(
      String userId,
      ) {
    return '$baseUrl/api/bookings/createvisit/$userId';
  }

  static const String userBookings =
      '$baseUrl/api/bookings/user';

  static const String userVisits =
      '$baseUrl/api/bookings/user/visits';

  static String cancelBooking(
      String bookingId,
      ) {
    return '$baseUrl/api/bookings/cancel-booking/$bookingId';
  }

  static const String userDashboard =
      '$baseUrl/api/bookings/user/dashboard';

  // ============================================================
  // WISHLIST
  // ============================================================

  static String toggleWishlist(
      String userId,
      ) {
    return '$baseUrl/api/cabins/toggle/$userId';
  }

  static String myWishlist(
      String userId,
      ) {
    return '$baseUrl/api/cabins/mywishlist/$userId';
  }

  static String deleteWishlist(
      String userId,
      String cabinId,
      ) {
    return '$baseUrl/api/cabins/$userId/$cabinId';
  }

  // ============================================================
  // PROFILE
  // ============================================================

  static String profile(
      String userId,
      ) {
    return '$baseUrl/api/auth/profile/$userId';
  }
}