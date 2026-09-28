// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAppName => 'Kanz';

  @override
  String get commonBack => 'Back';

  @override
  String get commonBackendChecking => 'Checking the connection';

  @override
  String get commonBackendOffline => 'Offline';

  @override
  String get commonBackendOnline => 'Connected';

  @override
  String get commonBackendUnreachable => 'Server not reachable';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCo2eDisclaimer => 'Rough estimate from average factors.';

  @override
  String commonCo2eKg(String kg) {
    return '$kg kg CO₂e';
  }

  @override
  String get commonContinue => 'Continue';

  @override
  String commonDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get commonDifficultyEasy => 'Easy';

  @override
  String get commonDifficultyHard => 'Hard';

  @override
  String get commonDifficultyMedium => 'Medium';

  @override
  String commonDistanceKm(String km) {
    return '$km km';
  }

  @override
  String commonDistanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get commonErrorAiInvalidOutput =>
      'The AI\'s answer didn\'t make sense this time. Try again.';

  @override
  String get commonErrorAiQuotaExhausted =>
      'The AI quota on this server is used up for now.';

  @override
  String get commonErrorAiTimeout =>
      'The AI took too long to answer. Try again.';

  @override
  String get commonErrorAiUnavailable =>
      'The AI service is busy right now. Try again in a moment.';

  @override
  String get commonErrorBadRequest =>
      'Something in that request was off. Please try again.';

  @override
  String get commonErrorBadResponse =>
      'The server sent an answer Kanz didn\'t expect. Try again.';

  @override
  String get commonErrorCancelled => 'Cancelled.';

  @override
  String get commonErrorGeneric => 'Kanz hit an unexpected error.';

  @override
  String get commonErrorImageInvalid =>
      'That file isn\'t a photo Kanz can read. Try another one.';

  @override
  String get commonErrorImageTooLarge =>
      'That photo is too large. Try a smaller one.';

  @override
  String get commonErrorInternal =>
      'Something went wrong on our side. Try again.';

  @override
  String get commonErrorInterrupted =>
      'This step didn\'t finish last time. Try again.';

  @override
  String get commonErrorNotFound => 'Kanz can\'t find that anymore.';

  @override
  String get commonErrorOffline =>
      'No connection. Saved scans and tutorials still open.';

  @override
  String get commonErrorPlacesUnavailable =>
      'The map services didn\'t answer. Ideas and tutorials still work.';

  @override
  String get commonErrorRateLimited =>
      'Lots of requests at once. Wait a moment, then try again.';

  @override
  String get commonErrorTimeout =>
      'This is taking too long. Check your connection and try again.';

  @override
  String commonHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get commonJustNow => 'Just now';

  @override
  String get commonLanguageArabic => 'العربية';

  @override
  String get commonLanguageEnglish => 'English';

  @override
  String get commonLanguageSystem => 'Phone language';

  @override
  String get commonLevelHigh => 'High';

  @override
  String get commonLevelLow => 'Low';

  @override
  String get commonLevelMedium => 'Medium';

  @override
  String get commonLoading => 'Loading';

  @override
  String commonMinutes(int count) {
    return '$count min';
  }

  @override
  String commonMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String get commonNext => 'Next';

  @override
  String get commonOk => 'OK';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonPhotoBlurry => 'The photo is blurry';

  @override
  String get commonPhotoCluttered => 'Too many things in the frame';

  @override
  String get commonPhotoGlare => 'Glare is hiding the item';

  @override
  String get commonPhotoNoItems => 'No items found in the photo';

  @override
  String get commonPhotoTooClose => 'The item is too close';

  @override
  String get commonPhotoTooDark => 'The photo is too dark';

  @override
  String get commonPhotoTooFar => 'The item is too far away';

  @override
  String get commonRecyclableConditional => 'Recyclable after prep';

  @override
  String get commonRecyclableNo => 'Not recyclable';

  @override
  String get commonRecyclableYes => 'Recyclable';

  @override
  String get commonRegenerate => 'Try another image';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSkillAdvanced => 'Advanced';

  @override
  String get commonSkillBeginner => 'Beginner';

  @override
  String get commonSkillIntermediate => 'Intermediate';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSpeechCareful => 'Careful';

  @override
  String get commonSpeechTip => 'Tip';

  @override
  String get commonStageDropoff => 'Locating drop-off points';

  @override
  String get commonStageIdeas => 'Checking safety and finding ideas';

  @override
  String get commonStageIdentifying => 'Identifying materials';

  @override
  String get commonStageMakeovers => 'Rendering makeovers';

  @override
  String commonStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String commonStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get commonSupportCode => 'Support code';

  @override
  String get commonThemeDark => 'Dark';

  @override
  String get commonThemeLight => 'Light';

  @override
  String get commonThemeSystem => 'Match phone';

  @override
  String commonWeightKg(String kg) {
    return '$kg kg';
  }

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get completionAddPhoto => 'Add a photo of what you made';

  @override
  String get completionAfter => 'After';

  @override
  String get completionAllTime => 'All time';

  @override
  String get completionBefore => 'Before';

  @override
  String get completionCameraAllow => 'Allow the camera';

  @override
  String get completionCameraBlocked =>
      'The camera is turned off for Kanz in your phone\'s settings. You can choose a photo from your gallery instead.';

  @override
  String get completionCameraDenied =>
      'Allow the camera to photograph your project, or choose a photo you already took.';

  @override
  String get completionCameraNone =>
      'This phone\'s camera couldn\'t be opened. You can choose a photo from your gallery instead.';

  @override
  String get completionCameraTitle => 'The camera isn\'t available';

  @override
  String get completionCaptureGallery => 'Choose from gallery';

  @override
  String get completionCaptureGuidance => 'Photograph what you made';

  @override
  String get completionCaptureShutter => 'Take the photo';

  @override
  String get completionCaptureStarting => 'Opening the camera';

  @override
  String completionCardMadeFrom(String item) {
    return 'Made from $item';
  }

  @override
  String get completionCompare => 'Compare your item before and after';

  @override
  String get completionDescribedLabel => 'You described';

  @override
  String get completionErrorBody =>
      'Your project couldn\'t be read from this phone.';

  @override
  String get completionErrorTitle => 'The project didn\'t load';

  @override
  String get completionEyebrow => 'Project finished';

  @override
  String get completionEyebrowInProgress => 'In progress';

  @override
  String completionFinishedOn(String date) {
    return 'Finished $date';
  }

  @override
  String get completionImpactTitle => 'What this project changed';

  @override
  String get completionItems => 'Items kept out of the bin';

  @override
  String get completionLoading => 'Loading your project';

  @override
  String get completionMadeFrom => 'Made from';

  @override
  String get completionMissingBody =>
      'It may have been deleted with its scan. Your other projects are in History.';

  @override
  String get completionMissingTitle => 'This project isn\'t on this phone';

  @override
  String get completionNoPhoto =>
      'You described this item in words, so there\'s no photo to compare.';

  @override
  String get completionNotFinished => 'This project isn\'t finished yet.';

  @override
  String get completionPhotoFailed => 'Couldn\'t save the photo. Try again.';

  @override
  String get completionPhotoOnly =>
      'The makeover image isn\'t available on this server, so this is your original photo.';

  @override
  String completionProjectItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items kept out of the bin',
      one: 'item kept out of the bin',
    );
    return '$_temp0';
  }

  @override
  String get completionProjects => 'Projects finished';

  @override
  String get completionReplacePhoto => 'Take a new photo';

  @override
  String get completionSavingPhoto => 'Saving your photo';

  @override
  String get completionScanAgain => 'Scan something else';

  @override
  String get completionSeeProjects => 'See my projects';

  @override
  String get completionShare => 'Share before and after';

  @override
  String get completionShareFallback =>
      'Couldn\'t prepare the image, so only the text was shared.';

  @override
  String get completionShareProject => 'Share this project';

  @override
  String completionShareText(String title) {
    return '$title, made from something I nearly threw away. Planned with Kanz.';
  }

  @override
  String get completionSharing => 'Preparing the image';

  @override
  String get completionSkill => 'Skill';

  @override
  String get completionSteps => 'Steps';

  @override
  String completionStepsValue(int done, int total) {
    return '$done of $total';
  }

  @override
  String get completionStreak => 'Days in a row';

  @override
  String completionThisProject(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This project kept $count items out of the bin.',
      one: 'This project kept 1 item out of the bin.',
      zero: 'This project is now in your finished projects.',
    );
    return '$_temp0';
  }

  @override
  String get completionTime => 'Time';

  @override
  String get dropoffAcceptedUnknown =>
      'Accepted materials aren\'t listed. Check the bin labels before you go.';

  @override
  String dropoffAcceptsList(String materials) {
    return 'Accepts $materials';
  }

  @override
  String dropoffApproximate(String city) {
    return 'Your location was approximate, so Kanz is searching around $city.';
  }

  @override
  String get dropoffCall => 'Call';

  @override
  String get dropoffCatalogError => 'Filters didn\'t load.';

  @override
  String get dropoffCategoriesLabel => 'Materials to drop off';

  @override
  String get dropoffChangeLocation => 'Change';

  @override
  String get dropoffChangeLocationHint => 'Change where to search';

  @override
  String get dropoffCities => 'Cities';

  @override
  String get dropoffClosed => 'Closed';

  @override
  String get dropoffDetailAccepts => 'Accepts';

  @override
  String get dropoffDetailAddress => 'Address';

  @override
  String get dropoffDetailDistance => 'Distance';

  @override
  String get dropoffDetailHours => 'Hours';

  @override
  String get dropoffDetailSource => 'Source';

  @override
  String dropoffDirectionOfPlace(String direction, String place) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'n': 'North of $place centre',
      'ne': 'North-east of $place centre',
      'e': 'East of $place centre',
      'se': 'South-east of $place centre',
      's': 'South of $place centre',
      'sw': 'South-west of $place centre',
      'w': 'West of $place centre',
      'nw': 'North-west of $place centre',
      'other': 'Near $place centre',
    });
    return '$_temp0';
  }

  @override
  String dropoffDirectionOfYou(String direction) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'n': 'North of you',
      'ne': 'North-east of you',
      'e': 'East of you',
      'se': 'South-east of you',
      's': 'South of you',
      'sw': 'South-west of you',
      'w': 'West of you',
      'nw': 'North-west of you',
      'other': 'Near you',
    });
    return '$_temp0';
  }

  @override
  String get dropoffDirections => 'Directions';

  @override
  String dropoffDirectionsTo(String name) {
    return 'Directions to $name';
  }

  @override
  String get dropoffEmptyAction => 'Choose another city';

  @override
  String dropoffEmptyMessage(String place) {
    return 'No drop-off points for these materials near $place. Try another city, or add a material above.';
  }

  @override
  String dropoffEmptyTitle(int km) {
    return 'Nothing within $km km';
  }

  @override
  String get dropoffErrorTitle => 'Drop-off points didn\'t load';

  @override
  String get dropoffHoursUnknown => 'Hours not listed';

  @override
  String get dropoffLocating => 'Finding where to search';

  @override
  String get dropoffLocationAllow => 'Use my location';

  @override
  String get dropoffLocationBlockedCity =>
      'Or choose a city, and Kanz searches around its centre.';

  @override
  String get dropoffLocationBlockedReason =>
      'Turn it on in your phone\'s settings to sort places by distance from you.';

  @override
  String get dropoffLocationBlockedSnack =>
      'Location is off for Kanz. Turn it on in your phone\'s settings.';

  @override
  String get dropoffLocationBlockedTitle => 'Location is off for Kanz';

  @override
  String get dropoffLocationDenied =>
      'Location wasn\'t allowed. You can choose a city instead.';

  @override
  String get dropoffLocationFootnote =>
      'You can change this at any time from the top of this tab.';

  @override
  String get dropoffLocationPickCity => 'Choose a city';

  @override
  String get dropoffLocationReasonDistance =>
      'Places are sorted by how far they are from you.';

  @override
  String get dropoffLocationReasonHazard =>
      'Batteries and electronics go to places that take them.';

  @override
  String dropoffLocationSheetSubtitle(int km) {
    return 'Kanz lists drop-off points within $km km.';
  }

  @override
  String get dropoffLocationSheetTitle => 'Search near';

  @override
  String get dropoffLocationTitle => 'Find drop-off points near you';

  @override
  String dropoffNearCity(String city) {
    return 'Near $city';
  }

  @override
  String get dropoffNearYou => 'Near you';

  @override
  String get dropoffNoCategoryMessage =>
      'Choose at least one material above to see drop-off points near you.';

  @override
  String get dropoffNoCategoryTitle => 'Pick a material';

  @override
  String get dropoffOfflineTitle => 'Drop-off points need a connection';

  @override
  String get dropoffOpenFailed => 'Couldn\'t open that. Try again.';

  @override
  String get dropoffOpenNow => 'Open now';

  @override
  String dropoffPlaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String dropoffPlotCentreOf(String city) {
    return '$city centre';
  }

  @override
  String dropoffPlotLabel(int count, String place, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count drop-off points around $place. The nearest is $distance away.',
      one: '1 drop-off point around $place, $distance away.',
    );
    return '$_temp0';
  }

  @override
  String get dropoffPlotListed => 'Materials listed';

  @override
  String get dropoffPlotNorth => 'N';

  @override
  String dropoffPlotRings(String distance) {
    return 'Rings every $distance';
  }

  @override
  String get dropoffPlotUnlisted => 'Not listed';

  @override
  String get dropoffPlotYou => 'Your location';

  @override
  String get dropoffSearching => 'Looking for drop-off points';

  @override
  String dropoffSearchingNear(String place) {
    return 'Searching near $place';
  }

  @override
  String get dropoffSearchingNearYou => 'Searching near you';

  @override
  String get dropoffSourceCurated => 'Kanz list, checked by the team';

  @override
  String get dropoffSourceGoogle => 'Google Maps';

  @override
  String get dropoffSourceOsm => '© OpenStreetMap contributors';

  @override
  String get dropoffSourcesLabel => 'Sources';

  @override
  String get dropoffTitle => 'Drop-off';

  @override
  String get dropoffTypeAll => 'All types';

  @override
  String dropoffTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count types',
      one: '1 type',
    );
    return '$_temp0';
  }

  @override
  String get dropoffTypeEmptyMessage =>
      'Places were found nearby, but none match the type you picked.';

  @override
  String get dropoffTypeEmptyTitle => 'No places of this type';

  @override
  String get dropoffTypeFilterHint => 'Filter by type of place';

  @override
  String get dropoffTypeSheetSubtitle =>
      'Show only the kinds of places you want to visit.';

  @override
  String get dropoffTypeSheetTitle => 'Type of place';

  @override
  String get dropoffTypeShowAll => 'Show all types';

  @override
  String get dropoffUseMyLocation => 'Use my location';

  @override
  String get dropoffUseMyLocationDetail =>
      'Sorts places by distance from where you are';

  @override
  String get dropoffViewList => 'List';

  @override
  String get dropoffViewMap => 'Map';

  @override
  String get dropoffWebsite => 'Website';

  @override
  String dropoffWithinKm(int km) {
    return 'within $km km';
  }

  @override
  String get historyDelete => 'Delete scan';

  @override
  String get historyDeleteBody =>
      'Its photo, ideas and projects are removed from this phone. Your impact numbers stay.';

  @override
  String get historyDeleteConfirm => 'Delete';

  @override
  String get historyDeleteFailed => 'The scan couldn\'t be deleted. Try again.';

  @override
  String get historyDeleteTitle => 'Delete this scan?';

  @override
  String get historyDeleted => 'Scan deleted';

  @override
  String get historyErrorBody =>
      'Your saved scans and projects couldn\'t be read from this phone.';

  @override
  String get historyErrorTitle => 'History didn\'t load';

  @override
  String get historyFinished => 'Finished';

  @override
  String historyFinishedOn(String date) {
    return 'Finished $date';
  }

  @override
  String get historyInProgress => 'In progress';

  @override
  String get historyLoading => 'Loading your history';

  @override
  String historyMore(String title) {
    return 'More options for $title';
  }

  @override
  String get historyNotStarted => 'Tutorial not opened yet';

  @override
  String get historyOpenScan => 'Open scan';

  @override
  String get historyProjectsEmptyBody =>
      'Pick an upcycling idea from a scan and start its tutorial. Your progress is kept here.';

  @override
  String get historyProjectsEmptyTitle => 'No projects yet';

  @override
  String get historyResume => 'Resume';

  @override
  String get historyScansEmptyBody =>
      'Every item you scan is saved here and opens even without a connection.';

  @override
  String get historyScansEmptyTitle => 'No scans yet';

  @override
  String get historySeeProject => 'See project';

  @override
  String historyStepsDone(int done, int total) {
    return '$done of $total steps done';
  }

  @override
  String get historyTabProjects => 'My projects';

  @override
  String get historyTabScans => 'Scans';

  @override
  String get historyTitle => 'History';

  @override
  String get historyToday => 'Today';

  @override
  String get homeDescribe => 'Describe it';

  @override
  String get homeDescription => 'Description';

  @override
  String get homeErrorMessage =>
      'Your saved scans couldn\'t be read from this phone.';

  @override
  String get homeErrorTitle => 'Your scans didn\'t load';

  @override
  String get homeGallery => 'From gallery';

  @override
  String get homeGuideEyebrow => 'What to photograph';

  @override
  String get homeGuideGlass => 'Jars and bottles';

  @override
  String get homeGuideHazardous =>
      'Batteries and old phones. Kanz shows where to take them safely.';

  @override
  String get homeGuideMetal => 'Tins and drink cans';

  @override
  String get homeGuidePaper => 'Cardboard boxes and newspapers';

  @override
  String get homeGuideTextile => 'T-shirts, jeans and fabric scraps';

  @override
  String get homeGuideTitle =>
      'Start with something from your kitchen or wardrobe.';

  @override
  String get homeHeadline => 'What are you about to throw away?';

  @override
  String get homeHistory => 'History';

  @override
  String homeImpactItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items out of the bin',
      one: 'item out of the bin',
    );
    return '$_temp0';
  }

  @override
  String get homeImpactOpen => 'See your impact';

  @override
  String homeImpactProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'projects finished',
      one: 'project finished',
    );
    return '$_temp0';
  }

  @override
  String homeImpactStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days in a row',
      one: 'day in a row',
    );
    return '$_temp0';
  }

  @override
  String get homeImpactTitle => 'Your impact';

  @override
  String homeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get homeLead =>
      'Photograph it and Kanz shows what it\'s made of and what it could become.';

  @override
  String get homeLoadingRecent => 'Loading your recent scans';

  @override
  String get homeRecentTitle => 'Recent scans';

  @override
  String get homeResume => 'Resume';

  @override
  String get homeResumeEyebrow => 'Continue your project';

  @override
  String get homeResumeNotStarted => 'Tutorial not opened yet';

  @override
  String homeResumeProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get homeScan => 'Scan an item';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeTip1 => 'One item at a time, filling most of the frame.';

  @override
  String get homeTip2 => 'A plain background and even light.';

  @override
  String get homeTip3 => 'Show labels or recycling marks if it has any.';

  @override
  String get homeTipsTitle => 'For a clear photo';

  @override
  String get homeUnfinishedScan => 'Unfinished scan';

  @override
  String get ideaAfter => 'After';

  @override
  String get ideaBackToResults => 'Back to results';

  @override
  String get ideaBasedOn => 'Based on';

  @override
  String get ideaBefore => 'Before';

  @override
  String get ideaCompare => 'Compare before and after';

  @override
  String get ideaDifficulty => 'Difficulty';

  @override
  String get ideaDragHint => 'Drag to compare';

  @override
  String ideaEyebrow(int index, int total) {
    return 'Idea $index of $total';
  }

  @override
  String get ideaFromDescription => 'From your description';

  @override
  String get ideaImageFailed => 'Makeover didn\'t render';

  @override
  String get ideaImagePaused => 'Makeover images paused';

  @override
  String get ideaMaterialsTitle => 'Also needed';

  @override
  String get ideaMissingBody =>
      'The ideas for this scan changed. Go back to see the current ones.';

  @override
  String get ideaMissingTitle => 'This idea isn\'t available anymore';

  @override
  String get ideaNoTools => 'No tools needed, just your hands.';

  @override
  String get ideaRendering => 'Rendering the makeover';

  @override
  String get ideaSafety => 'Safety';

  @override
  String get ideaSeeTutorial => 'See the tutorial';

  @override
  String get ideaTime => 'Time';

  @override
  String get ideaToolHave => 'You have it';

  @override
  String get ideaToolMissing => 'You\'ll need it';

  @override
  String get ideaTools => 'Tools';

  @override
  String get ideaToolsTitle => 'Tools needed';

  @override
  String get impactActiveToday => 'Active today';

  @override
  String get impactByMaterial => 'By material';

  @override
  String get impactByPath => 'Where they went';

  @override
  String get impactCo2Label => 'Emissions avoided';

  @override
  String get impactEmptyMessage =>
      'Scan something you\'re about to throw away, then upcycle, recycle or donate it. Each item you mark shows up here.';

  @override
  String get impactEmptyTitle => 'Your impact starts with one scan';

  @override
  String get impactErrorTitle => 'Your impact didn\'t load';

  @override
  String get impactEstimateLabel => 'Estimate';

  @override
  String get impactHowItems =>
      'Items you mark as recycled, donated or disposed of safely from a scan\'s results.';

  @override
  String get impactHowProjects =>
      'Upcycling projects you finish, step by step.';

  @override
  String get impactHowStreak =>
      'Days in a row with a scan, a marked item or a finished project.';

  @override
  String get impactHowTitle => 'What counts here';

  @override
  String get impactIntro =>
      'Counted from what you scanned and marked on this phone.';

  @override
  String impactItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get impactItemsLabel => 'Items kept out of the bin';

  @override
  String get impactKeepStreak =>
      'Scan or mark one thing today so your streak keeps going.';

  @override
  String get impactKindDisposed => 'Disposed of safely';

  @override
  String get impactKindDonated => 'Donated';

  @override
  String get impactKindRecycled => 'Recycled';

  @override
  String get impactKindUpcycled => 'Upcycled';

  @override
  String get impactLoading => 'Adding up your impact';

  @override
  String get impactMassLabel => 'Material kept from landfill';

  @override
  String get impactNoItemsYet =>
      'Nothing marked yet. Open a scan\'s results and mark an item as recycled, donated or upcycled to count it here.';

  @override
  String get impactProjectsLabel => 'Projects finished';

  @override
  String get impactScanAction => 'Scan an item';

  @override
  String get impactStartStreak => 'Scan something today to start a new streak.';

  @override
  String get impactStreakLabel => 'Day streak';

  @override
  String get impactTitle => 'Your impact';

  @override
  String get onboardingChangeLater => 'You can change this later in Settings.';

  @override
  String get onboardingFinish => 'Start using Kanz';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingLanguageArabicSample =>
      'الأفكار والدروس والصوت بالعربية.';

  @override
  String get onboardingLanguageBody =>
      'Menus, ideas, tutorials and spoken steps all follow it.';

  @override
  String get onboardingLanguageEnglishSample =>
      'Ideas, tutorials and voice in English.';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingSkillAdvancedLine =>
      'You measure, saw, sew and finish with care.';

  @override
  String get onboardingSkillBeginnerLine =>
      'Cutting, gluing and painting. No power tools.';

  @override
  String get onboardingSkillBody =>
      'Tutorials match your level. Beginners get simpler steps and more detail.';

  @override
  String get onboardingSkillIntermediateLine =>
      'Comfortable with a drill, sandpaper and a needle.';

  @override
  String onboardingSkillLevel(int level) {
    return 'Level $level of 3';
  }

  @override
  String get onboardingSkillTitle => 'How handy are you?';

  @override
  String get onboardingToolGroupBuilding => 'Drilling and fixing';

  @override
  String onboardingToolGroupCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get onboardingToolGroupCutting => 'Cutting';

  @override
  String get onboardingToolGroupFinishing => 'Sanding and painting';

  @override
  String get onboardingToolGroupJoining => 'Gluing and fastening';

  @override
  String get onboardingToolGroupMeasuring => 'Measuring';

  @override
  String get onboardingToolGroupOther => 'Other tools';

  @override
  String get onboardingToolGroupSewing => 'Sewing';

  @override
  String get onboardingToolsBody =>
      'Ideas and tutorials use only these. Safety gear is always listed.';

  @override
  String onboardingToolsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tools selected',
      one: '1 tool selected',
      zero: 'No tools selected',
    );
    return '$_temp0';
  }

  @override
  String get onboardingToolsNone =>
      'No tools? That\'s fine. Ideas that need none come first.';

  @override
  String get onboardingToolsTitle => 'Which tools do you have?';

  @override
  String get onboardingWelcomeBody =>
      'Photograph something you\'re about to throw away and Kanz tells you what it\'s made of and what to do with it.';

  @override
  String get onboardingWelcomeStep1Body =>
      'Materials, condition and quantity from one photo.';

  @override
  String get onboardingWelcomeStep1Title => 'Photograph an item';

  @override
  String get onboardingWelcomeStep2Body =>
      'Upcycle it with a step-by-step tutorial, recycle it or donate it.';

  @override
  String get onboardingWelcomeStep2Title => 'Choose a path';

  @override
  String get onboardingWelcomeStep3Body =>
      'Recycling and donation points near you.';

  @override
  String get onboardingWelcomeStep3Title => 'Drop it off';

  @override
  String get onboardingWelcomeTitle =>
      'Find the treasure in what you throw away.';

  @override
  String get permissionsAsking => 'Waiting for your answer';

  @override
  String get permissionsCameraAllow => 'Allow camera';

  @override
  String get permissionsCameraBlocked =>
      'The camera is turned off for Kanz in your phone\'s settings. Turn it on there, or pick a photo from your gallery.';

  @override
  String get permissionsCameraDenied =>
      'The camera wasn\'t allowed. Ask again, or pick a photo from your gallery.';

  @override
  String get permissionsCameraGallery => 'Pick from gallery instead';

  @override
  String get permissionsCameraReason1 =>
      'Point the camera at an item and Kanz names its materials and condition.';

  @override
  String get permissionsCameraReason2 =>
      'Only the photo you take is sent for analysis, with its location data removed.';

  @override
  String get permissionsCameraReason3 =>
      'Rather not? Pick a photo from your gallery instead.';

  @override
  String get permissionsCameraRestricted =>
      'The camera can\'t be turned on for Kanz on this phone. Pick a photo from your gallery instead.';

  @override
  String get permissionsCameraTitle =>
      'Show Kanz what you\'re about to throw away';

  @override
  String get permissionsCityBody =>
      'Kanz looks for drop-off points around the city centre. You can change it any time in Settings.';

  @override
  String get permissionsCityEyebrow => 'Emirates';

  @override
  String get permissionsCitySelected => 'Selected';

  @override
  String get permissionsCityTitle => 'Choose your city';

  @override
  String get permissionsCityUseLocation => 'Use my location instead';

  @override
  String get permissionsCityUseLocationDetail =>
      'More precise: points sorted by distance from you';

  @override
  String get permissionsFootnote => 'You can change this any time in Settings.';

  @override
  String get permissionsLocationAllow => 'Use my location';

  @override
  String get permissionsLocationBlocked =>
      'Location is turned off for Kanz in your phone\'s settings. Turn it on there, or choose a city.';

  @override
  String get permissionsLocationCity => 'Choose a city instead';

  @override
  String get permissionsLocationDenied =>
      'Location wasn\'t allowed. Ask again, or choose a city.';

  @override
  String get permissionsLocationReason1 =>
      'Recycling and donation points are sorted by distance from you.';

  @override
  String get permissionsLocationReason2 =>
      'Kanz reads your position only when it searches for drop-off points.';

  @override
  String get permissionsLocationReason3 =>
      'Rather not? Choose your city and Kanz searches around its centre.';

  @override
  String get permissionsLocationRestricted =>
      'Location can\'t be turned on for Kanz on this phone. Choose a city instead.';

  @override
  String get permissionsLocationTitle => 'Find drop-off points near you';

  @override
  String get permissionsNotAllowed => 'Not allowed';

  @override
  String get permissionsTurnedOff => 'Turned off in Settings';

  @override
  String get permissionsUnavailable => 'Not available on this phone';

  @override
  String resultsAccepts(String materials) {
    return 'Accepts $materials';
  }

  @override
  String resultsAroundCity(String city) {
    return 'Around $city, since your location was approximate';
  }

  @override
  String resultsAttribution(String sources) {
    return 'Places from $sources';
  }

  @override
  String get resultsBasedOn => 'Based on';

  @override
  String get resultsBeforeYouGo => 'Before you go';

  @override
  String resultsBoxSemantics(String name, String category, String confidence) {
    return '$name, $category, $confidence confidence';
  }

  @override
  String get resultsCheckAgain => 'Retry';

  @override
  String get resultsChecking => 'Checking the connection';

  @override
  String get resultsChooseCity => 'Choose a city';

  @override
  String get resultsChooseFromGallery => 'Choose from gallery';

  @override
  String get resultsClosedNow => 'Closed now';

  @override
  String get resultsCorrectedNote => 'Corrected by you.';

  @override
  String get resultsDescribeAgain => 'Describe it again';

  @override
  String resultsDirections(String name) {
    return 'Directions to $name';
  }

  @override
  String get resultsDirectionsFailed =>
      'Maps didn\'t open. Try again in a moment.';

  @override
  String get resultsDisposalNever => 'Never';

  @override
  String get resultsDisposalSteps => 'What to do';

  @override
  String get resultsDo => 'Do';

  @override
  String get resultsDonateNotSuitable => 'Not suitable to donate';

  @override
  String get resultsDonateSuitable => 'Good to donate';

  @override
  String get resultsDonateUnavailableTitle => 'Not one to donate';

  @override
  String get resultsDonateWhere => 'Where';

  @override
  String resultsDoneIn(String seconds) {
    return 'Done in $seconds s';
  }

  @override
  String get resultsDont => 'Don\'t';

  @override
  String get resultsDropoffErrorTitle => 'Drop-off points didn\'t load';

  @override
  String get resultsDropoffTitle => 'Drop-off near you';

  @override
  String get resultsDropoffWaiting =>
      'Drop-off points appear once Kanz knows what this is.';

  @override
  String get resultsEditCategory => 'Material';

  @override
  String get resultsEditHazards => 'Hazards';

  @override
  String get resultsEditItem => 'Correct this item';

  @override
  String get resultsEditMaterial => 'Specific material';

  @override
  String get resultsEditMaterialHint => 'For example: clear glass, PET #1';

  @override
  String get resultsEditName => 'Name';

  @override
  String get resultsEditQuality => 'Quality';

  @override
  String get resultsEditQuantity => 'Quantity';

  @override
  String get resultsEditQuantityInvalid => 'Enter a number, like 2 or 0.5';

  @override
  String get resultsEditSave => 'Save and update ideas';

  @override
  String get resultsEditState => 'State';

  @override
  String get resultsEditSubtitle =>
      'Kanz will update the ideas with your changes.';

  @override
  String get resultsEditUnit => 'Unit';

  @override
  String get resultsFindingIdeas => 'Finding ideas that suit your tools';

  @override
  String get resultsFocusItem => 'Focus ideas on this item';

  @override
  String resultsFocusedItem(String item) {
    return 'Ideas below are for the $item';
  }

  @override
  String resultsHazardLabel(String hazards) {
    return '$hazards: safe disposal only, no DIY';
  }

  @override
  String resultsHeldBackBody(String items) {
    return '$items can\'t be used for DIY.';
  }

  @override
  String get resultsHeldBackPointer =>
      'How to get rid of it safely follows the ideas.';

  @override
  String get resultsHeldBackTitle => 'Held back from DIY';

  @override
  String get resultsHideSteps => 'Hide steps';

  @override
  String get resultsHoursUnknown => 'Hours not listed';

  @override
  String get resultsIdeaBefore => 'Before';

  @override
  String get resultsIdeaImageFailed => 'Preview unavailable';

  @override
  String get resultsIdeaImagePaused => 'Image generation paused';

  @override
  String get resultsIdeaImageRetry => 'Try the image again';

  @override
  String get resultsIdeaRendering => 'Rendering the makeover';

  @override
  String get resultsIdeasErrorTitle => 'Ideas didn\'t load';

  @override
  String get resultsIdentifyErrorTitle =>
      'Kanz couldn\'t identify the materials';

  @override
  String get resultsImagesPausedBody =>
      'This server can\'t draw pictures right now. The ideas and their step-by-step tutorials still work.';

  @override
  String get resultsImagesPausedTitle => 'Makeover images paused';

  @override
  String resultsInCity(String city) {
    return 'In $city';
  }

  @override
  String resultsItemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items found',
      one: '1 item found',
    );
    return '$_temp0';
  }

  @override
  String get resultsLabelConfidence => 'Confidence';

  @override
  String get resultsLabelMaterial => 'Material';

  @override
  String get resultsLabelQuality => 'Quality';

  @override
  String get resultsLabelQuantity => 'Qty';

  @override
  String get resultsLabelRecyclable => 'Recyclable';

  @override
  String get resultsLabelState => 'State';

  @override
  String get resultsLabelType => 'Type';

  @override
  String resultsListAnd(String first, String last) {
    return '$first and $last';
  }

  @override
  String get resultsLocationOff =>
      'Location is off for Kanz, so pick a city instead.';

  @override
  String get resultsMarkDisposed => 'Mark as disposed';

  @override
  String get resultsMarkDonated => 'Mark as donated';

  @override
  String get resultsMarkRecycled => 'Mark as recycled';

  @override
  String get resultsMarkedDisposed => 'Disposed · added to your impact';

  @override
  String get resultsMarkedDonated => 'Donated · added to your impact';

  @override
  String get resultsMarkedRecycled => 'Recycled · added to your impact';

  @override
  String get resultsMaterialsSubtitle => 'Tap an item to see its details.';

  @override
  String get resultsMaterialsTitle => 'What it\'s made of';

  @override
  String get resultsMissingBody =>
      'It may have been deleted from History. Start a new scan to see ideas.';

  @override
  String get resultsMissingTitle => 'This scan isn\'t on this phone';

  @override
  String get resultsNearYou => 'Near your location';

  @override
  String get resultsNeedsLocationBody =>
      'Use your location or pick a city to see the nearest drop-off points.';

  @override
  String get resultsNeedsLocationTitle => 'Where should Kanz look?';

  @override
  String get resultsNewScan => 'New scan';

  @override
  String get resultsNoDiyTitle => 'No DIY for this item';

  @override
  String get resultsNoIdeasBody =>
      'Recycling or donating may suit it better. If Kanz misread the item, correct it above.';

  @override
  String get resultsNoIdeasTitle => 'No DIY ideas for this one';

  @override
  String get resultsNoPlacesBody =>
      'The Drop-off tab can search a wider set of places or another city.';

  @override
  String get resultsNoPlacesTitle => 'No drop-off points found nearby';

  @override
  String get resultsOffline =>
      'You\'re offline. Saved results still open; new steps wait for a connection.';

  @override
  String get resultsOpenDropoff => 'Open Drop-off';

  @override
  String get resultsOpenNow => 'Open now';

  @override
  String get resultsPathsTitle => 'What it can become';

  @override
  String get resultsPathsTitleDisposal => 'How to get rid of it safely';

  @override
  String resultsPhotoSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your photo, $count items found',
      one: 'Your photo, 1 item found',
      zero: 'Your photo',
    );
    return '$_temp0';
  }

  @override
  String get resultsPrep => 'Prep';

  @override
  String resultsQualitySemantics(int score, String label) {
    return 'Quality $score of 5, $label';
  }

  @override
  String get resultsReadAs => 'Kanz read this as';

  @override
  String get resultsReadingItems => 'Reading material, quantity and condition';

  @override
  String resultsRecyclableValue(String status, String stream) {
    return '$status · $stream';
  }

  @override
  String get resultsRecycleEmpty =>
      'No recycling steps came back for this scan.';

  @override
  String get resultsRetake => 'Retake photo';

  @override
  String get resultsRetakeFallbackTitle => 'Kanz couldn\'t make out an item';

  @override
  String get resultsSafeDisposalTitle => 'Safe disposal';

  @override
  String resultsSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get resultsSeeAll => 'See all';

  @override
  String get resultsShowSteps => 'Show steps';

  @override
  String get resultsSourceCurated => 'Kanz\'s own list';

  @override
  String get resultsSourceGoogle => 'Google';

  @override
  String get resultsSourceOsm => 'OpenStreetMap contributors';

  @override
  String get resultsStageImagesPaused =>
      'Image generation is paused on this server. Ideas and tutorials still work.';

  @override
  String get resultsStageNeedsLocation => 'Choose where to look, below.';

  @override
  String get resultsStageNoDropoff => 'Nothing here needs a drop-off point.';

  @override
  String get resultsStageNoMakeovers => 'No ideas to render.';

  @override
  String get resultsStageNoMakeoversDisposal =>
      'Nothing to render: this item needs safe disposal.';

  @override
  String get resultsSummaryDisposal => 'safe disposal';

  @override
  String resultsSummaryIdeas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ideas',
      one: '1 idea',
      zero: 'no ideas',
    );
    return '$_temp0';
  }

  @override
  String get resultsSummaryImagesPaused => 'Makeover images paused';

  @override
  String resultsSummaryPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
      zero: 'no places nearby',
    );
    return '$_temp0';
  }

  @override
  String get resultsTabDispose => 'Dispose';

  @override
  String get resultsTabDonate => 'Donate';

  @override
  String get resultsTabRecycle => 'Recycle';

  @override
  String get resultsTabUpcycle => 'Upcycle';

  @override
  String get resultsTextRejectedBody =>
      'Name the item and what it\'s made of, for example: two empty plastic water bottles.';

  @override
  String get resultsTextRejectedTitle => 'Kanz couldn\'t tell what that is';

  @override
  String get resultsTextScan => 'Text scan';

  @override
  String get resultsTip => 'What to try';

  @override
  String get resultsTitle => 'Scan results';

  @override
  String get resultsToolsAll => 'You have every tool';

  @override
  String resultsToolsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Needs $count tools you don\'t have',
      one: 'Needs 1 tool you don\'t have',
    );
    return '$_temp0';
  }

  @override
  String get resultsToolsNone => 'No tools needed';

  @override
  String resultsToolsSome(int have, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'You have $have of $total tools',
      one: 'You have $have of 1 tool',
    );
    return '$_temp0';
  }

  @override
  String get resultsUnitBag => 'bags';

  @override
  String get resultsUnitG => 'g';

  @override
  String get resultsUnitHandful => 'handfuls';

  @override
  String get resultsUnitKg => 'kg';

  @override
  String get resultsUnitL => 'litres';

  @override
  String get resultsUnitM => 'm';

  @override
  String get resultsUnitM2 => 'm²';

  @override
  String get resultsUnitPcs => 'pieces';

  @override
  String get resultsUnreachable =>
      'Can\'t reach the Kanz server. Saved results still open; new steps wait for it.';

  @override
  String get resultsUseMyLocation => 'Use my location';

  @override
  String get scanBackToCamera => 'Back to camera';

  @override
  String get scanCameraAllow => 'Allow camera';

  @override
  String get scanCameraBlockedBody =>
      'Camera access is off for Kanz. Turn it on in Settings, or use a photo from your gallery.';

  @override
  String get scanCameraDeniedBody =>
      'You can still pick a photo you already took, or describe the item in a sentence.';

  @override
  String get scanCameraDeniedTitle => 'Kanz can\'t use the camera';

  @override
  String get scanCameraUnavailableBody =>
      'Another app may be using it. Try again, or pick a photo from your gallery.';

  @override
  String get scanCameraUnavailableTitle => 'The camera isn\'t available';

  @override
  String get scanChooseFromGallery => 'Choose from gallery';

  @override
  String get scanDescribe => 'Describe';

  @override
  String get scanDescribeBody =>
      'Say what it is, what it\'s made of, how many there are and what shape they\'re in.';

  @override
  String get scanDescribeHint =>
      'For example: three empty glass jars with metal lids';

  @override
  String get scanDescribeInstead => 'Describe it instead';

  @override
  String get scanDescribeLabel => 'Description';

  @override
  String get scanDescribeSemantics => 'Describe the item in words';

  @override
  String get scanDescribeStart => 'Identify materials';

  @override
  String get scanDescribeTitle => 'Describe what you have';

  @override
  String get scanExampleBatteries => 'Four used AA batteries';

  @override
  String get scanExampleBox => 'A big cardboard box from a delivery';

  @override
  String get scanExampleJars => 'Empty glass jam jars with metal lids';

  @override
  String get scanExampleJeans => 'A pile of old denim jeans';

  @override
  String scanExampleSemantics(String example) {
    return 'Use the example: $example';
  }

  @override
  String get scanExamplesTitle => 'Or start from an example';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanGalleryErrorBody =>
      'Allow Kanz to see your photos, then try again.';

  @override
  String get scanGalleryErrorTitle => 'Your photos didn\'t open';

  @override
  String get scanGallerySemantics => 'Choose a photo from your gallery';

  @override
  String get scanGuidance => 'Fill the frame with one item, in good light';

  @override
  String get scanNoCameraBody =>
      'This phone has no camera Kanz can use. Pick a photo or describe the item instead.';

  @override
  String get scanOffline =>
      'You\'re offline. Kanz needs a connection to identify materials.';

  @override
  String get scanOpeningGallery => 'Opening your photos';

  @override
  String get scanShutter => 'Take photo';

  @override
  String get scanStartingCamera => 'Starting the camera';

  @override
  String get scanTextScan => 'Text scan';

  @override
  String get scanTorch => 'Flashlight';

  @override
  String get scanUseCamera => 'Use the camera';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutBody =>
      'Kanz identifies what your things are made of, suggests how to upcycle, recycle or donate them, and finds drop-off points in the UAE.';

  @override
  String get settingsCity => 'City';

  @override
  String get settingsCo2eNote =>
      'CO₂e figures in Kanz are estimates from average emission factors, not measurements.';

  @override
  String get settingsEstimates => 'Estimates';

  @override
  String get settingsHandsFree => 'Hands-free by default';

  @override
  String get settingsHandsFreeDetail =>
      'Reads each step aloud and listens for \"next\", \"back\" and \"repeat\".';

  @override
  String get settingsKnowledge => 'Knowledge base';

  @override
  String settingsKnowledgeDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
    );
    return '$_temp0';
  }

  @override
  String settingsKnowledgeKeyword(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents, keyword search',
      one: '1 document, keyword search',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageNote =>
      'Ideas, tutorials and spoken steps use this language too.';

  @override
  String settingsLanguageSystemDetail(String language) {
    return 'Now $language';
  }

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get settingsLocation => 'Location for drop-off points';

  @override
  String get settingsLocationCity => 'A fixed city';

  @override
  String settingsLocationCityDetail(String city) {
    return 'Search around $city';
  }

  @override
  String get settingsLocationCityNone => 'Choose a city';

  @override
  String get settingsLocationGps => 'Use my location';

  @override
  String get settingsLocationGpsDetail => 'Points sorted by distance from you';

  @override
  String get settingsLocationGpsOff =>
      'Location access is off. Kanz uses your city until you allow it.';

  @override
  String get settingsLocationGpsOffNoCity =>
      'Location access is off. Allow it, or choose a city.';

  @override
  String get settingsLocationUndecided =>
      'Kanz asks the first time you look for drop-off points.';

  @override
  String get settingsModelEmbed => 'Embeddings';

  @override
  String get settingsModelImage => 'Image model';

  @override
  String get settingsModelText => 'Text model';

  @override
  String get settingsModelVision => 'Vision model';

  @override
  String get settingsPlaces => 'Places sources';

  @override
  String get settingsPlacesNone => 'None configured';

  @override
  String get settingsServer => 'Server';

  @override
  String settingsServerHelper(String url) {
    return 'Default: $url';
  }

  @override
  String get settingsServerInvalid =>
      'Enter a full address that starts with http:// or https://';

  @override
  String get settingsServerNoAi =>
      'No AI key is set on this server, so scans can\'t be analysed.';

  @override
  String get settingsServerOfflineDetail =>
      'This phone has no network connection.';

  @override
  String get settingsServerReset => 'Use default';

  @override
  String get settingsServerSave => 'Save and test';

  @override
  String get settingsServerTest => 'Test connection';

  @override
  String get settingsServerTesting => 'Testing the connection';

  @override
  String get settingsServerUnreachableDetail =>
      'Check the address, and that the server is running and on the same network.';

  @override
  String get settingsServerUrl => 'Server address';

  @override
  String get settingsServerVersion => 'Server version';

  @override
  String get settingsSkill => 'Skill level';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTools => 'My tools';

  @override
  String get settingsToolsListSeparator => ', ';

  @override
  String settingsToolsMore(String names, int count) {
    return '$names and $count more';
  }

  @override
  String get settingsToolsNone =>
      'None yet. Ideas that need no tools come first.';

  @override
  String get settingsTutorials => 'Tutorials';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsWorkshop => 'Your workshop';

  @override
  String get shellChecking => 'Checking the connection';

  @override
  String get shellOffline => 'You\'re offline. Saved scans still open.';

  @override
  String get shellRetry => 'Retry';

  @override
  String get shellScan => 'Scan an item';

  @override
  String get shellTabDropoff => 'Drop-off';

  @override
  String get shellTabHome => 'Home';

  @override
  String get shellTabImpact => 'Impact';

  @override
  String get shellTabSwaps => 'Swaps';

  @override
  String get shellUnreachable =>
      'Can\'t reach the Kanz server. Saved scans still open.';

  @override
  String get swapsChipBatteries => 'Batteries';

  @override
  String get swapsChipClingFilm => 'Cling film';

  @override
  String get swapsChipCoffeeCapsules => 'Coffee capsules';

  @override
  String get swapsChipPaperTowels => 'Paper towels';

  @override
  String get swapsChipPlasticBags => 'Plastic bags';

  @override
  String get swapsChipPlasticBottles => 'Plastic bottles';

  @override
  String get swapsChipTakeawayContainers => 'Takeaway containers';

  @override
  String get swapsChipWetWipes => 'Wet wipes';

  @override
  String get swapsChipsLabel => 'Often in your bin';

  @override
  String swapsCostLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'low': 'Low cost',
      'medium': 'Medium cost',
      'high': 'High cost',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String swapsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count swaps',
      one: '1 swap',
    );
    return '$_temp0';
  }

  @override
  String swapsEffortLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'low': 'Low effort',
      'medium': 'Medium effort',
      'high': 'High effort',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String get swapsEmptyMessage =>
      'Kanz couldn\'t match those items. Try a common one, like plastic bottles or cling film.';

  @override
  String get swapsEmptyTitle => 'No swaps for that yet';

  @override
  String get swapsErrorTitle => 'Swaps didn\'t load';

  @override
  String get swapsFreeTextHelper => 'Separate items with commas';

  @override
  String get swapsFreeTextHint => 'Straws, foil trays, razors';

  @override
  String get swapsFreeTextLabel => 'Add something else';

  @override
  String get swapsFromScans => 'From your scans';

  @override
  String swapsHistorySubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Also covers what you scanned in the last $days days',
      one: 'Also covers what you scanned today',
    );
    return '$_temp0';
  }

  @override
  String get swapsHistoryTitle => 'Use my scan history';

  @override
  String get swapsHowCost =>
      'Effort and cost at a glance, with the sources behind it.';

  @override
  String get swapsHowSwap => 'One lasting alternative for each item you pick.';

  @override
  String get swapsHowTip =>
      'Why it helps, and one tip to make the switch stick.';

  @override
  String get swapsHowTitle => 'What you get';

  @override
  String get swapsInsightLabel => 'From your scans';

  @override
  String get swapsInsteadOf => 'Instead of';

  @override
  String get swapsIntro =>
      'Pick what you throw away most. Kanz suggests a lasting alternative for each, with one tip to make it stick.';

  @override
  String swapsLoading(String items) {
    return 'Finding swaps for $items';
  }

  @override
  String get swapsLoadingHistory => 'Finding swaps from your scan history';

  @override
  String get swapsOfflineTitle => 'Swaps need a connection';

  @override
  String get swapsResultsTitle => 'Swaps for you';

  @override
  String get swapsSources => 'Sources';

  @override
  String get swapsStartOver => 'Start over';

  @override
  String get swapsSubmit => 'Find swaps';

  @override
  String get swapsSubmitHint => 'Pick at least one item, or type your own.';

  @override
  String get swapsTip => 'Tip';

  @override
  String get swapsTitle => 'Swaps';

  @override
  String get swapsTry => 'Try';

  @override
  String get swapsUpdate => 'Update swaps';

  @override
  String get tutorialAdaptAdd => 'Add a tool';

  @override
  String get tutorialAdaptBody =>
      'Kanz rewrites the steps for your skill and the tools you have.';

  @override
  String tutorialAdaptFailed(String reason) {
    return 'Couldn\'t rewrite the tutorial. $reason';
  }

  @override
  String get tutorialAdaptHave => 'You have';

  @override
  String get tutorialAdaptOffline => 'Adapting needs a connection.';

  @override
  String get tutorialAdaptOfflineRow => 'Adapting needs a connection';

  @override
  String get tutorialAdaptProgressNote =>
      'Your progress starts over, because the steps change.';

  @override
  String get tutorialAdaptSkill => 'Your skill';

  @override
  String get tutorialAdaptSubmit => 'Rewrite the steps';

  @override
  String get tutorialAdaptTitle => 'Adapt this tutorial';

  @override
  String tutorialAdaptToolsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tools · $count selected',
      zero: 'Tools · none selected',
    );
    return '$_temp0';
  }

  @override
  String get tutorialAdaptToolsHint =>
      'Leave a tool off and Kanz works around it.';

  @override
  String get tutorialAdaptTooltip => 'Adapt to your skill and tools';

  @override
  String get tutorialAdaptedLabel => 'Your version';

  @override
  String tutorialAdapting(String skill) {
    return 'Rewriting for $skill with your tools. The current steps stay here until the new ones arrive.';
  }

  @override
  String get tutorialAdaptingRow => 'Adapting to your tools';

  @override
  String get tutorialBefore => 'Before';

  @override
  String get tutorialCareLabel => 'Care';

  @override
  String get tutorialCareful => 'Careful';

  @override
  String get tutorialChangeSetup => 'Change skill or tools';

  @override
  String get tutorialCommandBack => 'back';

  @override
  String get tutorialCommandNext => 'next';

  @override
  String get tutorialCommandRepeat => 'repeat';

  @override
  String tutorialContinue(int number) {
    return 'Continue at step $number';
  }

  @override
  String get tutorialDismiss => 'Dismiss';

  @override
  String get tutorialErrorTitle => 'The tutorial didn\'t load';

  @override
  String get tutorialEyebrow => 'Tutorial';

  @override
  String get tutorialFinish => 'Finish project';

  @override
  String get tutorialFinishEyebrow => 'Almost done';

  @override
  String get tutorialFinishFailed => 'Couldn\'t save the project. Try again.';

  @override
  String get tutorialFinishSaving => 'Saving your project';

  @override
  String get tutorialFinishTitle => 'Finishing and care';

  @override
  String get tutorialFinishingLabel => 'Finishing';

  @override
  String get tutorialFromScan => 'From your scan';

  @override
  String get tutorialGearLabel => 'Protective gear';

  @override
  String get tutorialHandsFree => 'Hands-free mode';

  @override
  String get tutorialHandsFreeOn => 'Hands-free is on';

  @override
  String get tutorialHandsFreeStarting => 'Starting hands-free';

  @override
  String tutorialHeard(String command) {
    return 'Heard “$command”';
  }

  @override
  String tutorialImageBlocked(int number) {
    return 'Waiting for the image of step $number';
  }

  @override
  String tutorialImageDrawing(int number) {
    return 'Drawing step $number';
  }

  @override
  String get tutorialImageFailed => 'This step\'s image didn\'t load';

  @override
  String tutorialImageLabel(int number, String title) {
    return 'Picture of step $number: $title';
  }

  @override
  String get tutorialImageOffline => 'Pictures need a connection';

  @override
  String get tutorialImagePaused => 'Image generation is paused on this server';

  @override
  String tutorialImageQueued(int number) {
    return 'In line after step $number';
  }

  @override
  String tutorialImageTag(String number) {
    return 'Step $number';
  }

  @override
  String get tutorialListening => 'Listening';

  @override
  String get tutorialLoadingBody =>
      'Kanz is writing steps for your skill and the tools you have. This takes about ten seconds.';

  @override
  String get tutorialLoadingTitle => 'Writing your tutorial';

  @override
  String get tutorialMarkDone => 'Mark step done';

  @override
  String get tutorialMaterialsTitle => 'Materials';

  @override
  String get tutorialMissingAction => 'Back to the ideas';

  @override
  String get tutorialMissingBody =>
      'Its scan may have been deleted. Go back and pick another idea.';

  @override
  String get tutorialMissingTitle => 'This idea isn\'t available';

  @override
  String get tutorialNext => 'Next step';

  @override
  String get tutorialNoHandsFree =>
      'Hands-free isn\'t available on this phone. The buttons still work.';

  @override
  String get tutorialNoSpeech =>
      'This phone has no voice to read steps aloud. Voice commands still work.';

  @override
  String get tutorialNoVoice =>
      'Voice commands aren\'t available on this phone. Steps are read aloud; use the buttons to move.';

  @override
  String get tutorialOfflineBanner =>
      'You\'re offline. This tutorial is saved; new pictures and adapting need a connection.';

  @override
  String get tutorialOfflineBody =>
      'This tutorial isn\'t saved on your phone yet. Connect to the internet and try again.';

  @override
  String get tutorialOfflineTitle => 'You\'re offline';

  @override
  String get tutorialOverview => 'Back to the overview';

  @override
  String get tutorialPrevious => 'Previous step';

  @override
  String get tutorialRedraw => 'Redraw picture';

  @override
  String get tutorialSafetyNotes => 'Before you start';

  @override
  String get tutorialSafetyTitle => 'Safety';

  @override
  String get tutorialSourcesLabel => 'Based on';

  @override
  String tutorialSpeaking(int number) {
    return 'Reading step $number aloud';
  }

  @override
  String get tutorialSpecSkill => 'Skill';

  @override
  String get tutorialSpecSteps => 'Steps';

  @override
  String get tutorialSpecTime => 'Time';

  @override
  String get tutorialSpecTools => 'Tools';

  @override
  String get tutorialStart => 'Start step 1';

  @override
  String get tutorialStepDone => 'Step done';

  @override
  String get tutorialStepDoneHint => 'Tap to mark it not done';

  @override
  String get tutorialStepDoneTag => 'Done';

  @override
  String tutorialStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String tutorialStepsDone(int done, int total) {
    return '$done of $total steps done';
  }

  @override
  String tutorialStepsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps aren\'t marked done. You can still finish.',
      one: '1 step isn\'t marked done. You can still finish.',
    );
    return '$_temp0';
  }

  @override
  String get tutorialTip => 'Tip';

  @override
  String get tutorialToFinish => 'Go to finishing';

  @override
  String get tutorialToGather => 'To gather';

  @override
  String get tutorialToolHave => 'You have it';

  @override
  String get tutorialToolInstead => 'Use instead';

  @override
  String get tutorialToolMissing => 'Missing';

  @override
  String tutorialToolsReady(int have, int total) {
    return '$have of $total ready';
  }

  @override
  String get tutorialToolsTitle => 'Tools';

  @override
  String get tutorialUpdated => 'Updated';

  @override
  String get tutorialVoiceHint => 'Say “next”, “back” or “repeat”';
}
