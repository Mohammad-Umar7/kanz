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
      'تعذّر الوصول إلى كنز. تحقّق من الاتصال وحاول مجدداً.';

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

  @override
  String get completionAfter => 'بعد';

  @override
  String get completionBefore => 'قبل';

  @override
  String completionCardMadeFrom(String item) {
    return 'مصنوع من $item';
  }

  @override
  String get completionCompare => 'قارن غرضك قبل التحويل وبعده';

  @override
  String get completionDescribedLabel => 'وصفك';

  @override
  String get completionErrorTitle => 'تعذّر تحميل المشروع';

  @override
  String get completionEyebrow => 'اكتمل المشروع';

  @override
  String get completionEyebrowInProgress => 'قيد التنفيذ';

  @override
  String completionFinishedOn(String date) {
    return 'اكتمل $date';
  }

  @override
  String get completionImpactTitle => 'ما الذي تغيّر';

  @override
  String get completionItems => 'أغراض أنقذتها من النفايات';

  @override
  String get completionLoading => 'نحمّل مشروعك';

  @override
  String get completionMadeFrom => 'مصنوع من';

  @override
  String get completionMissingBody =>
      'ربما حُذف مع المسح الخاص به. تجد مشاريعك الأخرى في السجل.';

  @override
  String get completionMissingTitle => 'هذا المشروع غير موجود على هاتفك';

  @override
  String get completionNoPhoto =>
      'وصفتَ هذا الغرض بالكلمات، فلا توجد صورة للمقارنة.';

  @override
  String get completionPhotoOnly =>
      'صورة التحويل غير متاحة على هذا الخادم، لذا تظهر هنا صورتك الأصلية.';

  @override
  String get completionProjects => 'مشاريع مكتملة';

  @override
  String get completionScanAgain => 'صوّر غرضاً آخر';

  @override
  String get completionSeeProjects => 'اعرض مشاريعي';

  @override
  String get completionShare => 'شارك صورة قبل وبعد';

  @override
  String get completionShareFallback =>
      'تعذّر تجهيز الصورة، فشاركنا النص وحده.';

  @override
  String get completionShareProject => 'شارك هذا المشروع';

  @override
  String completionShareText(String title) {
    return '$title، صنعته من شيء كدت أرميه. خطّطت له مع كنز.';
  }

  @override
  String get completionSharing => 'نجهّز الصورة';

  @override
  String get completionSkill => 'المهارة';

  @override
  String get completionSteps => 'الخطوات';

  @override
  String completionStepsValue(int done, int total) {
    return '$done من $total';
  }

  @override
  String get completionStreak => 'أيام متتالية';

  @override
  String completionThisProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أنقذ هذا المشروع $count غرض من النفايات.',
      many: 'أنقذ هذا المشروع $count غرضاً من النفايات.',
      few: 'أنقذ هذا المشروع $count أغراض من النفايات.',
      two: 'أنقذ هذا المشروع غرضين من النفايات.',
      one: 'أنقذ هذا المشروع غرضاً واحداً من النفايات.',
      zero: 'أُضيف هذا المشروع إلى مشاريعك المكتملة.',
    );
    return '$_temp0';
  }

  @override
  String get completionTime => 'الوقت';

  @override
  String get dropoffAcceptedUnknown =>
      'المواد المقبولة غير مذكورة. تحقّق من ملصقات الحاوية قبل الذهاب.';

  @override
  String dropoffAcceptsList(String materials) {
    return 'يستقبل: $materials';
  }

  @override
  String dropoffApproximate(String city) {
    return 'موقعك غير دقيق، لذلك يبحث كنز حول $city.';
  }

  @override
  String get dropoffCall => 'اتصال';

  @override
  String get dropoffCatalogError => 'تعذّر تحميل عوامل التصفية.';

  @override
  String get dropoffCategoriesLabel => 'المواد التي تريد تسليمها';

  @override
  String get dropoffChangeLocation => 'تغيير';

  @override
  String get dropoffChangeLocationHint => 'تغيير مكان البحث';

  @override
  String get dropoffCities => 'المدن';

  @override
  String get dropoffClosed => 'مغلق الآن';

  @override
  String get dropoffDetailAccepts => 'يستقبل';

  @override
  String get dropoffDetailAddress => 'العنوان';

  @override
  String get dropoffDetailDistance => 'المسافة';

  @override
  String get dropoffDetailHours => 'ساعات العمل';

  @override
  String get dropoffDetailSource => 'المصدر';

  @override
  String dropoffDirectionOfPlace(String direction, String place) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'n': 'إلى الشمال من وسط $place',
      'ne': 'إلى الشمال الشرقي من وسط $place',
      'e': 'إلى الشرق من وسط $place',
      'se': 'إلى الجنوب الشرقي من وسط $place',
      's': 'إلى الجنوب من وسط $place',
      'sw': 'إلى الجنوب الغربي من وسط $place',
      'w': 'إلى الغرب من وسط $place',
      'nw': 'إلى الشمال الغربي من وسط $place',
      'other': 'بالقرب من وسط $place',
    });
    return '$_temp0';
  }

  @override
  String dropoffDirectionOfYou(String direction) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'n': 'إلى الشمال منك',
      'ne': 'إلى الشمال الشرقي منك',
      'e': 'إلى الشرق منك',
      'se': 'إلى الجنوب الشرقي منك',
      's': 'إلى الجنوب منك',
      'sw': 'إلى الجنوب الغربي منك',
      'w': 'إلى الغرب منك',
      'nw': 'إلى الشمال الغربي منك',
      'other': 'بالقرب منك',
    });
    return '$_temp0';
  }

  @override
  String get dropoffDirections => 'الاتجاهات';

  @override
  String dropoffDirectionsTo(String name) {
    return 'الاتجاهات إلى $name';
  }

  @override
  String get dropoffEmptyAction => 'اختر مدينة أخرى';

  @override
  String dropoffEmptyMessage(String place) {
    return 'لا توجد نقاط تسليم لهذه المواد بالقرب من $place. جرّب مدينة أخرى، أو أضف مادة من الأعلى.';
  }

  @override
  String dropoffEmptyTitle(int km) {
    return 'لا شيء ضمن $km كم';
  }

  @override
  String get dropoffErrorTitle => 'تعذّر تحميل نقاط التسليم';

  @override
  String get dropoffHoursUnknown => 'ساعات العمل غير مذكورة';

  @override
  String get dropoffLocating => 'تحديد مكان البحث';

  @override
  String get dropoffLocationAllow => 'استخدم موقعي';

  @override
  String get dropoffLocationBlockedCity =>
      'أو اختر مدينة، وسيبحث كنز حول وسطها.';

  @override
  String get dropoffLocationBlockedReason =>
      'فعّله من إعدادات هاتفك لترتيب الأماكن حسب بُعدها عنك.';

  @override
  String get dropoffLocationBlockedSnack =>
      'الموقع غير مفعّل لكنز. فعّله من إعدادات هاتفك.';

  @override
  String get dropoffLocationBlockedTitle => 'الموقع غير مفعّل لكنز';

  @override
  String get dropoffLocationDenied =>
      'لم يُسمح بالوصول إلى الموقع. يمكنك اختيار مدينة بدلًا من ذلك.';

  @override
  String get dropoffLocationFootnote =>
      'يمكنك تغيير ذلك في أي وقت من أعلى هذه الصفحة.';

  @override
  String get dropoffLocationPickCity => 'اختر مدينة';

  @override
  String get dropoffLocationReasonCity =>
      'لا تريد مشاركة موقعك؟ اختر مدينتك بدلًا من ذلك.';

  @override
  String get dropoffLocationReasonDistance => 'تُرتَّب الأماكن حسب بُعدها عنك.';

  @override
  String get dropoffLocationReasonHazard =>
      'تذهب البطاريات والأجهزة الإلكترونية إلى أماكن تستقبلها.';

  @override
  String dropoffLocationSheetSubtitle(int km) {
    return 'يعرض كنز نقاط التسليم ضمن $km كم.';
  }

  @override
  String get dropoffLocationSheetTitle => 'ابحث بالقرب من';

  @override
  String get dropoffLocationTitle => 'اعثر على نقاط التسليم القريبة منك';

  @override
  String dropoffNearCity(String city) {
    return 'بالقرب من $city';
  }

  @override
  String get dropoffNearYou => 'بالقرب منك';

  @override
  String get dropoffNoCategoryMessage =>
      'اختر مادة واحدة على الأقل من الأعلى لترى نقاط التسليم القريبة منك.';

  @override
  String get dropoffNoCategoryTitle => 'اختر مادة';

  @override
  String get dropoffOfflineTitle => 'أنت غير متصل';

  @override
  String get dropoffOpenFailed => 'تعذّر فتح الرابط. حاول مرة أخرى.';

  @override
  String get dropoffOpenNow => 'مفتوح الآن';

  @override
  String dropoffPlaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكان',
      many: '$count مكانًا',
      few: '$count أماكن',
      two: 'مكانان',
      one: 'مكان واحد',
      zero: 'لا أماكن',
    );
    return '$_temp0';
  }

  @override
  String dropoffPlotCentreOf(String city) {
    return 'وسط $city';
  }

  @override
  String dropoffPlotLabel(int count, String place, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة تسليم حول $place، أقربها على بُعد $distance.',
      many: '$count نقطة تسليم حول $place، أقربها على بُعد $distance.',
      few: '$count نقاط تسليم حول $place، أقربها على بُعد $distance.',
      two: 'نقطتا تسليم حول $place، أقربهما على بُعد $distance.',
      one: 'نقطة تسليم واحدة حول $place، على بُعد $distance.',
    );
    return '$_temp0';
  }

  @override
  String get dropoffPlotNorth => 'ش';

  @override
  String dropoffPlotRings(String distance) {
    return 'المسافة بين الحلقات $distance';
  }

  @override
  String get dropoffPlotYou => 'موقعك';

  @override
  String get dropoffSearching => 'البحث عن نقاط التسليم';

  @override
  String dropoffSearchingNear(String place) {
    return 'البحث بالقرب من $place';
  }

  @override
  String get dropoffSearchingNearYou => 'البحث بالقرب منك';

  @override
  String get dropoffSourceCurated => 'قائمة كنز، راجعها الفريق';

  @override
  String get dropoffSourceGoogle => 'Google Maps';

  @override
  String get dropoffSourceOsm => '© مساهمو OpenStreetMap';

  @override
  String get dropoffSourcesLabel => 'المصادر';

  @override
  String get dropoffTitle => 'نقاط التسليم';

  @override
  String get dropoffTypeAll => 'كل الأنواع';

  @override
  String dropoffTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نوع',
      many: '$count نوعًا',
      few: '$count أنواع',
      two: 'نوعان',
      one: 'نوع واحد',
    );
    return '$_temp0';
  }

  @override
  String get dropoffTypeEmptyMessage =>
      'وُجدت أماكن قريبة، لكن لا يطابق أيٌّ منها النوع الذي اخترته.';

  @override
  String get dropoffTypeEmptyTitle => 'لا أماكن من هذا النوع';

  @override
  String get dropoffTypeFilterHint => 'التصفية حسب نوع المكان';

  @override
  String get dropoffTypeSheetSubtitle =>
      'اعرض فقط أنواع الأماكن التي تريد زيارتها.';

  @override
  String get dropoffTypeSheetTitle => 'نوع المكان';

  @override
  String get dropoffTypeShowAll => 'عرض كل الأنواع';

  @override
  String get dropoffUseMyLocation => 'استخدم موقعي';

  @override
  String get dropoffUseMyLocationDetail => 'ترتيب الأماكن حسب بُعدها عنك';

  @override
  String get dropoffViewList => 'قائمة';

  @override
  String get dropoffViewMap => 'خريطة';

  @override
  String get dropoffWebsite => 'الموقع الإلكتروني';

  @override
  String dropoffWithinKm(int km) {
    return 'ضمن $km كم';
  }

  @override
  String get historyDelete => 'احذف الفحص';

  @override
  String get historyDeleteBody =>
      'ستُحذف صورته وأفكاره ومشاريعه من هذا الهاتف، وتبقى أرقام أثرك كما هي.';

  @override
  String get historyDeleteConfirm => 'احذف';

  @override
  String get historyDeleteFailed => 'تعذّر حذف الفحص. حاول مرة أخرى.';

  @override
  String get historyDeleteTitle => 'أتريد حذف هذا الفحص؟';

  @override
  String get historyDeleted => 'حُذف الفحص';

  @override
  String get historyErrorBody =>
      'تعذّر على كنز قراءة ما حُفظ على هذا الهاتف. حاول مرة أخرى.';

  @override
  String get historyErrorTitle => 'لم يُحمَّل السجل';

  @override
  String get historyFinished => 'مكتملة';

  @override
  String historyFinishedOn(String date) {
    return 'اكتمل في $date';
  }

  @override
  String get historyInProgress => 'قيد التنفيذ';

  @override
  String get historyLoading => 'جارٍ تحميل السجل';

  @override
  String historyMore(String title) {
    return 'خيارات أخرى لـ$title';
  }

  @override
  String get historyNotStarted => 'لم تفتح الدرس بعد';

  @override
  String get historyOpenScan => 'افتح الفحص';

  @override
  String get historyProjectsEmptyBody =>
      'اختر فكرة لإعادة الابتكار من أحد فحوصك وابدأ درسها، وسيُحفظ تقدّمك هنا.';

  @override
  String get historyProjectsEmptyTitle => 'لا مشاريع بعد';

  @override
  String get historyResume => 'تابِع';

  @override
  String get historyScansEmptyBody =>
      'يُحفظ هنا كل غرض تفحصه، ويُفتح حتى دون اتصال.';

  @override
  String get historyScansEmptyTitle => 'لا فحوص بعد';

  @override
  String get historySeeProject => 'اعرض المشروع';

  @override
  String historyStepsDone(int done, int total) {
    return '$done من $total خطوات منجزة';
  }

  @override
  String get historyTabProjects => 'مشاريعي';

  @override
  String get historyTabScans => 'الفحوص';

  @override
  String get historyTitle => 'السجل';

  @override
  String get historyToday => 'اليوم';

  @override
  String get homeDescribe => 'صِفه بالكلمات';

  @override
  String get homeDescription => 'وصف';

  @override
  String get homeErrorMessage =>
      'تعذّر على كنز قراءة الفحوص المحفوظة على هذا الهاتف. حاول مرة أخرى.';

  @override
  String get homeErrorTitle => 'لم تُحمَّل فحوصك';

  @override
  String get homeGallery => 'من المعرض';

  @override
  String get homeGuideEyebrow => 'ماذا تصوّر';

  @override
  String get homeGuideGlass => 'البرطمانات والقوارير';

  @override
  String get homeGuideHazardous =>
      'البطاريات والهواتف القديمة، ويدلّك كنز على مكان تسليمها بأمان.';

  @override
  String get homeGuideMetal => 'العلب المعدنية وعلب المشروبات';

  @override
  String get homeGuidePaper => 'علب الكرتون والصحف';

  @override
  String get homeGuideTextile => 'القمصان والجينز وبقايا القماش';

  @override
  String get homeGuideTitle => 'ابدأ بشيء من مطبخك أو خزانة ملابسك.';

  @override
  String get homeHeadline => 'ما الذي توشك على رميه؟';

  @override
  String get homeHistory => 'السجل';

  @override
  String homeImpactItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'غرض أُبعد عن سلة المهملات',
      many: 'غرضًا أُبعد عن سلة المهملات',
      few: 'أغراض أُبعدت عن سلة المهملات',
      two: 'غرضان أُبعدا عن سلة المهملات',
      one: 'غرض أُبعد عن سلة المهملات',
    );
    return '$_temp0';
  }

  @override
  String get homeImpactOpen => 'اعرض أثرك';

  @override
  String homeImpactProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مشروع مكتمل',
      many: 'مشروعًا مكتملًا',
      few: 'مشاريع مكتملة',
      two: 'مشروعان مكتملان',
      one: 'مشروع مكتمل',
    );
    return '$_temp0';
  }

  @override
  String homeImpactStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم على التوالي',
      many: 'يومًا على التوالي',
      few: 'أيام على التوالي',
      two: 'يومان على التوالي',
      one: 'يوم على التوالي',
    );
    return '$_temp0';
  }

  @override
  String get homeImpactTitle => 'أثرك';

  @override
  String homeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غرض',
      many: '$count غرضًا',
      few: '$count أغراض',
      two: 'غرضان',
      one: 'غرض واحد',
    );
    return '$_temp0';
  }

  @override
  String get homeLead => 'صوّره، وسيخبرك كنز ممّ صُنع وما الذي يمكن أن يصبح.';

  @override
  String get homeLoadingRecent => 'جارٍ تحميل آخر الفحوص';

  @override
  String get homeRecentTitle => 'آخر الفحوص';

  @override
  String get homeResume => 'تابِع';

  @override
  String get homeResumeEyebrow => 'تابِع مشروعك';

  @override
  String get homeResumeNotStarted => 'لم تفتح الدرس بعد';

  @override
  String homeResumeProgress(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get homeScan => 'صوّر غرضًا';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeSettings => 'الإعدادات';

  @override
  String get homeTip1 => 'غرض واحد في كل مرة، يملأ معظم الإطار.';

  @override
  String get homeTip2 => 'خلفية بسيطة وإضاءة متساوية.';

  @override
  String get homeTip3 => 'أظهر الملصقات أو رموز التدوير إن وُجدت.';

  @override
  String get homeTipsTitle => 'لصورة واضحة';

  @override
  String get homeUnfinishedScan => 'فحص لم يكتمل';

  @override
  String get ideaAfter => 'بعد';

  @override
  String get ideaBackToResults => 'العودة إلى النتائج';

  @override
  String get ideaBasedOn => 'المصادر';

  @override
  String get ideaBefore => 'قبل';

  @override
  String get ideaCompare => 'قارن بين قبل وبعد';

  @override
  String get ideaDifficulty => 'الصعوبة';

  @override
  String get ideaDragHint => 'اسحب للمقارنة';

  @override
  String ideaEyebrow(int index, int total) {
    return 'الفكرة $index من $total';
  }

  @override
  String get ideaFromDescription => 'من وصفك';

  @override
  String get ideaImageFailed => 'لم تُرسم المعاينة.';

  @override
  String get ideaImagePaused =>
      'توليد الصور متوقف على هذا الخادم، لذلك لا توجد معاينة بعد.';

  @override
  String get ideaMaterialsTitle => 'ستحتاج أيضًا';

  @override
  String get ideaMissingBody =>
      'تغيّرت أفكار هذا المسح. ارجع لترى الأفكار الحالية.';

  @override
  String get ideaMissingTitle => 'هذه الفكرة لم تعد متاحة';

  @override
  String get ideaNoTools => 'لا حاجة إلى أدوات، يكفي أن تستخدم يديك.';

  @override
  String get ideaRendering => 'جارٍ رسم الشكل الجديد';

  @override
  String get ideaSafety => 'السلامة';

  @override
  String get ideaSeeTutorial => 'اعرض الدرس';

  @override
  String get ideaTime => 'الوقت';

  @override
  String get ideaToolHave => 'لديك';

  @override
  String get ideaToolMissing => 'ستحتاج إليها';

  @override
  String get ideaTools => 'الأدوات';

  @override
  String get ideaToolsTitle => 'الأدوات اللازمة';

  @override
  String get impactActiveToday => 'سجّلت نشاطًا اليوم';

  @override
  String get impactByMaterial => 'حسب المادة';

  @override
  String get impactByPath => 'أين ذهبت';

  @override
  String get impactCo2Label => 'انبعاثات تم تجنّبها';

  @override
  String get impactEmptyMessage =>
      'صوّر شيئًا توشك على رميه، ثم أعد ابتكاره أو تدويره أو تبرّع به. كل غرض تسجّله يظهر هنا.';

  @override
  String get impactEmptyTitle => 'يبدأ أثرك بفحص واحد';

  @override
  String get impactErrorTitle => 'تعذّر تحميل أثرك';

  @override
  String get impactEstimateLabel => 'تقدير';

  @override
  String get impactHowItems =>
      'الأغراض التي تحدّدها من نتائج الفحص على أنها أُعيد تدويرها أو تُبرّع بها أو تُخلّص منها بأمان.';

  @override
  String get impactHowProjects =>
      'مشاريع إعادة الابتكار التي تُكملها خطوة بخطوة.';

  @override
  String get impactHowStreak =>
      'الأيام المتتالية التي فحصت فيها غرضًا، أو سجّلته، أو أكملت فيها مشروعًا.';

  @override
  String get impactHowTitle => 'ما الذي يُحتسب هنا';

  @override
  String get impactIntro => 'محسوب مما فحصته وسجّلته على هذا الهاتف.';

  @override
  String impactItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غرض',
      many: '$count غرضًا',
      few: '$count أغراض',
      two: 'غرضان',
      one: 'غرض واحد',
      zero: 'لا أغراض',
    );
    return '$_temp0';
  }

  @override
  String get impactItemsLabel => 'أغراض أبعدتها عن سلة المهملات';

  @override
  String get impactKeepStreak =>
      'صوّر غرضًا أو سجّله اليوم حتى لا تنقطع سلسلتك.';

  @override
  String get impactKindDisposed => 'تخلّص آمن';

  @override
  String get impactKindDonated => 'تبرّع';

  @override
  String get impactKindRecycled => 'إعادة تدوير';

  @override
  String get impactKindUpcycled => 'إعادة ابتكار';

  @override
  String get impactLoading => 'جارٍ حساب أثرك';

  @override
  String get impactMassLabel => 'مواد أُبعدت عن المكبّ';

  @override
  String get impactNoItemsYet =>
      'لم تسجّل شيئًا بعد. افتح نتائج أي فحص وحدّد غرضًا على أنه أُعيد تدويره أو تُبرّع به أو أُعيد ابتكاره ليُحتسب هنا.';

  @override
  String get impactProjectsLabel => 'مشاريع مكتملة';

  @override
  String get impactScanAction => 'صوّر غرضًا';

  @override
  String get impactStartStreak => 'صوّر شيئًا اليوم لتبدأ سلسلة جديدة.';

  @override
  String get impactStreakLabel => 'أيام متتالية';

  @override
  String get impactTitle => 'أثرك';

  @override
  String get onboardingChangeLater => 'يمكنك تغيير ذلك لاحقًا من الإعدادات.';

  @override
  String get onboardingFinish => 'ابدأ مع كنز';

  @override
  String get onboardingGetStarted => 'لنبدأ';

  @override
  String get onboardingLanguageArabicSample =>
      'الأفكار والدروس والصوت بالعربية.';

  @override
  String get onboardingLanguageBody =>
      'تتبعها القوائم والأفكار والدروس والخطوات المقروءة بصوت عالٍ.';

  @override
  String get onboardingLanguageEnglishSample =>
      'Ideas, tutorials and voice in English.';

  @override
  String get onboardingLanguageTitle => 'اختر لغتك';

  @override
  String get onboardingSkillAdvancedLine =>
      'تقيس وتنشر وتخيط وتُتقن اللمسات الأخيرة.';

  @override
  String get onboardingSkillBeginnerLine =>
      'قصّ ولصق وطلاء، دون أدوات كهربائية.';

  @override
  String get onboardingSkillBody =>
      'تتكيّف الدروس مع مستواك، فللمبتدئين خطوات أبسط وتفاصيل أكثر.';

  @override
  String get onboardingSkillIntermediateLine =>
      'تستخدم المثقاب وورق الصنفرة والإبرة بثقة.';

  @override
  String onboardingSkillLevel(int level) {
    return 'المستوى $level من 3';
  }

  @override
  String get onboardingSkillTitle => 'ما مدى خبرتك في الأعمال اليدوية؟';

  @override
  String get onboardingToolGroupBuilding => 'الثقب والتركيب';

  @override
  String onboardingToolGroupCount(int selected, int total) {
    return '$selected من $total مختارة';
  }

  @override
  String get onboardingToolGroupCutting => 'القصّ';

  @override
  String get onboardingToolGroupFinishing => 'الصنفرة والطلاء';

  @override
  String get onboardingToolGroupJoining => 'اللصق والتثبيت';

  @override
  String get onboardingToolGroupMeasuring => 'القياس';

  @override
  String get onboardingToolGroupOther => 'أدوات أخرى';

  @override
  String get onboardingToolGroupSewing => 'الخياطة';

  @override
  String get onboardingToolsBody =>
      'لا تستخدم الأفكار والدروس إلا هذه الأدوات، مع ذكر معدات السلامة دائمًا.';

  @override
  String onboardingToolsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اخترت $count أداة',
      many: 'اخترت $count أداة',
      few: 'اخترت $count أدوات',
      two: 'اخترت أداتين',
      one: 'اخترت أداة واحدة',
      zero: 'لم تختر أي أداة',
    );
    return '$_temp0';
  }

  @override
  String get onboardingToolsNone =>
      'لا بأس إن لم تكن لديك أدوات، فسيبدأ كنز بالأفكار التي لا تحتاج إليها.';

  @override
  String get onboardingToolsTitle => 'ما الأدوات التي لديك؟';

  @override
  String get onboardingWelcomeBody =>
      'صوّر شيئًا توشك على رميه، وسيخبرك كنز ممّ صُنع وماذا تفعل به.';

  @override
  String get onboardingWelcomeStep1Body =>
      'المواد والحالة والكمية من صورة واحدة.';

  @override
  String get onboardingWelcomeStep1Title => 'صوّر الغرض';

  @override
  String get onboardingWelcomeStep2Body =>
      'أعد ابتكاره بدرس خطوة بخطوة، أو أرسله للتدوير، أو تبرّع به.';

  @override
  String get onboardingWelcomeStep2Title => 'اختر طريقه';

  @override
  String get onboardingWelcomeStep3Body => 'نقاط التدوير والتبرع القريبة منك.';

  @override
  String get onboardingWelcomeStep3Title => 'سلّمه';

  @override
  String get onboardingWelcomeTitle => 'اكتشف الكنز فيما تتخلّص منه.';

  @override
  String get permissionsAsking => 'بانتظار ردّك';

  @override
  String get permissionsCameraAllow => 'اسمح بالكاميرا';

  @override
  String get permissionsCameraBlocked =>
      'الكاميرا متوقفة لكنز في إعدادات هاتفك. فعّلها من هناك، أو اختر صورة من المعرض.';

  @override
  String get permissionsCameraDenied =>
      'لم يُسمح بالوصول إلى الكاميرا. اطلبه مرة أخرى، أو اختر صورة من المعرض.';

  @override
  String get permissionsCameraGallery => 'اختر من المعرض بدلًا من ذلك';

  @override
  String get permissionsCameraReason1 =>
      'وجّه الكاميرا نحو أي غرض، وسيتعرّف كنز على مواده وحالته.';

  @override
  String get permissionsCameraReason2 =>
      'لا تُرسَل للتحليل إلا الصورة التي تلتقطها، بعد حذف بيانات موقعها.';

  @override
  String get permissionsCameraReason3 => 'لا تفضّل ذلك؟ اختر صورة من المعرض.';

  @override
  String get permissionsCameraRestricted =>
      'لا يمكن تفعيل الكاميرا لكنز على هذا الهاتف. اختر صورة من المعرض بدلًا من ذلك.';

  @override
  String get permissionsCameraTitle => 'أرِ كنز ما توشك على رميه';

  @override
  String get permissionsCityBody =>
      'يبحث كنز عن نقاط التسليم حول وسط المدينة، ويمكنك تغييرها في أي وقت من الإعدادات.';

  @override
  String get permissionsCityEyebrow => 'الإمارات';

  @override
  String get permissionsCitySelected => 'المختارة';

  @override
  String get permissionsCityTitle => 'اختر مدينتك';

  @override
  String get permissionsCityUseLocation => 'استخدم موقعي بدلًا من ذلك';

  @override
  String get permissionsCityUseLocationDetail =>
      'أدق، فالنقاط مرتّبة حسب بعدها عنك';

  @override
  String get permissionsFootnote => 'يمكنك تغيير ذلك في أي وقت من الإعدادات.';

  @override
  String get permissionsLocationAllow => 'استخدم موقعي';

  @override
  String get permissionsLocationBlocked =>
      'الوصول إلى الموقع متوقف لكنز في إعدادات هاتفك. فعّله من هناك، أو اختر مدينة.';

  @override
  String get permissionsLocationCity => 'اختر مدينة بدلًا من ذلك';

  @override
  String get permissionsLocationDenied =>
      'لم يُسمح بالوصول إلى الموقع. اطلبه مرة أخرى، أو اختر مدينة.';

  @override
  String get permissionsLocationReason1 =>
      'تُرتَّب نقاط التدوير والتبرع حسب بعدها عنك.';

  @override
  String get permissionsLocationReason2 =>
      'لا يقرأ كنز موقعك إلا عند البحث عن نقاط التسليم.';

  @override
  String get permissionsLocationReason3 =>
      'لا تفضّل ذلك؟ اختر مدينتك وسيبحث كنز حول وسطها.';

  @override
  String get permissionsLocationRestricted =>
      'لا يمكن تفعيل الموقع لكنز على هذا الهاتف. اختر مدينة بدلًا من ذلك.';

  @override
  String get permissionsLocationTitle => 'اعثر على نقاط التسليم القريبة منك';

  @override
  String get permissionsNotAllowed => 'غير مسموح';

  @override
  String get permissionsTurnedOff => 'متوقف من الإعدادات';

  @override
  String get permissionsUnavailable => 'غير متاح على هذا الهاتف';

  @override
  String resultsAccepts(String materials) {
    return 'يقبل $materials';
  }

  @override
  String resultsAroundCity(String city) {
    return 'حول $city، لأن موقعك كان تقريبيًا';
  }

  @override
  String resultsAttribution(String sources) {
    return 'الأماكن من $sources';
  }

  @override
  String get resultsBasedOn => 'المصادر';

  @override
  String get resultsBeforeYouGo => 'قبل أن تذهب';

  @override
  String resultsBoxSemantics(String name, String category, String confidence) {
    return '$name، $category، بثقة $confidence';
  }

  @override
  String get resultsChooseCity => 'اختر مدينة';

  @override
  String get resultsChooseFromGallery => 'اختر من المعرض';

  @override
  String get resultsClosedNow => 'مغلق الآن';

  @override
  String get resultsCorrectedNote => 'صحّحته بنفسك.';

  @override
  String get resultsDescribeAgain => 'أعد الوصف';

  @override
  String resultsDirections(String name) {
    return 'الاتجاهات إلى $name';
  }

  @override
  String get resultsDirectionsFailed =>
      'لم تُفتح الخرائط. حاول مرة أخرى بعد قليل.';

  @override
  String get resultsDisposalNever => 'لا تفعل أبدًا';

  @override
  String get resultsDisposalSteps => 'ما عليك فعله';

  @override
  String get resultsDo => 'افعل';

  @override
  String get resultsDonateNotSuitable => 'غير صالح للتبرّع';

  @override
  String get resultsDonateSuitable => 'صالح للتبرّع';

  @override
  String get resultsDonateUnavailableTitle => 'ليس مما يُتبرّع به';

  @override
  String get resultsDonateWhere => 'أين';

  @override
  String resultsDoneIn(String seconds) {
    return 'اكتمل في $seconds ث';
  }

  @override
  String get resultsDont => 'لا تفعل';

  @override
  String get resultsDropoffErrorTitle => 'لم تُحمَّل نقاط التسليم';

  @override
  String get resultsDropoffTitle => 'نقاط التسليم القريبة';

  @override
  String get resultsDropoffWaiting =>
      'تظهر نقاط التسليم بعد أن يعرف كنز ما هذا الغرض.';

  @override
  String get resultsEditCategory => 'المادة';

  @override
  String get resultsEditHazards => 'المخاطر';

  @override
  String get resultsEditItem => 'صحّح هذا الغرض';

  @override
  String get resultsEditMaterial => 'المادة بالتحديد';

  @override
  String get resultsEditMaterialHint => 'مثلًا: زجاج شفاف، بلاستيك PET رقم 1';

  @override
  String get resultsEditName => 'الاسم';

  @override
  String get resultsEditQuality => 'الجودة';

  @override
  String get resultsEditQuantity => 'الكمية';

  @override
  String get resultsEditQuantityInvalid => 'أدخل رقمًا، مثل 2 أو 0.5';

  @override
  String get resultsEditSave => 'احفظ وحدّث الأفكار';

  @override
  String get resultsEditState => 'الحالة';

  @override
  String get resultsEditSubtitle => 'سيحدّث كنز الأفكار بناءً على تعديلاتك.';

  @override
  String get resultsEditUnit => 'الوحدة';

  @override
  String get resultsFindingIdeas => 'جارٍ البحث عن أفكار تناسب أدواتك';

  @override
  String get resultsFocusItem => 'اجعل الأفكار لهذا الغرض';

  @override
  String get resultsFocusedItem => 'الأفكار أدناه لهذا الغرض';

  @override
  String resultsHazardLabel(String hazards) {
    return '$hazards: تخلّص آمن فقط، بلا أعمال يدوية';
  }

  @override
  String resultsHeldBackBody(String items) {
    return 'لا يصلح $items للأعمال اليدوية.';
  }

  @override
  String get resultsHeldBackPointer => 'طريقة التخلّص الآمن منه بعد الأفكار.';

  @override
  String get resultsHeldBackTitle => 'مستبعد من الأعمال اليدوية';

  @override
  String get resultsHideSteps => 'أخفِ الخطوات';

  @override
  String get resultsHoursUnknown => 'الساعات غير مذكورة';

  @override
  String get resultsIdeaBefore => 'قبل';

  @override
  String get resultsIdeaImageFailed => 'المعاينة غير متاحة';

  @override
  String get resultsIdeaImagePaused => 'توليد الصور متوقف';

  @override
  String get resultsIdeaImageRetry => 'أعد محاولة الصورة';

  @override
  String get resultsIdeaRendering => 'جارٍ رسم الشكل الجديد';

  @override
  String get resultsIdeasErrorTitle => 'لم تُحمَّل الأفكار';

  @override
  String get resultsIdentifyErrorTitle => 'لم يتمكن كنز من التعرّف على المواد';

  @override
  String resultsInCity(String city) {
    return 'في $city';
  }

  @override
  String resultsItemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عُثر على $count غرض',
      many: 'عُثر على $count غرضًا',
      few: 'عُثر على $count أغراض',
      two: 'عُثر على غرضين',
      one: 'عُثر على غرض واحد',
    );
    return '$_temp0';
  }

  @override
  String get resultsLabelConfidence => 'الثقة';

  @override
  String get resultsLabelMaterial => 'المادة';

  @override
  String get resultsLabelQuality => 'الجودة';

  @override
  String get resultsLabelQuantity => 'الكمية';

  @override
  String get resultsLabelRecyclable => 'قابلية التدوير';

  @override
  String get resultsLabelState => 'الحالة';

  @override
  String get resultsLabelType => 'النوع';

  @override
  String resultsListAnd(String first, String last) {
    return '$first و$last';
  }

  @override
  String get resultsLocationOff =>
      'الموقع مغلق أمام كنز، فاختر مدينة بدلًا منه.';

  @override
  String get resultsMarkDisposed => 'سجّل أنك تخلّصت منه';

  @override
  String get resultsMarkDonated => 'سجّل أنك تبرّعت به';

  @override
  String get resultsMarkRecycled => 'سجّل أنك أعدت تدويره';

  @override
  String get resultsMarkedDisposed => 'تخلّصت منه · أُضيف إلى أثرك';

  @override
  String get resultsMarkedDonated => 'تبرّعت به · أُضيف إلى أثرك';

  @override
  String get resultsMarkedRecycled => 'أُعيد تدويره · أُضيف إلى أثرك';

  @override
  String get resultsMaterialsSubtitle => 'المس أي غرض لترى تفاصيله.';

  @override
  String get resultsMaterialsTitle => 'مِمَّ صُنع';

  @override
  String get resultsMissingBody =>
      'ربما حُذف من السجل. ابدأ مسحًا جديدًا لترى الأفكار.';

  @override
  String get resultsMissingTitle => 'هذا المسح غير موجود على هذا الهاتف';

  @override
  String get resultsNearYou => 'بالقرب من موقعك';

  @override
  String get resultsNeedsLocationBody =>
      'استخدم موقعك أو اختر مدينة لترى أقرب نقاط التسليم.';

  @override
  String get resultsNeedsLocationTitle => 'أين يبحث كنز؟';

  @override
  String get resultsNewScan => 'مسح جديد';

  @override
  String get resultsNoDiyTitle => 'لا أعمال يدوية لهذا الغرض';

  @override
  String get resultsNoIdeasBody =>
      'قد يناسبه التدوير أو التبرّع أكثر. وإن أخطأ كنز في قراءته، فصحّحه في الأعلى.';

  @override
  String get resultsNoIdeasTitle => 'لا أفكار يدوية لهذا الغرض';

  @override
  String get resultsNoPlacesBody =>
      'يمكنك في تبويب نقاط التسليم البحث في أماكن أكثر أو في مدينة أخرى.';

  @override
  String get resultsNoPlacesTitle => 'لم نجد نقاط تسليم قريبة';

  @override
  String get resultsOffline =>
      'أنت غير متصل. النتائج المحفوظة تُفتح كالمعتاد، والخطوات الجديدة تنتظر الاتصال.';

  @override
  String get resultsOpenDropoff => 'افتح نقاط التسليم';

  @override
  String get resultsOpenNow => 'مفتوح الآن';

  @override
  String get resultsPathsTitle => 'ماذا يمكن أن يصبح';

  @override
  String get resultsPathsTitleDisposal => 'كيف تتخلّص منه بأمان';

  @override
  String resultsPhotoSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صورتك، وُجد فيها $count غرض',
      many: 'صورتك، وُجد فيها $count غرضًا',
      few: 'صورتك، وُجدت فيها $count أغراض',
      two: 'صورتك، وُجد فيها غرضان',
      one: 'صورتك، وُجد فيها غرض واحد',
      zero: 'صورتك',
    );
    return '$_temp0';
  }

  @override
  String get resultsPrep => 'التحضير';

  @override
  String resultsQualitySemantics(int score, String label) {
    return 'الجودة $score من 5، $label';
  }

  @override
  String get resultsReadAs => 'فهمه كنز على أنه';

  @override
  String get resultsReadingItems => 'جارٍ قراءة المادة والكمية والحالة';

  @override
  String resultsRecyclableValue(String status, String stream) {
    return '$status · $stream';
  }

  @override
  String get resultsRecycleEmpty => 'لم تصل خطوات لإعادة التدوير في هذا المسح.';

  @override
  String get resultsRetake => 'أعد التقاط الصورة';

  @override
  String get resultsRetakeFallbackTitle => 'لم يتبيّن كنز أي غرض';

  @override
  String get resultsSafeDisposalTitle => 'التخلّص الآمن';

  @override
  String resultsSeconds(String seconds) {
    return '$seconds ث';
  }

  @override
  String get resultsSeeAll => 'عرض الكل';

  @override
  String get resultsShowSteps => 'اعرض الخطوات';

  @override
  String get resultsSourceCurated => 'قائمة كنز';

  @override
  String get resultsSourceGoogle => 'Google';

  @override
  String get resultsSourceOsm => 'مساهمي OpenStreetMap';

  @override
  String get resultsStageImagesPaused =>
      'توليد الصور متوقف على هذا الخادم. الأفكار والدروس تعمل كالمعتاد.';

  @override
  String get resultsStageNeedsLocation => 'اختر مكان البحث في الأسفل.';

  @override
  String get resultsStageNoDropoff => 'لا شيء هنا يحتاج إلى نقطة تسليم.';

  @override
  String get resultsStageNoMakeovers => 'لا أفكار لرسمها.';

  @override
  String get resultsStageNoMakeoversDisposal =>
      'لا شيء يُرسم: هذا الغرض يحتاج إلى تخلّص آمن.';

  @override
  String get resultsSummaryDisposal => 'تخلّص آمن';

  @override
  String resultsSummaryIdeas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فكرة',
      many: '$count فكرة',
      few: '$count أفكار',
      two: 'فكرتان',
      one: 'فكرة واحدة',
      zero: 'بلا أفكار',
    );
    return '$_temp0';
  }

  @override
  String get resultsSummaryImagesPaused => 'الصور متوقفة';

  @override
  String resultsSummaryPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكان',
      many: '$count مكانًا',
      few: '$count أماكن',
      two: 'مكانان',
      one: 'مكان واحد',
      zero: 'لا أماكن قريبة',
    );
    return '$_temp0';
  }

  @override
  String get resultsTabDispose => 'تخلّص آمن';

  @override
  String get resultsTabDonate => 'تبرّع';

  @override
  String get resultsTabRecycle => 'إعادة تدوير';

  @override
  String get resultsTabUpcycle => 'تدوير إبداعي';

  @override
  String get resultsTextRejectedBody =>
      'اذكر اسم الغرض ومادته، مثلًا: قارورتا ماء بلاستيكيتان فارغتان.';

  @override
  String get resultsTextRejectedTitle => 'لم يتمكن كنز من معرفة ما هو';

  @override
  String get resultsTextScan => 'مسح بالوصف';

  @override
  String get resultsTip => 'جرّب هذا';

  @override
  String get resultsTitle => 'نتائج المسح';

  @override
  String get resultsToolsAll => 'لديك كل الأدوات';

  @override
  String resultsToolsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تحتاج إلى $count أداة ليست لديك',
      many: 'تحتاج إلى $count أداة ليست لديك',
      few: 'تحتاج إلى $count أدوات ليست لديك',
      two: 'تحتاج إلى أداتين ليستا لديك',
      one: 'تحتاج إلى أداة واحدة ليست لديك',
    );
    return '$_temp0';
  }

  @override
  String get resultsToolsNone => 'لا حاجة إلى أدوات';

  @override
  String resultsToolsSome(int have, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'لديك $have من $total أداة',
      many: 'لديك $have من $total أداة',
      few: 'لديك $have من $total أدوات',
      two: 'لديك $have من أداتين',
      one: 'لديك $have من أداة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get resultsUnitBag => 'أكياس';

  @override
  String get resultsUnitG => 'غ';

  @override
  String get resultsUnitHandful => 'حفنات';

  @override
  String get resultsUnitKg => 'كغ';

  @override
  String get resultsUnitL => 'لتر';

  @override
  String get resultsUnitM => 'م';

  @override
  String get resultsUnitM2 => 'م²';

  @override
  String get resultsUnitPcs => 'قطع';

  @override
  String get resultsUseMyLocation => 'استخدم موقعي';

  @override
  String get scanBackToCamera => 'العودة إلى الكاميرا';

  @override
  String get scanCameraAllow => 'اسمح باستخدام الكاميرا';

  @override
  String get scanCameraBlockedBody =>
      'الوصول إلى الكاميرا مغلق أمام كنز. فعّله من الإعدادات، أو استخدم صورة من معرض الصور.';

  @override
  String get scanCameraDeniedBody =>
      'ما زال بإمكانك اختيار صورة التقطتها من قبل، أو وصف الغرض في جملة.';

  @override
  String get scanCameraDeniedTitle => 'لا يستطيع كنز استخدام الكاميرا';

  @override
  String get scanCameraUnavailableBody =>
      'ربما يستخدمها تطبيق آخر. حاول مرة أخرى، أو اختر صورة من المعرض.';

  @override
  String get scanCameraUnavailableTitle => 'الكاميرا غير متاحة';

  @override
  String get scanChooseFromGallery => 'اختر من المعرض';

  @override
  String get scanDescribe => 'صِف';

  @override
  String get scanDescribeBody =>
      'اذكر ما هو، ومِمَّ صُنع، وكم قطعة لديك، وما حالتها.';

  @override
  String get scanDescribeHint =>
      'مثلًا: ثلاثة برطمانات زجاجية فارغة بأغطية معدنية';

  @override
  String get scanDescribeInstead => 'صِفه بدلًا من ذلك';

  @override
  String get scanDescribeLabel => 'الوصف';

  @override
  String get scanDescribeSemantics => 'صِف الغرض بالكلمات';

  @override
  String get scanDescribeStart => 'تعرّف على المواد';

  @override
  String get scanDescribeTitle => 'صِف ما لديك';

  @override
  String get scanExampleBatteries => 'أربع بطاريات AA مستعملة';

  @override
  String get scanExampleBox => 'صندوق كرتون كبير من طلبية توصيل';

  @override
  String get scanExampleJars => 'برطمانات مربى زجاجية فارغة بأغطية معدنية';

  @override
  String get scanExampleJeans => 'كومة من سراويل الجينز القديمة';

  @override
  String scanExampleSemantics(String example) {
    return 'استخدم المثال: $example';
  }

  @override
  String get scanExamplesTitle => 'أو ابدأ بمثال';

  @override
  String get scanGallery => 'المعرض';

  @override
  String get scanGalleryErrorBody =>
      'تأكد من أن كنز مسموح له بقراءة صورك، ثم حاول مرة أخرى.';

  @override
  String get scanGalleryErrorTitle => 'تعذّر فتح صورك';

  @override
  String get scanGallerySemantics => 'اختر صورة من معرض الصور';

  @override
  String get scanGuidance => 'اجعل الغرض يملأ الإطار، في إضاءة جيدة';

  @override
  String get scanNoCameraBody =>
      'لا توجد في هذا الهاتف كاميرا يستطيع كنز استخدامها. اختر صورة أو صِف الغرض بدلًا من ذلك.';

  @override
  String get scanOffline =>
      'أنت غير متصل. يحتاج كنز إلى اتصال ليتعرّف على المواد.';

  @override
  String get scanOpeningGallery => 'جارٍ فتح صورك';

  @override
  String get scanShutter => 'التقط صورة';

  @override
  String get scanStartingCamera => 'جارٍ تشغيل الكاميرا';

  @override
  String get scanTextScan => 'مسح بالوصف';

  @override
  String get scanTorch => 'الكشّاف';

  @override
  String get settingsAbout => 'حول كنز';

  @override
  String get settingsAboutBody =>
      'يتعرّف كنز على المواد التي صُنعت منها أغراضك، ويقترح إعادة ابتكارها أو تدويرها أو التبرع بها، ويدلّك على نقاط التسليم في الإمارات.';

  @override
  String get settingsCo2eNote =>
      'أرقام مكافئ ثاني أكسيد الكربون في كنز تقديرات مبنية على معاملات انبعاث متوسطة، وليست قياسات.';

  @override
  String get settingsEstimates => 'تقديرات';

  @override
  String get settingsHandsFree => 'بلا لمس افتراضيًا';

  @override
  String get settingsHandsFreeDetail =>
      'يقرأ كل خطوة بصوت عالٍ وينتظر كلمات \"التالي\" و\"السابق\" و\"كرر\".';

  @override
  String get settingsKnowledge => 'قاعدة المعرفة';

  @override
  String settingsKnowledgeDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستند',
      many: '$count مستندًا',
      few: '$count مستندات',
      two: 'مستندان',
      one: 'مستند واحد',
    );
    return '$_temp0';
  }

  @override
  String settingsKnowledgeKeyword(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستند، بحث بالكلمات',
      many: '$count مستندًا، بحث بالكلمات',
      few: '$count مستندات، بحث بالكلمات',
      two: 'مستندان، بحث بالكلمات',
      one: 'مستند واحد، بحث بالكلمات',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageNote =>
      'تستخدم الأفكار والدروس والخطوات المقروءة هذه اللغة أيضًا.';

  @override
  String settingsLanguageSystemDetail(String language) {
    return 'حاليًا: $language';
  }

  @override
  String get settingsLicenses => 'تراخيص البرمجيات مفتوحة المصدر';

  @override
  String get settingsLocation => 'الموقع لنقاط التسليم';

  @override
  String get settingsLocationCity => 'مدينة محددة';

  @override
  String settingsLocationCityDetail(String city) {
    return 'البحث حول $city';
  }

  @override
  String get settingsLocationCityNone => 'اختر مدينة';

  @override
  String get settingsLocationGps => 'استخدم موقعي';

  @override
  String get settingsLocationGpsDetail => 'النقاط مرتّبة حسب بعدها عنك';

  @override
  String get settingsLocationGpsOff =>
      'الوصول إلى الموقع متوقف، لذا يستخدم كنز مدينتك حتى تسمح به.';

  @override
  String get settingsLocationGpsOffNoCity =>
      'الوصول إلى الموقع متوقف. اسمح به أو اختر مدينة.';

  @override
  String get settingsLocationUndecided =>
      'سيسألك كنز أول مرة تبحث فيها عن نقاط التسليم.';

  @override
  String get settingsModelEmbed => 'نموذج التضمين';

  @override
  String get settingsModelImage => 'نموذج الصور';

  @override
  String get settingsModelText => 'نموذج النصوص';

  @override
  String get settingsModelVision => 'نموذج الرؤية';

  @override
  String get settingsPlaces => 'مصادر الأماكن';

  @override
  String get settingsPlacesNone => 'لا مصادر مُعدّة';

  @override
  String get settingsServer => 'الخادم';

  @override
  String settingsServerHelper(String url) {
    return 'الافتراضي: $url';
  }

  @override
  String get settingsServerInvalid =>
      'أدخل عنوانًا كاملًا يبدأ بـ http:// أو https://';

  @override
  String get settingsServerNoAi =>
      'لا يوجد مفتاح ذكاء اصطناعي على هذا الخادم، لذا لا يمكن تحليل الفحوص.';

  @override
  String get settingsServerOfflineDetail =>
      'لا يوجد اتصال بالشبكة على هذا الهاتف.';

  @override
  String get settingsServerReset => 'استخدم الافتراضي';

  @override
  String get settingsServerSave => 'احفظ واختبر';

  @override
  String get settingsServerTest => 'اختبر الاتصال';

  @override
  String get settingsServerTesting => 'جارٍ اختبار الاتصال';

  @override
  String get settingsServerUnreachableDetail =>
      'تحقّق من العنوان، ومن أن الخادم يعمل وعلى الشبكة نفسها.';

  @override
  String get settingsServerUrl => 'عنوان الخادم';

  @override
  String get settingsServerVersion => 'إصدار الخادم';

  @override
  String get settingsSkill => 'مستوى المهارة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsTools => 'أدواتي';

  @override
  String get settingsToolsListSeparator => '، ';

  @override
  String settingsToolsMore(String names, int count) {
    return '$names و$count أخرى';
  }

  @override
  String get settingsToolsNone =>
      'لا شيء بعد. تأتي أولًا الأفكار التي لا تحتاج إلى أدوات.';

  @override
  String get settingsTutorials => 'الدروس';

  @override
  String get settingsWorkshop => 'ورشتك';

  @override
  String get shellChecking => 'جارٍ التحقق من الاتصال';

  @override
  String get shellOffline =>
      'أنت غير متصل بالإنترنت. الفحوص المحفوظة ما زالت تُفتح.';

  @override
  String get shellRetry => 'أعد المحاولة';

  @override
  String get shellScan => 'صوّر غرضًا';

  @override
  String get shellTabDropoff => 'التسليم';

  @override
  String get shellTabHome => 'الرئيسية';

  @override
  String get shellTabImpact => 'الأثر';

  @override
  String get shellTabSwaps => 'البدائل';

  @override
  String get shellUnreachable =>
      'تعذّر الوصول إلى خادم كنز. الفحوص المحفوظة ما زالت تُفتح.';

  @override
  String get swapsChipBatteries => 'بطاريات';

  @override
  String get swapsChipClingFilm => 'غلاف بلاستيكي للطعام';

  @override
  String get swapsChipCoffeeCapsules => 'كبسولات القهوة';

  @override
  String get swapsChipPaperTowels => 'مناشف ورقية';

  @override
  String get swapsChipPlasticBags => 'أكياس بلاستيكية';

  @override
  String get swapsChipPlasticBottles => 'زجاجات بلاستيكية';

  @override
  String get swapsChipTakeawayContainers => 'علب الطعام الجاهز';

  @override
  String get swapsChipWetWipes => 'مناديل مبللة';

  @override
  String get swapsChipsLabel => 'يتكرر في سلة المهملات';

  @override
  String swapsCost(String level) {
    return 'التكلفة: $level';
  }

  @override
  String swapsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بديل',
      many: '$count بديلًا',
      few: '$count بدائل',
      two: 'بديلان',
      one: 'بديل واحد',
    );
    return '$_temp0';
  }

  @override
  String swapsEffort(String level) {
    return 'الجهد: $level';
  }

  @override
  String get swapsEmptyMessage =>
      'لم يجد كنز ما يطابق هذه العناصر. جرّب عنصرًا شائعًا، مثل الزجاجات البلاستيكية أو غلاف الطعام البلاستيكي.';

  @override
  String get swapsEmptyTitle => 'لا بدائل لذلك بعد';

  @override
  String get swapsErrorTitle => 'تعذّر تحميل البدائل';

  @override
  String get swapsFreeTextHelper => 'افصل بين العناصر بفاصلة';

  @override
  String get swapsFreeTextHint => 'مصاصات، صوانٍ من الألمنيوم، شفرات حلاقة';

  @override
  String get swapsFreeTextLabel => 'أضف شيئًا آخر';

  @override
  String get swapsFromScans => 'من فحوصك';

  @override
  String swapsHistorySubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'تشمل الاقتراحات أيضًا ما فحصته خلال آخر $days يوم',
      many: 'تشمل الاقتراحات أيضًا ما فحصته خلال آخر $days يومًا',
      few: 'تشمل الاقتراحات أيضًا ما فحصته خلال آخر $days أيام',
      two: 'تشمل الاقتراحات أيضًا ما فحصته خلال آخر يومين',
      one: 'تشمل الاقتراحات أيضًا ما فحصته اليوم',
    );
    return '$_temp0';
  }

  @override
  String get swapsHistoryTitle => 'استخدم سجل فحوصي';

  @override
  String get swapsHowCost =>
      'الجهد والتكلفة بنظرة سريعة، مع المصادر التي بُني عليها.';

  @override
  String get swapsHowSwap => 'بديل يدوم لكل عنصر تختاره.';

  @override
  String get swapsHowTip => 'لماذا يفيد، ونصيحة واحدة تساعدك على الالتزام به.';

  @override
  String get swapsHowTitle => 'ما الذي ستحصل عليه';

  @override
  String get swapsInsightLabel => 'من فحوصك';

  @override
  String get swapsInsteadOf => 'بدلًا من';

  @override
  String get swapsIntro =>
      'اختر ما ترميه أكثر من غيره، وسيقترح كنز بديلًا يدوم لكلٍّ منها، مع نصيحة واحدة تساعدك على الالتزام به.';

  @override
  String swapsLoading(String items) {
    return 'البحث عن بدائل: $items';
  }

  @override
  String get swapsLoadingHistory => 'البحث عن بدائل بناءً على فحوصك';

  @override
  String get swapsOfflineTitle => 'أنت غير متصل';

  @override
  String get swapsResultsTitle => 'بدائل مقترحة لك';

  @override
  String get swapsSources => 'المصادر';

  @override
  String get swapsStartOver => 'ابدأ من جديد';

  @override
  String get swapsSubmit => 'اقترح بدائل';

  @override
  String get swapsSubmitHint =>
      'اختر عنصرًا واحدًا على الأقل، أو اكتب ما تريد.';

  @override
  String get swapsTip => 'نصيحة';

  @override
  String get swapsTitle => 'البدائل';

  @override
  String get swapsTry => 'جرّب';

  @override
  String get swapsUpdate => 'حدّث البدائل';

  @override
  String get tutorialAdaptBody =>
      'يعيد كنز كتابة الخطوات بما يناسب مهارتك والأدوات المتوفرة لديك.';

  @override
  String tutorialAdaptFailed(String reason) {
    return 'تعذّرت إعادة كتابة الدليل. $reason';
  }

  @override
  String get tutorialAdaptOffline => 'تعديل الدليل يحتاج إلى اتصال بالإنترنت.';

  @override
  String get tutorialAdaptProgressNote =>
      'سيبدأ تقدّمك من جديد، لأن الخطوات ستتغير.';

  @override
  String get tutorialAdaptSkill => 'مهارتك';

  @override
  String get tutorialAdaptSubmit => 'أعد كتابة الخطوات';

  @override
  String get tutorialAdaptTitle => 'عدّل هذا الدليل';

  @override
  String get tutorialAdaptTools => 'الأدوات المتوفرة لديك';

  @override
  String get tutorialAdaptToolsHint =>
      'إن لم تختر أداةً، يجد كنز طريقة للاستغناء عنها.';

  @override
  String get tutorialAdaptTooltip => 'عدّل الدليل حسب مهارتك وأدواتك';

  @override
  String get tutorialAdaptedLabel => 'نسختك';

  @override
  String tutorialAdapting(String skill) {
    return 'نعيد الكتابة لمستوى $skill وبأدواتك. تبقى الخطوات الحالية هنا حتى تصل الجديدة.';
  }

  @override
  String get tutorialBefore => 'قبل';

  @override
  String get tutorialCareLabel => 'العناية';

  @override
  String get tutorialCareful => 'انتبه';

  @override
  String get tutorialChangeSetup => 'غيّر المهارة أو الأدوات';

  @override
  String get tutorialCommandBack => 'السابق';

  @override
  String get tutorialCommandNext => 'التالي';

  @override
  String get tutorialCommandRepeat => 'كرر';

  @override
  String tutorialContinue(int number) {
    return 'تابع من الخطوة $number';
  }

  @override
  String get tutorialDismiss => 'إخفاء';

  @override
  String get tutorialErrorTitle => 'تعذّر تحميل الدليل';

  @override
  String get tutorialEyebrow => 'الدليل';

  @override
  String get tutorialFinish => 'إنهاء المشروع';

  @override
  String get tutorialFinishEyebrow => 'اقتربت من النهاية';

  @override
  String get tutorialFinishFailed => 'تعذّر حفظ المشروع. حاول مجدداً.';

  @override
  String get tutorialFinishSaving => 'نحفظ مشروعك';

  @override
  String get tutorialFinishTitle => 'اللمسات الأخيرة والعناية';

  @override
  String get tutorialFinishingLabel => 'اللمسات الأخيرة';

  @override
  String get tutorialFromScan => 'من صورتك';

  @override
  String get tutorialGearLabel => 'معدات الوقاية';

  @override
  String get tutorialHandsFree => 'التحكم بالصوت';

  @override
  String get tutorialHandsFreeOn => 'التحكم بالصوت مفعّل';

  @override
  String get tutorialHandsFreeStarting => 'جارٍ تشغيل التحكم بالصوت';

  @override
  String tutorialHeard(String command) {
    return 'سُمع: «$command»';
  }

  @override
  String tutorialImageBlocked(int number) {
    return 'بانتظار صورة الخطوة $number';
  }

  @override
  String tutorialImageDrawing(int number) {
    return 'نرسم الخطوة $number';
  }

  @override
  String get tutorialImageFailed => 'تعذّر تحميل صورة هذه الخطوة';

  @override
  String tutorialImageLabel(int number, String title) {
    return 'صورة الخطوة $number: $title';
  }

  @override
  String get tutorialImagePaused => 'توليد الصور متوقف مؤقتاً على هذا الخادم';

  @override
  String tutorialImageQueued(int number) {
    return 'في الانتظار بعد الخطوة $number';
  }

  @override
  String tutorialImageTag(String number) {
    return 'الخطوة $number';
  }

  @override
  String get tutorialListening => 'يستمع الآن';

  @override
  String get tutorialLoadingBody =>
      'يكتب كنز الخطوات بما يناسب مهارتك والأدوات المتوفرة لديك. يستغرق ذلك نحو عشر ثوانٍ.';

  @override
  String get tutorialLoadingTitle => 'نكتب لك الدليل';

  @override
  String get tutorialMarkDone => 'أنجزتُ الخطوة';

  @override
  String get tutorialMaterialsTitle => 'المواد';

  @override
  String get tutorialMissingAction => 'العودة إلى الفكرة';

  @override
  String get tutorialMissingBody =>
      'ربما حُذف المسح الخاص بها. ارجع واختر فكرة أخرى.';

  @override
  String get tutorialMissingTitle => 'هذه الفكرة لم تعد متاحة';

  @override
  String get tutorialNext => 'الخطوة التالية';

  @override
  String get tutorialNoHandsFree =>
      'التحكم بالصوت غير متاح على هذا الهاتف. الأزرار تعمل كالمعتاد.';

  @override
  String get tutorialNoSpeech =>
      'لا يوجد على هذا الهاتف صوت لقراءة الخطوات. الأوامر الصوتية ما زالت تعمل.';

  @override
  String get tutorialNoVoice =>
      'الأوامر الصوتية غير متاحة على هذا الهاتف. تُقرأ الخطوات بصوت مسموع، واستخدم الأزرار للتنقل.';

  @override
  String get tutorialOfflineBanner =>
      'أنت غير متصل. الدليل محفوظ، أما الصور الجديدة وتعديل الخطوات فتحتاج إلى اتصال.';

  @override
  String get tutorialOfflineBody =>
      'هذا الدليل غير محفوظ على هاتفك بعد. اتصل بالإنترنت وحاول مجدداً.';

  @override
  String get tutorialOfflineTitle => 'أنت غير متصل';

  @override
  String get tutorialOverview => 'العودة إلى النظرة العامة';

  @override
  String get tutorialPrevious => 'الخطوة السابقة';

  @override
  String get tutorialSafetyNotes => 'قبل أن تبدأ';

  @override
  String get tutorialSafetyTitle => 'السلامة';

  @override
  String get tutorialSourcesLabel => 'المصادر';

  @override
  String tutorialSpeaking(int number) {
    return 'يقرأ الخطوة $number';
  }

  @override
  String get tutorialSpecSkill => 'المهارة';

  @override
  String get tutorialSpecSteps => 'الخطوات';

  @override
  String get tutorialSpecTime => 'الوقت';

  @override
  String get tutorialSpecTools => 'الأدوات';

  @override
  String get tutorialStart => 'ابدأ الخطوة 1';

  @override
  String get tutorialStepDone => 'الخطوة منجزة';

  @override
  String get tutorialStepDoneHint => 'اضغط لإلغاء الإنجاز';

  @override
  String get tutorialStepDoneTag => 'منجزة';

  @override
  String tutorialStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوة',
      many: '$count خطوة',
      few: '$count خطوات',
      two: 'خطوتان',
      one: 'خطوة واحدة',
      zero: 'لا خطوات',
    );
    return '$_temp0';
  }

  @override
  String tutorialStepsDone(int done, int total) {
    return 'المنجز $done من $total خطوات';
  }

  @override
  String tutorialStepsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقيت $count خطوة غير منجزة، ويمكنك الإنهاء الآن.',
      many: 'بقيت $count خطوة غير منجزة، ويمكنك الإنهاء الآن.',
      few: 'بقيت $count خطوات غير منجزة، ويمكنك الإنهاء الآن.',
      two: 'بقيت خطوتان غير منجزتين، ويمكنك الإنهاء الآن.',
      one: 'بقيت خطوة واحدة غير منجزة، ويمكنك الإنهاء الآن.',
    );
    return '$_temp0';
  }

  @override
  String get tutorialTip => 'نصيحة';

  @override
  String get tutorialToFinish => 'إلى اللمسات الأخيرة';

  @override
  String get tutorialToGather => 'تحتاج إلى تجهيزها';

  @override
  String get tutorialToolHave => 'متوفرة لديك';

  @override
  String get tutorialToolInstead => 'بديل مناسب';

  @override
  String get tutorialToolMissing => 'غير متوفرة';

  @override
  String tutorialToolsReady(int have, int total) {
    return '$have من $total متوفرة';
  }

  @override
  String get tutorialToolsTitle => 'الأدوات';

  @override
  String get tutorialUpdated => 'مُحدَّث';

  @override
  String get tutorialVoiceHint => 'قل «التالي» أو «السابق» أو «كرر»';
}
