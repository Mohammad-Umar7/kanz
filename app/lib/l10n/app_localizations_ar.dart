// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonAppName => 'كنز';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonBackendChecking => 'جارٍ التحقق من الاتصال';

  @override
  String get commonBackendOffline => 'غير متصل';

  @override
  String get commonBackendOnline => 'متصل';

  @override
  String get commonBackendUnreachable => 'تعذّر الوصول إلى الخادم';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonCo2eDisclaimer => 'تقدير، تحقّق منه قبل الاستشهاد به.';

  @override
  String commonCo2eKg(String kg) {
    return '$kg كغ مكافئ CO2';
  }

  @override
  String get commonContinue => 'متابعة';

  @override
  String commonDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count يوماً',
      few: 'قبل $count أيام',
      two: 'قبل يومين',
      one: 'قبل يوم',
    );
    return '$_temp0';
  }

  @override
  String get commonDifficultyEasy => 'سهل';

  @override
  String get commonDifficultyHard => 'صعب';

  @override
  String get commonDifficultyMedium => 'متوسط';

  @override
  String commonDistanceKm(String km) {
    return '$km كم';
  }

  @override
  String commonDistanceMeters(String meters) {
    return '$meters م';
  }

  @override
  String get commonDone => 'تم';

  @override
  String get commonErrorAiInvalidOutput =>
      'لم تكن إجابة الذكاء الاصطناعي مفهومة هذه المرة. حاول مرة أخرى.';

  @override
  String get commonErrorAiQuotaExhausted =>
      'نفدت حصة الذكاء الاصطناعي على هذا الخادم حالياً.';

  @override
  String get commonErrorAiTimeout =>
      'استغرق الذكاء الاصطناعي وقتاً طويلاً في الرد. حاول مرة أخرى.';

  @override
  String get commonErrorAiUnavailable =>
      'خدمة الذكاء الاصطناعي مشغولة الآن. حاول بعد لحظات.';

  @override
  String get commonErrorBadRequest => 'في الطلب شيء غير صحيح. حاول مرة أخرى.';

  @override
  String get commonErrorBadResponse =>
      'أرسل الخادم رداً غير متوقع. حاول مرة أخرى.';

  @override
  String get commonErrorCancelled => 'أُلغي.';

  @override
  String get commonErrorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get commonErrorImageInvalid =>
      'لا يستطيع كنز قراءة هذا الملف كصورة. جرّب صورة أخرى.';

  @override
  String get commonErrorImageTooLarge => 'الصورة كبيرة جداً. جرّب صورة أصغر.';

  @override
  String get commonErrorInternal => 'حدث خطأ من جهتنا. حاول مرة أخرى.';

  @override
  String get commonErrorInterrupted =>
      'لم تكتمل هذه الخطوة في المرة السابقة. حاول مرة أخرى.';

  @override
  String get commonErrorNotFound => 'لم يعد كنز يجد هذا.';

  @override
  String get commonErrorOffline =>
      'أنت غير متصل. تحقّق من الاتصال وحاول مجدداً.';

  @override
  String get commonErrorPlacesUnavailable =>
      'تعذّر تحميل نقاط التسليم الآن. حاول بعد قليل.';

  @override
  String get commonErrorRateLimited =>
      'طلبات كثيرة في وقت واحد. انتظر قليلاً ثم حاول مجدداً.';

  @override
  String get commonErrorTimeout =>
      'يستغرق هذا وقتاً طويلاً. تحقّق من الاتصال وحاول مجدداً.';

  @override
  String commonHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      few: 'قبل $count ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get commonJustNow => 'الآن';

  @override
  String get commonLanguageArabic => 'العربية';

  @override
  String get commonLanguageEnglish => 'English';

  @override
  String get commonLanguageSystem => 'لغة الهاتف';

  @override
  String get commonLevelHigh => 'مرتفع';

  @override
  String get commonLevelLow => 'منخفض';

  @override
  String get commonLevelMedium => 'متوسط';

  @override
  String get commonLoading => 'جارٍ التحميل';

  @override
  String commonMinutes(int count) {
    return '$count د';
  }

  @override
  String commonMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count دقيقة',
      few: 'قبل $count دقائق',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get commonNext => 'التالي';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonOpenSettings => 'فتح الإعدادات';

  @override
  String get commonPhotoBlurry => 'الصورة غير واضحة';

  @override
  String get commonPhotoCluttered => 'أشياء كثيرة في الصورة';

  @override
  String get commonPhotoGlare => 'اللمعان يخفي الغرض';

  @override
  String get commonPhotoNoItems => 'لم يُعثر على أغراض في الصورة';

  @override
  String get commonPhotoTooClose => 'الغرض قريب جداً';

  @override
  String get commonPhotoTooDark => 'الصورة مظلمة جداً';

  @override
  String get commonPhotoTooFar => 'الغرض بعيد جداً';

  @override
  String get commonRecyclableConditional => 'قابل لإعادة التدوير بعد التجهيز';

  @override
  String get commonRecyclableNo => 'غير قابل لإعادة التدوير';

  @override
  String get commonRecyclableYes => 'قابل لإعادة التدوير';

  @override
  String get commonRegenerate => 'جرّب صورة أخرى';

  @override
  String get commonRetry => 'حاول مجدداً';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonSkillAdvanced => 'متقدّم';

  @override
  String get commonSkillBeginner => 'مبتدئ';

  @override
  String get commonSkillIntermediate => 'متوسط';

  @override
  String get commonSkip => 'تخطٍّ';

  @override
  String get commonSpeechCareful => 'انتبه';

  @override
  String get commonSpeechTip => 'نصيحة';

  @override
  String get commonStageDropoff => 'البحث عن نقاط التسليم';

  @override
  String get commonStageIdeas => 'فحص السلامة وإيجاد الأفكار';

  @override
  String get commonStageIdentifying => 'التعرّف على المواد';

  @override
  String get commonStageMakeovers => 'رسم الشكل الجديد';

  @override
  String commonStepNumber(int number) {
    return 'الخطوة $number';
  }

  @override
  String commonStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get commonThemeDark => 'داكن';

  @override
  String get commonThemeLight => 'فاتح';

  @override
  String get commonThemeSystem => 'مثل الهاتف';

  @override
  String commonWeightKg(String kg) {
    return '$kg كغ';
  }

  @override
  String get commonYesterday => 'أمس';
}
