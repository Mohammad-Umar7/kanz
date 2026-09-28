/// Sample content for the component gallery, in English and Arabic.
///
/// Recognition, idea, tutorial and swap text comes from the contract
/// fixtures (contracts/fixtures/*glass_jar*, analyze_battery.json,
/// tutorial_jar_lantern*, swaps_plastic.json) so components are shown with the shapes and lengths
/// real responses have. Place rows use descriptive names because the
/// facility fixtures use placeholder names.
library;

import 'package:flutter/widgets.dart';

@immutable
class GallerySpecimen {
  const GallerySpecimen({
    required this.name,
    required this.material,
    required this.quantity,
    required this.quality,
    required this.qualitySemantics,
    required this.recyclable,
    required this.confidence,
    required this.note,
    required this.states,
    required this.boxLabel,
  });

  final String name;
  final String material;
  final String quantity;
  final String quality;
  final String qualitySemantics;
  final String recyclable;
  final String confidence;
  final String note;
  final List<String> states;
  final String boxLabel;
}

@immutable
class GalleryIdea {
  const GalleryIdea({
    required this.title,
    required this.pitch,
    required this.meta,
    required this.toolMatch,
    required this.have,
    required this.total,
  });

  final String title;
  final String pitch;
  final List<String> meta;
  final String toolMatch;
  final int have;
  final int total;
}

@immutable
class GalleryPlace {
  const GalleryPlace({
    required this.name,
    required this.address,
    required this.type,
    required this.distance,
    required this.openLabel,
    required this.open,
    required this.materials,
  });

  final String name;
  final String address;
  final String type;
  final String distance;
  final String openLabel;

  /// true open, false closed, null not listed.
  final bool? open;
  final List<String> materials;
}

@immutable
class GallerySwap {
  const GallerySwap({
    required this.from,
    required this.to,
    required this.why,
    required this.tip,
    required this.meta,
    this.badge,
  });

  final String from;
  final String to;
  final String why;
  final String tip;
  final List<String> meta;
  final String? badge;
}

@immutable
class GalleryRationale {
  const GalleryRationale({
    required this.title,
    required this.reasons,
    required this.allow,
    required this.alternative,
    required this.footnote,
  });

  final String title;
  final List<String> reasons;
  final String allow;
  final String alternative;
  final String footnote;
}

/// Every string the gallery shows, for one language.
@immutable
class GallerySamples {
  const GallerySamples({
    required this.title,
    required this.sections,
    required this.darkToggle,
    required this.rtlToggle,
    required this.textToggle,
    required this.seeTutorial,
    required this.retake,
    required this.skip,
    required this.deleteHistory,
    required this.saving,
    required this.scan,
    required this.chooseFromGallery,
    required this.share,
    required this.readAloud,
    required this.flash,
    required this.close,
    required this.materials,
    required this.tabs,
    required this.material,
    required this.type,
    required this.quantity,
    required this.quality,
    required this.state,
    required this.recyclable,
    required this.confidence,
    required this.correctItem,
    required this.photoSemantics,
    required this.jar,
    required this.lid,
    required this.battery,
    required this.batteryHazard,
    required this.stages,
    required this.stageTimes,
    required this.pipelineSummary,
    required this.showSteps,
    required this.hideSteps,
    required this.imagesPaused,
    required this.noDiyIdeas,
    required this.noMakeovers,
    required this.ideas,
    required this.rendering,
    required this.previewUnavailable,
    required this.before,
    required this.after,
    required this.compare,
    required this.sourcesTitle,
    required this.sources,
    required this.tipTitle,
    required this.carefulTitle,
    required this.safetyTitle,
    required this.tip,
    required this.careful,
    required this.safety,
    required this.stepOf,
    required this.stepTime,
    required this.stepTitle,
    required this.stepInstruction,
    required this.places,
    required this.directions,
    required this.insteadOf,
    required this.tryThis,
    required this.tipLabel,
    required this.swaps,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.errorTitle,
    required this.errorMessage,
    required this.tryAgain,
    required this.errorCode,
    required this.offline,
    required this.camera,
    required this.location,
    required this.itemsSaved,
    required this.itemsSavedLabel,
    required this.projectsDone,
    required this.projectsDoneLabel,
    required this.materialCounts,
    required this.nav,
    required this.fieldLabel,
    required this.fieldHint,
    required this.fieldHelper,
    required this.languageSetting,
    required this.languageValue,
    required this.toolsSetting,
    required this.toolsDetail,
    required this.handsFree,
    required this.handsFreeDetail,
    required this.sheetTitle,
    required this.sheetSubtitle,
  });

  /// Screen title.
  final String title;

  /// Section titles, in gallery order.
  final List<String> sections;
  final String darkToggle;
  final String rtlToggle;
  final String textToggle;

  final String seeTutorial;
  final String retake;
  final String skip;
  final String deleteHistory;
  final String saving;
  final String scan;
  final String chooseFromGallery;
  final String share;
  final String readAloud;
  final String flash;
  final String close;

  /// Material category labels keyed by vocabulary id.
  final Map<String, String> materials;

  /// Upcycle, Recycle, Donate.
  final List<String> tabs;

  final String material;
  final String type;
  final String quantity;
  final String quality;
  final String state;
  final String recyclable;
  final String confidence;
  final String correctItem;
  final String photoSemantics;
  final GallerySpecimen jar;
  final GallerySpecimen lid;

  /// A hazardous item: disposal only, no DIY.
  final GallerySpecimen battery;
  final String batteryHazard;

  final List<String> stages;
  final List<String> stageTimes;
  final String pipelineSummary;
  final String showSteps;
  final String hideSteps;
  final String imagesPaused;

  /// Skipped-stage notes for a hazardous item.
  final String noDiyIdeas;
  final String noMakeovers;

  final List<GalleryIdea> ideas;
  final String rendering;
  final String previewUnavailable;
  final String before;
  final String after;
  final String compare;
  final String sourcesTitle;
  final List<String> sources;

  final String tipTitle;
  final String carefulTitle;
  final String safetyTitle;
  final String tip;
  final String careful;
  final String safety;

  final String stepOf;
  final String stepTime;
  final String stepTitle;
  final String stepInstruction;

  final List<GalleryPlace> places;
  final String directions;
  final String insteadOf;
  final String tryThis;
  final String tipLabel;
  final List<GallerySwap> swaps;

  final String emptyTitle;
  final String emptyMessage;
  final String errorTitle;
  final String errorMessage;
  final String tryAgain;
  final String errorCode;
  final String offline;
  final GalleryRationale camera;
  final GalleryRationale location;

  final String itemsSaved;
  final String itemsSavedLabel;
  final String projectsDone;
  final String projectsDoneLabel;

  /// Formatted counts for the material bars, keyed by category id.
  final Map<String, String> materialCounts;

  /// Home, Drop-off, Swaps, Impact.
  final List<String> nav;

  final String fieldLabel;
  final String fieldHint;
  final String fieldHelper;
  final String languageSetting;
  final String languageValue;
  final String toolsSetting;
  final String toolsDetail;
  final String handsFree;
  final String handsFreeDetail;
  final String sheetTitle;
  final String sheetSubtitle;

  static const GallerySamples en = GallerySamples(
    title: 'Design gallery',
    sections: [
      'Foundations',
      'Controls',
      'Recognition',
      'Recommendations',
      'Tutorial',
      'Drop-off and swaps',
      'States',
      'Navigation and brand',
    ],
    darkToggle: 'Dark',
    rtlToggle: 'Arabic, right to left',
    textToggle: 'Text 130%',
    seeTutorial: 'See the tutorial',
    retake: 'Retake photo',
    skip: 'Skip',
    deleteHistory: 'Delete history',
    saving: 'Saving',
    scan: 'Scan an item',
    chooseFromGallery: 'Choose from gallery',
    share: 'Share',
    readAloud: 'Read aloud',
    flash: 'Flash',
    close: 'Close',
    materials: {
      'glass': 'Glass',
      'plastic': 'Plastic',
      'paper': 'Paper & cardboard',
      'metal': 'Metal',
      'textile': 'Textile',
      'wood': 'Wood',
      'electronics': 'Electronics',
      'hazardous': 'Hazardous',
      'organic': 'Organic',
      'other': 'Other',
    },
    tabs: ['Upcycle', 'Recycle', 'Donate'],
    material: 'Material',
    type: 'Type',
    quantity: 'Qty',
    quality: 'Quality',
    state: 'State',
    recyclable: 'Recyclable',
    confidence: 'Confidence',
    correctItem: 'Correct this item',
    photoSemantics: 'Your photo, 2 items found',
    jar: GallerySpecimen(
      name: 'Glass jam jar',
      material: 'Clear soda-lime glass',
      quantity: '1 pc',
      quality: 'Good',
      qualitySemantics: 'Quality 4 of 5, good',
      recyclable: 'Yes · glass bottle bank',
      confidence: '93%',
      note: 'No chips or cracks; label residue on one side.',
      states: ['Empty', 'Label on', 'Lid on', 'Intact'],
      boxLabel: 'Jar · 93%',
    ),
    lid: GallerySpecimen(
      name: 'Metal jar lid',
      material: 'Tin-plated steel with plastic liner',
      quantity: '1 pc',
      quality: 'Good',
      qualitySemantics: 'Quality 4 of 5, good',
      recyclable: 'Yes · metal recycling (cans)',
      confidence: '81%',
      note: 'Slight scratches, no rust.',
      states: ['Clean', 'Intact'],
      boxLabel: 'Lid · 81%',
    ),
    battery: GallerySpecimen(
      name: 'AA alkaline batteries',
      material: 'Alkaline cell (zinc / manganese dioxide)',
      quantity: '4 pcs',
      quality: 'Worn',
      qualitySemantics: 'Quality 2 of 5, worn',
      recyclable: 'Only at a battery collection point',
      confidence: '96%',
      note: 'Used; one shows light corrosion at the terminal.',
      states: ['Worn', 'Dirty'],
      boxLabel: 'Batteries · 96%',
    ),
    batteryHazard: 'Battery. Take it to a collection point; no DIY.',
    stages: [
      'Identifying materials',
      'Checking safety and finding ideas',
      'Locating drop-off points',
      'Rendering makeovers',
    ],
    stageTimes: ['4.4 s', '6.6 s', '1.2 s'],
    pipelineSummary: 'Done in 12.2 s · 3 ideas · 3 places',
    showSteps: 'Show steps',
    hideSteps: 'Hide steps',
    imagesPaused:
        'Image generation is paused on this server. Ideas and tutorials '
        'still work.',
    noDiyIdeas:
        'Batteries go to a collection point, so there are no DIY ideas.',
    noMakeovers: 'Nothing to render without an idea.',
    ideas: [
      GalleryIdea(
        title: 'Hanging jar lantern',
        pitch:
            'A warm tea-light lantern with a twine handle, for the balcony '
            'or a dinner table.',
        meta: ['Easy', '35 min'],
        toolMatch: 'You have 3 of 4 tools',
        have: 3,
        total: 4,
      ),
      GalleryIdea(
        title: 'Kitchen herb jar',
        pitch:
            'Grow basil or mint on the windowsill, with a pebble layer for '
            'drainage.',
        meta: ['Easy', '25 min'],
        toolMatch: 'You have every tool',
        have: 1,
        total: 1,
      ),
      GalleryIdea(
        title: 'Painted desk organizer',
        pitch:
            'Frosted paint and a twine band turn it into a pen and brush '
            'holder.',
        meta: ['Medium', '60 min'],
        toolMatch: 'You have 1 of 4 tools',
        have: 1,
        total: 4,
      ),
    ],
    rendering: 'Rendering the makeover',
    previewUnavailable: 'Preview unavailable',
    before: 'Before',
    after: 'After',
    compare: 'Compare before and after',
    sourcesTitle: 'Sources',
    sources: ['Jar lantern project', 'Glass safety', 'Glass: identification'],
    tipTitle: 'Tip',
    carefulTitle: 'Careful',
    safetyTitle: 'Safety',
    tip: 'A little cooking oil lifts stubborn glue.',
    careful: 'Wire ends are sharp: tuck them flat against the glass.',
    safety: 'Wear work gloves when bending wire.',
    stepOf: 'Step 2 of 5',
    stepTime: '5 min',
    stepTitle: 'Wrap the wire collar',
    stepInstruction:
        'Wrap craft wire twice around the groove under the rim and twist '
        'the ends together with pliers until it does not slide.',
    places: [
      GalleryPlace(
        name: 'Glass collection point',
        address: 'Al Khalidiyah',
        type: 'Collection point',
        distance: '950 m',
        openLabel: 'Hours not listed',
        open: null,
        materials: ['glass', 'paper', 'plastic'],
      ),
      GalleryPlace(
        name: 'Municipal recycling centre',
        address: 'Mussafah Industrial Area',
        type: 'Recycling center',
        distance: '2.7 km',
        openLabel: 'Open now',
        open: true,
        materials: ['glass', 'metal'],
      ),
      GalleryPlace(
        name: 'Community donation box',
        address: 'Al Bateen',
        type: 'Donation',
        distance: '3.4 km',
        openLabel: 'Closed',
        open: false,
        materials: ['textile'],
      ),
    ],
    directions: 'Directions',
    insteadOf: 'Instead of',
    tryThis: 'Try',
    tipLabel: 'Tip',
    swaps: [
      GallerySwap(
        from: 'Single-use plastic bags',
        to: 'A folding cotton or canvas tote',
        why:
            'One tote replaces hundreds of thin bags that tear quickly and '
            'end up as litter.',
        tip:
            'Keep one folded in your car and one clipped to your keys so it '
            'is there when you shop.',
        meta: ['Effort: low', 'Cost: low'],
      ),
      GallerySwap(
        from: 'Bottled water',
        to: 'A filter jug and a steel bottle',
        why:
            'You scanned mostly plastic bottles; refilling one bottle '
            'removes that stream.',
        tip: 'Fill the bottle the night before and keep it by your keys.',
        meta: ['Effort: low', 'Cost: medium'],
        badge: 'From your scans',
      ),
    ],
    emptyTitle: 'No scans yet',
    emptyMessage:
        'Photograph something you are about to throw away. Kanz tells you '
        'what it is made of and what it could become.',
    errorTitle: 'Kanz is busy',
    errorMessage:
        'The AI service is busy right now. Please try again in a moment.',
    tryAgain: 'Try again',
    errorCode: 'ai_unavailable · req_5f3c2a1b',
    offline: 'You are offline. Saved scans still open.',
    camera: GalleryRationale(
      title: 'Show Kanz the thing you want to part with',
      reasons: [
        'Point the camera at any item to identify its materials.',
        'Boxes on your photo show exactly what was recognised.',
        'Prefer not to? Pick a photo from your gallery instead.',
      ],
      allow: 'Allow camera',
      alternative: 'Choose from gallery',
      footnote: 'You can change this later in Settings.',
    ),
    location: GalleryRationale(
      title: 'Find drop-off points near you',
      reasons: [
        'Recycling and donation points are sorted by distance.',
        'Hazardous items are matched to places that accept them.',
        'Prefer not to share? Pick your city instead.',
      ],
      allow: 'Allow location',
      alternative: 'Pick my city',
      footnote: 'You can change this later in Settings.',
    ),
    itemsSaved: '12',
    itemsSavedLabel: 'Items kept out of the bin',
    projectsDone: '5',
    projectsDoneLabel: 'Projects finished',
    materialCounts: {
      'glass': '7 items',
      'plastic': '4 items',
      'paper': '3 items',
      'metal': '2 items',
      'textile': '1 item',
    },
    nav: ['Home', 'Drop-off', 'Swaps', 'Impact'],
    fieldLabel: 'Describe the item',
    fieldHint: 'A pile of old denim jeans',
    fieldHelper: 'Materials and condition help the most.',
    languageSetting: 'Language',
    languageValue: 'English',
    toolsSetting: 'My tools',
    toolsDetail: 'Scissors, pliers, twine and 4 more',
    handsFree: 'Hands-free mode',
    handsFreeDetail: 'Reads each step aloud and listens for "next".',
    sheetTitle: 'Correct this item',
    sheetSubtitle: 'Kanz will redo the ideas with your changes.',
  );

  static const GallerySamples ar = GallerySamples(
    title: 'معرض التصميم',
    sections: [
      'الأساسيات',
      'عناصر التحكم',
      'التعرّف',
      'التوصيات',
      'الدرس',
      'التسليم والبدائل',
      'الحالات',
      'التنقل والهوية',
    ],
    darkToggle: 'داكن',
    rtlToggle: 'العربية، من اليمين لليسار',
    textToggle: 'نص 130%',
    seeTutorial: 'اعرض الدرس',
    retake: 'أعد التصوير',
    skip: 'تخطَّ',
    deleteHistory: 'احذف السجل',
    saving: 'جارٍ الحفظ',
    scan: 'صوّر غرضًا',
    chooseFromGallery: 'اختر من المعرض',
    share: 'مشاركة',
    readAloud: 'اقرأ بصوت عالٍ',
    flash: 'الفلاش',
    close: 'إغلاق',
    materials: {
      'glass': 'زجاج',
      'plastic': 'بلاستيك',
      'paper': 'ورق وكرتون',
      'metal': 'معدن',
      'textile': 'نسيج',
      'wood': 'خشب',
      'electronics': 'إلكترونيات',
      'hazardous': 'خطرة',
      'organic': 'عضوي',
      'other': 'أخرى',
    },
    tabs: ['ابتكار', 'تدوير', 'تبرّع'],
    material: 'المادة',
    type: 'النوع',
    quantity: 'الكمية',
    quality: 'الجودة',
    state: 'الحالة',
    recyclable: 'قابل للتدوير',
    confidence: 'الثقة',
    correctItem: 'صحّح هذا الغرض',
    photoSemantics: 'صورتك، تم العثور على غرضين',
    jar: GallerySpecimen(
      name: 'برطمان مربى زجاجي',
      material: 'زجاج شفاف (صودا-جير)',
      quantity: 'قطعة واحدة',
      quality: 'جيد',
      qualitySemantics: 'الجودة 4 من 5، جيد',
      recyclable: 'نعم · حاوية الزجاج',
      confidence: '93%',
      note: 'لا شقوق ولا كسور، وبقايا ملصق على جانب واحد.',
      states: ['فارغ', 'بالملصق', 'بالغطاء', 'سليم'],
      boxLabel: 'برطمان · 93%',
    ),
    lid: GallerySpecimen(
      name: 'غطاء برطمان معدني',
      material: 'فولاذ مطلي بالقصدير مع بطانة بلاستيكية',
      quantity: 'قطعة واحدة',
      quality: 'جيد',
      qualitySemantics: 'الجودة 4 من 5، جيد',
      recyclable: 'نعم · تدوير المعادن (العلب)',
      confidence: '81%',
      note: 'خدوش خفيفة، بلا صدأ.',
      states: ['نظيف', 'سليم'],
      boxLabel: 'غطاء · 81%',
    ),
    battery: GallerySpecimen(
      name: 'بطاريات قلوية AA',
      material: 'خلية قلوية (زنك / ثاني أكسيد المنغنيز)',
      quantity: '4 قطع',
      quality: 'مستهلك',
      qualitySemantics: 'الجودة 2 من 5، مستهلك',
      recyclable: 'فقط في نقطة جمع البطاريات',
      confidence: '96%',
      note: 'مستعملة، وعلى طرف إحداها آثار تآكل خفيفة.',
      states: ['مهترئ', 'متّسخ'],
      boxLabel: 'بطاريات · 96%',
    ),
    batteryHazard: 'بطارية. سلّمها إلى نقطة جمع، ولا مشاريع يدوية.',
    stages: [
      'التعرّف على المواد',
      'فحص السلامة وإيجاد الأفكار',
      'تحديد نقاط التسليم',
      'رسم صور التحويل',
    ],
    stageTimes: ['4.4 ث', '6.6 ث', '1.2 ث'],
    pipelineSummary: 'اكتمل في 12.2 ث · 3 أفكار · 3 أماكن',
    showSteps: 'اعرض المراحل',
    hideSteps: 'أخفِ المراحل',
    imagesPaused:
        'توليد الصور متوقف على هذا الخادم. الأفكار والدروس تعمل كالمعتاد.',
    noDiyIdeas: 'البطاريات تُسلَّم إلى نقطة جمع، لذا لا توجد أفكار يدوية.',
    noMakeovers: 'لا صور تحويل دون فكرة.',
    ideas: [
      GalleryIdea(
        title: 'فانوس برطمان معلّق',
        pitch: 'فانوس دافئ بشمعة صغيرة ومقبض من الخيط، للشرفة أو مائدة العشاء.',
        meta: ['سهل', '35 د'],
        toolMatch: 'لديك 3 من 4 أدوات',
        have: 3,
        total: 4,
      ),
      GalleryIdea(
        title: 'برطمان أعشاب للمطبخ',
        pitch: 'ازرع الريحان أو النعناع على حافة النافذة مع طبقة حصى للتصريف.',
        meta: ['سهل', '25 د'],
        toolMatch: 'لديك كل الأدوات',
        have: 1,
        total: 1,
      ),
      GalleryIdea(
        title: 'منظّم مكتب مطلي',
        pitch: 'طلاء مطفأ وحزام من الخيط يحوّلانه إلى حامل أقلام وفرش.',
        meta: ['متوسط', '60 د'],
        toolMatch: 'لديك 1 من 4 أدوات',
        have: 1,
        total: 4,
      ),
    ],
    rendering: 'جارٍ رسم التحويل',
    previewUnavailable: 'المعاينة غير متاحة',
    before: 'قبل',
    after: 'بعد',
    compare: 'قارن بين قبل وبعد',
    sourcesTitle: 'المصادر',
    sources: [
      'مشروع فانوس البرطمان',
      'سلامة التعامل مع الزجاج',
      'الزجاج: التعرّف والتحضير',
    ],
    tipTitle: 'نصيحة',
    carefulTitle: 'انتبه',
    safetyTitle: 'السلامة',
    tip: 'قليل من زيت الطبخ يزيل الغراء العنيد.',
    careful: 'أطراف السلك حادة: اثنها لتلتصق بالزجاج.',
    safety: 'ارتدِ قفازات العمل عند ثني السلك.',
    stepOf: 'الخطوة 2 من 5',
    stepTime: '5 د',
    stepTitle: 'لفّ طوق السلك',
    stepInstruction:
        'لفّ السلك مرتين حول التجويف أسفل الحافة واجدل طرفيه بالكماشة '
        'حتى لا ينزلق.',
    places: [
      GalleryPlace(
        name: 'نقطة تجميع الزجاج',
        address: 'الخالدية',
        type: 'نقطة تجميع',
        distance: '950 م',
        openLabel: 'المواعيد غير مذكورة',
        open: null,
        materials: ['glass', 'paper', 'plastic'],
      ),
      GalleryPlace(
        name: 'مركز إعادة التدوير البلدي',
        address: 'المنطقة الصناعية في مصفح',
        type: 'مركز إعادة تدوير',
        distance: '2.7 كم',
        openLabel: 'مفتوح الآن',
        open: true,
        materials: ['glass', 'metal'],
      ),
      GalleryPlace(
        name: 'صندوق تبرعات الحي',
        address: 'البطين',
        type: 'تبرّع',
        distance: '3.4 كم',
        openLabel: 'مغلق',
        open: false,
        materials: ['textile'],
      ),
    ],
    directions: 'الاتجاهات',
    insteadOf: 'بدلًا من',
    tryThis: 'جرّب',
    tipLabel: 'نصيحة',
    swaps: [
      GallerySwap(
        from: 'الأكياس البلاستيكية أحادية الاستخدام',
        to: 'حقيبة قماشية قابلة للطي',
        why:
            'حقيبة واحدة تغني عن مئات الأكياس الرقيقة التي تتمزق بسرعة '
            'وينتهي بها الأمر في الشوارع.',
        tip: 'احتفظ بواحدة مطوية في السيارة وأخرى مع مفاتيحك.',
        meta: ['الجهد: قليل', 'التكلفة: منخفضة'],
      ),
      GallerySwap(
        from: 'المياه المعبأة',
        to: 'إبريق بفلتر وقارورة من الفولاذ',
        why:
            'معظم ما صوّرته قوارير بلاستيكية؛ إعادة تعبئة قارورة واحدة '
            'توقف هذا المصدر.',
        tip: 'املأ القارورة في الليلة السابقة وضعها قرب مفاتيحك.',
        meta: ['الجهد: قليل', 'التكلفة: متوسطة'],
        badge: 'من صورك السابقة',
      ),
    ],
    emptyTitle: 'لا صور بعد',
    emptyMessage:
        'صوّر شيئًا كنت ستتخلص منه، وسيخبرك كنز ممّ صُنع وما الذي يمكن '
        'أن يصبح.',
    errorTitle: 'كنز مشغول',
    errorMessage: 'خدمة الذكاء الاصطناعي مشغولة الآن. حاول مرة أخرى بعد لحظات.',
    tryAgain: 'حاول مجددًا',
    errorCode: 'ai_unavailable · req_5f3c2a1b',
    offline: 'أنت غير متصل. الصور المحفوظة ما زالت متاحة.',
    camera: GalleryRationale(
      title: 'أرِ كنز الشيء الذي تريد التخلص منه',
      reasons: [
        'وجّه الكاميرا نحو أي غرض للتعرّف على مواده.',
        'تُظهر المربعات على صورتك ما تم التعرّف عليه بالضبط.',
        'لا تفضّل ذلك؟ اختر صورة من المعرض.',
      ],
      allow: 'اسمح بالكاميرا',
      alternative: 'اختر من المعرض',
      footnote: 'يمكنك تغيير ذلك لاحقًا من الإعدادات.',
    ),
    location: GalleryRationale(
      title: 'اعثر على نقاط التسليم القريبة',
      reasons: [
        'نقاط التدوير والتبرع مرتبة حسب المسافة.',
        'الأغراض الخطرة تُطابق مع الأماكن التي تقبلها.',
        'لا تريد المشاركة؟ اختر مدينتك بدلًا من ذلك.',
      ],
      allow: 'اسمح بالموقع',
      alternative: 'اختر مدينتي',
      footnote: 'يمكنك تغيير ذلك لاحقًا من الإعدادات.',
    ),
    itemsSaved: '12',
    itemsSavedLabel: 'غرضًا أُنقذ من سلة المهملات',
    projectsDone: '5',
    projectsDoneLabel: 'مشاريع مكتملة',
    materialCounts: {
      'glass': '7 أغراض',
      'plastic': '4 أغراض',
      'paper': '3 أغراض',
      'metal': 'غرضان',
      'textile': 'غرض واحد',
    },
    nav: ['الرئيسية', 'التسليم', 'البدائل', 'الأثر'],
    fieldLabel: 'صف الغرض',
    fieldHint: 'كومة من سراويل الجينز القديمة',
    fieldHelper: 'المواد والحالة هما الأهم.',
    languageSetting: 'اللغة',
    languageValue: 'العربية',
    toolsSetting: 'أدواتي',
    toolsDetail: 'مقص وكماشة وخيط و4 أخرى',
    handsFree: 'وضع بلا لمس',
    handsFreeDetail: 'يقرأ كل خطوة بصوت عالٍ وينتظر كلمة "التالي".',
    sheetTitle: 'صحّح هذا الغرض',
    sheetSubtitle: 'سيعيد كنز الأفكار وفق تعديلاتك.',
  );
}
