enum AccountType {
  user,
  cabinOwner,
  medicalCabin,
}

extension AccountTypeExtension on AccountType {
  String get title {
    switch (this) {
      case AccountType.user:
        return 'User';

      case AccountType.cabinOwner:
        return 'Cabin Owner';

      case AccountType.medicalCabin:
        return 'Medical Cabin';
    }
  }

  String get description {
    switch (this) {
      case AccountType.user:
        return 'Book workspaces, medical chambers, and manage your professional needs.';

      case AccountType.cabinOwner:
        return 'List your workspaces, manage bookings, and earn passive income.';

      case AccountType.medicalCabin:
        return 'Register as a doctor, manage your medical practice, and offer consultations.';
    }
  }

  String get actionText {
    switch (this) {
      case AccountType.user:
        return 'Get Started';

      case AccountType.cabinOwner:
        return 'List Your Space';

      case AccountType.medicalCabin:
        return 'Join as Medical Cabin Owner';
    }
  }

  String get apiRole {
    switch (this) {
      case AccountType.user:
        return 'user';

      case AccountType.cabinOwner:
        return 'cabinOwner';

      case AccountType.medicalCabin:
        return 'medicalCabin';
    }
  }
}