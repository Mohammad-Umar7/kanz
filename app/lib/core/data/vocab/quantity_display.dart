import '../models/vocab_enums.dart';

/// Ready-to-show quantity for an item the user corrected: '1 pc', '3 pcs',
/// '0.5 kg', 'قطعة واحدة', '3 قطع'.
///
/// Mirrors `quantity_display` in `backend/app/ai/convert.py`, so a corrected
/// card reads exactly like one the Material Analyst produced. Arabic uses the
/// counted-noun forms (one, two, 3-10, 11+) and keeps Western digits.
String formatQuantity(
  double value,
  String unit,
  Lang lang, {
  bool isEstimate = false,
}) {
  final v = value < 0 ? 0.0 : value;
  final number = _number(v);
  if (lang == Lang.ar) {
    final prefix = isEstimate ? 'حوالي ' : '';
    final counted = _countedAr[unit];
    if (counted == null) return '$prefix$number ${_measureAr[unit] ?? unit}';
    if (!isEstimate && v == 1) return counted.one;
    if (!isEstimate && v == 2) return counted.two;
    final noun = v >= 3 && v <= 10
        ? counted.few
        : v > 10
        ? counted.many
        : counted.single;
    return '$prefix$number $noun';
  }
  final (singular, plural) = _unitsEn[unit] ?? (unit, unit);
  final measured = const {'kg', 'g', 'm', 'm2', 'L'}.contains(unit);
  final noun = measured || (v == 1 && !isEstimate) ? singular : plural;
  return '${isEstimate ? '~' : ''}$number $noun';
}

String _number(double v) {
  if ((v - v.roundToDouble()).abs() < 1e-6) return v.round().toString();
  final fixed = v.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

const _unitsEn = {
  'pcs': ('pc', 'pcs'),
  'kg': ('kg', 'kg'),
  'g': ('g', 'g'),
  'm': ('m', 'm'),
  'm2': ('m²', 'm²'),
  'L': ('L', 'L'),
  'handful': ('handful', 'handfuls'),
  'bag': ('bag', 'bags'),
};

typedef _Counted = ({
  String one,
  String two,
  String few,
  String many,
  String single,
});

const Map<String, _Counted> _countedAr = {
  'pcs': (
    one: 'قطعة واحدة',
    two: 'قطعتان',
    few: 'قطع',
    many: 'قطعة',
    single: 'قطعة',
  ),
  'handful': (
    one: 'حفنة واحدة',
    two: 'حفنتان',
    few: 'حفنات',
    many: 'حفنة',
    single: 'حفنة',
  ),
  'bag': (
    one: 'كيس واحد',
    two: 'كيسان',
    few: 'أكياس',
    many: 'كيسًا',
    single: 'كيس',
  ),
};

const _measureAr = {'kg': 'كغ', 'g': 'غ', 'm': 'م', 'm2': 'م²', 'L': 'لتر'};
