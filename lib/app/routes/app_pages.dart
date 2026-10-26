import 'package:get/get.dart';
import 'package:iryax_spaces/modules/navigation/bindings/navigation_binding.dart';
import 'package:iryax_spaces/modules/navigation/view/main_navigation_view.dart';
import 'package:iryax_spaces/modules/notifications/bindings/notification_binding.dart';
import 'package:iryax_spaces/modules/notifications/view/notifications_view.dart';
import 'package:iryax_spaces/modules/profile/bindings/profile_binding.dart';
import 'package:iryax_spaces/modules/profile/view/profile_view.dart';
import 'package:iryax_spaces/modules/spaces/view/book_space_view.dart';
import 'package:iryax_spaces/modules/spaces/view/site_visit_view.dart';
import 'package:iryax_spaces/modules/spaces/view/space_details_view.dart';
import 'package:iryax_spaces/modules/splash/bindings/splash_binding.dart';
import 'package:iryax_spaces/modules/splash/view/splash_view.dart';
import 'package:iryax_spaces/modules/wishlist/view/wishlist_view.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/view/account_type_view.dart';
import '../../modules/auth/view/forgot_password_view.dart';
import '../../modules/auth/view/login_view.dart';
import '../../modules/auth/view/registration_view.dart';
import '../../modules/auth/view/reset_password_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.accountType,
      page: () => const AccountTypeView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => const MainNavigationView(),
      binding: NavigationBinding(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.spaceDetails,
      page: () => const SpaceDetailsView(),
    ),

    GetPage(
      name: AppRoutes.bookSpace,
      page: () => const BookSpaceView(),
    ),

    GetPage(
      name: AppRoutes.siteVisit,
      page: () => const SiteVisitView(),
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationBinding(),
    ),

    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
    ),

  ];
}