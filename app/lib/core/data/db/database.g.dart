// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ScansTable extends Scans with TableInfo<$ScansTable, Scan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputTextMeta = const VerificationMeta(
    'inputText',
  );
  @override
  late final GeneratedColumn<String> inputText = GeneratedColumn<String>(
    'input_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageIdMeta = const VerificationMeta(
    'imageId',
  );
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
    'image_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryCategoryMeta = const VerificationMeta(
    'primaryCategory',
  );
  @override
  late final GeneratedColumn<String> primaryCategory = GeneratedColumn<String>(
    'primary_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _analysisJsonMeta = const VerificationMeta(
    'analysisJson',
  );
  @override
  late final GeneratedColumn<String> analysisJson = GeneratedColumn<String>(
    'analysis_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendationJsonMeta =
      const VerificationMeta('recommendationJson');
  @override
  late final GeneratedColumn<String> recommendationJson =
      GeneratedColumn<String>(
        'recommendation_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _facilitiesJsonMeta = const VerificationMeta(
    'facilitiesJson',
  );
  @override
  late final GeneratedColumn<String> facilitiesJson = GeneratedColumn<String>(
    'facilities_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stagesJsonMeta = const VerificationMeta(
    'stagesJson',
  );
  @override
  late final GeneratedColumn<String> stagesJson = GeneratedColumn<String>(
    'stages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _focusItemIdMeta = const VerificationMeta(
    'focusItemId',
  );
  @override
  late final GeneratedColumn<String> focusItemId = GeneratedColumn<String>(
    'focus_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    source,
    lang,
    inputText,
    localImagePath,
    imageId,
    imageUrl,
    title,
    primaryCategory,
    itemCount,
    analysisJson,
    recommendationJson,
    facilitiesJson,
    stagesJson,
    focusItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('input_text')) {
      context.handle(
        _inputTextMeta,
        inputText.isAcceptableOrUnknown(data['input_text']!, _inputTextMeta),
      );
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('image_id')) {
      context.handle(
        _imageIdMeta,
        imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('primary_category')) {
      context.handle(
        _primaryCategoryMeta,
        primaryCategory.isAcceptableOrUnknown(
          data['primary_category']!,
          _primaryCategoryMeta,
        ),
      );
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    if (data.containsKey('analysis_json')) {
      context.handle(
        _analysisJsonMeta,
        analysisJson.isAcceptableOrUnknown(
          data['analysis_json']!,
          _analysisJsonMeta,
        ),
      );
    }
    if (data.containsKey('recommendation_json')) {
      context.handle(
        _recommendationJsonMeta,
        recommendationJson.isAcceptableOrUnknown(
          data['recommendation_json']!,
          _recommendationJsonMeta,
        ),
      );
    }
    if (data.containsKey('facilities_json')) {
      context.handle(
        _facilitiesJsonMeta,
        facilitiesJson.isAcceptableOrUnknown(
          data['facilities_json']!,
          _facilitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('stages_json')) {
      context.handle(
        _stagesJsonMeta,
        stagesJson.isAcceptableOrUnknown(data['stages_json']!, _stagesJsonMeta),
      );
    }
    if (data.containsKey('focus_item_id')) {
      context.handle(
        _focusItemIdMeta,
        focusItemId.isAcceptableOrUnknown(
          data['focus_item_id']!,
          _focusItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      inputText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_text'],
      ),
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      imageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_id'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      primaryCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_category'],
      ),
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      analysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_json'],
      ),
      recommendationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendation_json'],
      ),
      facilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facilities_json'],
      ),
      stagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stages_json'],
      )!,
      focusItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus_item_id'],
      ),
    );
  }

  @override
  $ScansTable createAlias(String alias) {
    return $ScansTable(attachedDatabase, alias);
  }
}

class Scan extends DataClass implements Insertable<Scan> {
  /// App-generated id (uuid v4), known before the backend answers.
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 'image' or 'text' (AnalysisSource wire id).
  final String source;

  /// Content language the scan was analyzed in ('en' | 'ar').
  final String lang;

  /// The description, for text scans.
  final String? inputText;

  /// Compressed photo in the documents directory (thumbnail and offline hero).
  final String? localImagePath;

  /// Backend upload id ('img_...' / 'txt_...') once analyze succeeded.
  final String? imageId;
  final String? imageUrl;

  /// Primary item name and category, denormalized for the history list.
  final String? title;
  final String? primaryCategory;
  final int itemCount;
  final String? analysisJson;
  final String? recommendationJson;
  final String? facilitiesJson;

  /// Pipeline stage -> status name, e.g. {"identifying": "done"}.
  final String stagesJson;
  final String? focusItemId;
  const Scan({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    required this.lang,
    this.inputText,
    this.localImagePath,
    this.imageId,
    this.imageUrl,
    this.title,
    this.primaryCategory,
    required this.itemCount,
    this.analysisJson,
    this.recommendationJson,
    this.facilitiesJson,
    required this.stagesJson,
    this.focusItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['source'] = Variable<String>(source);
    map['lang'] = Variable<String>(lang);
    if (!nullToAbsent || inputText != null) {
      map['input_text'] = Variable<String>(inputText);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<String>(imageId);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || primaryCategory != null) {
      map['primary_category'] = Variable<String>(primaryCategory);
    }
    map['item_count'] = Variable<int>(itemCount);
    if (!nullToAbsent || analysisJson != null) {
      map['analysis_json'] = Variable<String>(analysisJson);
    }
    if (!nullToAbsent || recommendationJson != null) {
      map['recommendation_json'] = Variable<String>(recommendationJson);
    }
    if (!nullToAbsent || facilitiesJson != null) {
      map['facilities_json'] = Variable<String>(facilitiesJson);
    }
    map['stages_json'] = Variable<String>(stagesJson);
    if (!nullToAbsent || focusItemId != null) {
      map['focus_item_id'] = Variable<String>(focusItemId);
    }
    return map;
  }

  ScansCompanion toCompanion(bool nullToAbsent) {
    return ScansCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      source: Value(source),
      lang: Value(lang),
      inputText: inputText == null && nullToAbsent
          ? const Value.absent()
          : Value(inputText),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      primaryCategory: primaryCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryCategory),
      itemCount: Value(itemCount),
      analysisJson: analysisJson == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisJson),
      recommendationJson: recommendationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendationJson),
      facilitiesJson: facilitiesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(facilitiesJson),
      stagesJson: Value(stagesJson),
      focusItemId: focusItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(focusItemId),
    );
  }

  factory Scan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scan(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      source: serializer.fromJson<String>(json['source']),
      lang: serializer.fromJson<String>(json['lang']),
      inputText: serializer.fromJson<String?>(json['inputText']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      imageId: serializer.fromJson<String?>(json['imageId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      title: serializer.fromJson<String?>(json['title']),
      primaryCategory: serializer.fromJson<String?>(json['primaryCategory']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      analysisJson: serializer.fromJson<String?>(json['analysisJson']),
      recommendationJson: serializer.fromJson<String?>(
        json['recommendationJson'],
      ),
      facilitiesJson: serializer.fromJson<String?>(json['facilitiesJson']),
      stagesJson: serializer.fromJson<String>(json['stagesJson']),
      focusItemId: serializer.fromJson<String?>(json['focusItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'source': serializer.toJson<String>(source),
      'lang': serializer.toJson<String>(lang),
      'inputText': serializer.toJson<String?>(inputText),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'imageId': serializer.toJson<String?>(imageId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'title': serializer.toJson<String?>(title),
      'primaryCategory': serializer.toJson<String?>(primaryCategory),
      'itemCount': serializer.toJson<int>(itemCount),
      'analysisJson': serializer.toJson<String?>(analysisJson),
      'recommendationJson': serializer.toJson<String?>(recommendationJson),
      'facilitiesJson': serializer.toJson<String?>(facilitiesJson),
      'stagesJson': serializer.toJson<String>(stagesJson),
      'focusItemId': serializer.toJson<String?>(focusItemId),
    };
  }

  Scan copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    String? lang,
    Value<String?> inputText = const Value.absent(),
    Value<String?> localImagePath = const Value.absent(),
    Value<String?> imageId = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> primaryCategory = const Value.absent(),
    int? itemCount,
    Value<String?> analysisJson = const Value.absent(),
    Value<String?> recommendationJson = const Value.absent(),
    Value<String?> facilitiesJson = const Value.absent(),
    String? stagesJson,
    Value<String?> focusItemId = const Value.absent(),
  }) => Scan(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    source: source ?? this.source,
    lang: lang ?? this.lang,
    inputText: inputText.present ? inputText.value : this.inputText,
    localImagePath: localImagePath.present
        ? localImagePath.value
        : this.localImagePath,
    imageId: imageId.present ? imageId.value : this.imageId,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    title: title.present ? title.value : this.title,
    primaryCategory: primaryCategory.present
        ? primaryCategory.value
        : this.primaryCategory,
    itemCount: itemCount ?? this.itemCount,
    analysisJson: analysisJson.present ? analysisJson.value : this.analysisJson,
    recommendationJson: recommendationJson.present
        ? recommendationJson.value
        : this.recommendationJson,
    facilitiesJson: facilitiesJson.present
        ? facilitiesJson.value
        : this.facilitiesJson,
    stagesJson: stagesJson ?? this.stagesJson,
    focusItemId: focusItemId.present ? focusItemId.value : this.focusItemId,
  );
  Scan copyWithCompanion(ScansCompanion data) {
    return Scan(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      source: data.source.present ? data.source.value : this.source,
      lang: data.lang.present ? data.lang.value : this.lang,
      inputText: data.inputText.present ? data.inputText.value : this.inputText,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      title: data.title.present ? data.title.value : this.title,
      primaryCategory: data.primaryCategory.present
          ? data.primaryCategory.value
          : this.primaryCategory,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      analysisJson: data.analysisJson.present
          ? data.analysisJson.value
          : this.analysisJson,
      recommendationJson: data.recommendationJson.present
          ? data.recommendationJson.value
          : this.recommendationJson,
      facilitiesJson: data.facilitiesJson.present
          ? data.facilitiesJson.value
          : this.facilitiesJson,
      stagesJson: data.stagesJson.present
          ? data.stagesJson.value
          : this.stagesJson,
      focusItemId: data.focusItemId.present
          ? data.focusItemId.value
          : this.focusItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scan(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('lang: $lang, ')
          ..write('inputText: $inputText, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('imageId: $imageId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('title: $title, ')
          ..write('primaryCategory: $primaryCategory, ')
          ..write('itemCount: $itemCount, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('recommendationJson: $recommendationJson, ')
          ..write('facilitiesJson: $facilitiesJson, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('focusItemId: $focusItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    source,
    lang,
    inputText,
    localImagePath,
    imageId,
    imageUrl,
    title,
    primaryCategory,
    itemCount,
    analysisJson,
    recommendationJson,
    facilitiesJson,
    stagesJson,
    focusItemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scan &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.source == this.source &&
          other.lang == this.lang &&
          other.inputText == this.inputText &&
          other.localImagePath == this.localImagePath &&
          other.imageId == this.imageId &&
          other.imageUrl == this.imageUrl &&
          other.title == this.title &&
          other.primaryCategory == this.primaryCategory &&
          other.itemCount == this.itemCount &&
          other.analysisJson == this.analysisJson &&
          other.recommendationJson == this.recommendationJson &&
          other.facilitiesJson == this.facilitiesJson &&
          other.stagesJson == this.stagesJson &&
          other.focusItemId == this.focusItemId);
}

class ScansCompanion extends UpdateCompanion<Scan> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> source;
  final Value<String> lang;
  final Value<String?> inputText;
  final Value<String?> localImagePath;
  final Value<String?> imageId;
  final Value<String?> imageUrl;
  final Value<String?> title;
  final Value<String?> primaryCategory;
  final Value<int> itemCount;
  final Value<String?> analysisJson;
  final Value<String?> recommendationJson;
  final Value<String?> facilitiesJson;
  final Value<String> stagesJson;
  final Value<String?> focusItemId;
  final Value<int> rowid;
  const ScansCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.lang = const Value.absent(),
    this.inputText = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.imageId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.primaryCategory = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.recommendationJson = const Value.absent(),
    this.facilitiesJson = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.focusItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScansCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String source,
    required String lang,
    this.inputText = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.imageId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.primaryCategory = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.recommendationJson = const Value.absent(),
    this.facilitiesJson = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.focusItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       source = Value(source),
       lang = Value(lang);
  static Insertable<Scan> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? source,
    Expression<String>? lang,
    Expression<String>? inputText,
    Expression<String>? localImagePath,
    Expression<String>? imageId,
    Expression<String>? imageUrl,
    Expression<String>? title,
    Expression<String>? primaryCategory,
    Expression<int>? itemCount,
    Expression<String>? analysisJson,
    Expression<String>? recommendationJson,
    Expression<String>? facilitiesJson,
    Expression<String>? stagesJson,
    Expression<String>? focusItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (source != null) 'source': source,
      if (lang != null) 'lang': lang,
      if (inputText != null) 'input_text': inputText,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (imageId != null) 'image_id': imageId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (title != null) 'title': title,
      if (primaryCategory != null) 'primary_category': primaryCategory,
      if (itemCount != null) 'item_count': itemCount,
      if (analysisJson != null) 'analysis_json': analysisJson,
      if (recommendationJson != null) 'recommendation_json': recommendationJson,
      if (facilitiesJson != null) 'facilities_json': facilitiesJson,
      if (stagesJson != null) 'stages_json': stagesJson,
      if (focusItemId != null) 'focus_item_id': focusItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? source,
    Value<String>? lang,
    Value<String?>? inputText,
    Value<String?>? localImagePath,
    Value<String?>? imageId,
    Value<String?>? imageUrl,
    Value<String?>? title,
    Value<String?>? primaryCategory,
    Value<int>? itemCount,
    Value<String?>? analysisJson,
    Value<String?>? recommendationJson,
    Value<String?>? facilitiesJson,
    Value<String>? stagesJson,
    Value<String?>? focusItemId,
    Value<int>? rowid,
  }) {
    return ScansCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      lang: lang ?? this.lang,
      inputText: inputText ?? this.inputText,
      localImagePath: localImagePath ?? this.localImagePath,
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      itemCount: itemCount ?? this.itemCount,
      analysisJson: analysisJson ?? this.analysisJson,
      recommendationJson: recommendationJson ?? this.recommendationJson,
      facilitiesJson: facilitiesJson ?? this.facilitiesJson,
      stagesJson: stagesJson ?? this.stagesJson,
      focusItemId: focusItemId ?? this.focusItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (inputText.present) {
      map['input_text'] = Variable<String>(inputText.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (primaryCategory.present) {
      map['primary_category'] = Variable<String>(primaryCategory.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (analysisJson.present) {
      map['analysis_json'] = Variable<String>(analysisJson.value);
    }
    if (recommendationJson.present) {
      map['recommendation_json'] = Variable<String>(recommendationJson.value);
    }
    if (facilitiesJson.present) {
      map['facilities_json'] = Variable<String>(facilitiesJson.value);
    }
    if (stagesJson.present) {
      map['stages_json'] = Variable<String>(stagesJson.value);
    }
    if (focusItemId.present) {
      map['focus_item_id'] = Variable<String>(focusItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScansCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('source: $source, ')
          ..write('lang: $lang, ')
          ..write('inputText: $inputText, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('imageId: $imageId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('title: $title, ')
          ..write('primaryCategory: $primaryCategory, ')
          ..write('itemCount: $itemCount, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('recommendationJson: $recommendationJson, ')
          ..write('facilitiesJson: $facilitiesJson, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('focusItemId: $focusItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<String> scanId = GeneratedColumn<String>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ideaIdMeta = const VerificationMeta('ideaId');
  @override
  late final GeneratedColumn<String> ideaId = GeneratedColumn<String>(
    'idea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ideaJsonMeta = const VerificationMeta(
    'ideaJson',
  );
  @override
  late final GeneratedColumn<String> ideaJson = GeneratedColumn<String>(
    'idea_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tutorialIdMeta = const VerificationMeta(
    'tutorialId',
  );
  @override
  late final GeneratedColumn<String> tutorialId = GeneratedColumn<String>(
    'tutorial_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tutorialJsonMeta = const VerificationMeta(
    'tutorialJson',
  );
  @override
  late final GeneratedColumn<String> tutorialJson = GeneratedColumn<String>(
    'tutorial_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolsMeta = const VerificationMeta('tools');
  @override
  late final GeneratedColumn<String> tools = GeneratedColumn<String>(
    'tools',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _totalStepsMeta = const VerificationMeta(
    'totalSteps',
  );
  @override
  late final GeneratedColumn<int> totalSteps = GeneratedColumn<int>(
    'total_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _completedStepsMeta = const VerificationMeta(
    'completedSteps',
  );
  @override
  late final GeneratedColumn<String> completedSteps = GeneratedColumn<String>(
    'completed_steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProjectStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProjectStatus>($ProjectsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scanId,
    ideaId,
    title,
    ideaJson,
    tutorialId,
    tutorialJson,
    skill,
    tools,
    totalSteps,
    currentStep,
    completedSteps,
    status,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('idea_id')) {
      context.handle(
        _ideaIdMeta,
        ideaId.isAcceptableOrUnknown(data['idea_id']!, _ideaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ideaIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('idea_json')) {
      context.handle(
        _ideaJsonMeta,
        ideaJson.isAcceptableOrUnknown(data['idea_json']!, _ideaJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_ideaJsonMeta);
    }
    if (data.containsKey('tutorial_id')) {
      context.handle(
        _tutorialIdMeta,
        tutorialId.isAcceptableOrUnknown(data['tutorial_id']!, _tutorialIdMeta),
      );
    }
    if (data.containsKey('tutorial_json')) {
      context.handle(
        _tutorialJsonMeta,
        tutorialJson.isAcceptableOrUnknown(
          data['tutorial_json']!,
          _tutorialJsonMeta,
        ),
      );
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    }
    if (data.containsKey('tools')) {
      context.handle(
        _toolsMeta,
        tools.isAcceptableOrUnknown(data['tools']!, _toolsMeta),
      );
    }
    if (data.containsKey('total_steps')) {
      context.handle(
        _totalStepsMeta,
        totalSteps.isAcceptableOrUnknown(data['total_steps']!, _totalStepsMeta),
      );
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    }
    if (data.containsKey('completed_steps')) {
      context.handle(
        _completedStepsMeta,
        completedSteps.isAcceptableOrUnknown(
          data['completed_steps']!,
          _completedStepsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scanId, ideaId},
  ];
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_id'],
      )!,
      ideaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idea_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      ideaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idea_json'],
      )!,
      tutorialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutorial_id'],
      ),
      tutorialJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutorial_json'],
      ),
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      ),
      tools: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tools'],
      )!,
      totalSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_steps'],
      )!,
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_step'],
      )!,
      completedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_steps'],
      )!,
      status: $ProjectsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProjectStatus, String, String> $converterstatus =
      const EnumNameConverter<ProjectStatus>(ProjectStatus.values);
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String scanId;
  final String ideaId;
  final String title;

  /// The UpcycleIdea the project was started from.
  final String ideaJson;

  /// The latest tutorial (after any adaptation) and the profile it was made for.
  final String? tutorialId;
  final String? tutorialJson;
  final String? skill;

  /// Comma-separated ToolId wire ids the tutorial was adapted to.
  final String tools;
  final int totalSteps;

  /// 1-based step the user is looking at.
  final int currentStep;

  /// Comma-separated 1-based step numbers marked done.
  final String completedSteps;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const Project({
    required this.id,
    required this.scanId,
    required this.ideaId,
    required this.title,
    required this.ideaJson,
    this.tutorialId,
    this.tutorialJson,
    this.skill,
    required this.tools,
    required this.totalSteps,
    required this.currentStep,
    required this.completedSteps,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scan_id'] = Variable<String>(scanId);
    map['idea_id'] = Variable<String>(ideaId);
    map['title'] = Variable<String>(title);
    map['idea_json'] = Variable<String>(ideaJson);
    if (!nullToAbsent || tutorialId != null) {
      map['tutorial_id'] = Variable<String>(tutorialId);
    }
    if (!nullToAbsent || tutorialJson != null) {
      map['tutorial_json'] = Variable<String>(tutorialJson);
    }
    if (!nullToAbsent || skill != null) {
      map['skill'] = Variable<String>(skill);
    }
    map['tools'] = Variable<String>(tools);
    map['total_steps'] = Variable<int>(totalSteps);
    map['current_step'] = Variable<int>(currentStep);
    map['completed_steps'] = Variable<String>(completedSteps);
    {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      scanId: Value(scanId),
      ideaId: Value(ideaId),
      title: Value(title),
      ideaJson: Value(ideaJson),
      tutorialId: tutorialId == null && nullToAbsent
          ? const Value.absent()
          : Value(tutorialId),
      tutorialJson: tutorialJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tutorialJson),
      skill: skill == null && nullToAbsent
          ? const Value.absent()
          : Value(skill),
      tools: Value(tools),
      totalSteps: Value(totalSteps),
      currentStep: Value(currentStep),
      completedSteps: Value(completedSteps),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      scanId: serializer.fromJson<String>(json['scanId']),
      ideaId: serializer.fromJson<String>(json['ideaId']),
      title: serializer.fromJson<String>(json['title']),
      ideaJson: serializer.fromJson<String>(json['ideaJson']),
      tutorialId: serializer.fromJson<String?>(json['tutorialId']),
      tutorialJson: serializer.fromJson<String?>(json['tutorialJson']),
      skill: serializer.fromJson<String?>(json['skill']),
      tools: serializer.fromJson<String>(json['tools']),
      totalSteps: serializer.fromJson<int>(json['totalSteps']),
      currentStep: serializer.fromJson<int>(json['currentStep']),
      completedSteps: serializer.fromJson<String>(json['completedSteps']),
      status: $ProjectsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scanId': serializer.toJson<String>(scanId),
      'ideaId': serializer.toJson<String>(ideaId),
      'title': serializer.toJson<String>(title),
      'ideaJson': serializer.toJson<String>(ideaJson),
      'tutorialId': serializer.toJson<String?>(tutorialId),
      'tutorialJson': serializer.toJson<String?>(tutorialJson),
      'skill': serializer.toJson<String?>(skill),
      'tools': serializer.toJson<String>(tools),
      'totalSteps': serializer.toJson<int>(totalSteps),
      'currentStep': serializer.toJson<int>(currentStep),
      'completedSteps': serializer.toJson<String>(completedSteps),
      'status': serializer.toJson<String>(
        $ProjectsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Project copyWith({
    String? id,
    String? scanId,
    String? ideaId,
    String? title,
    String? ideaJson,
    Value<String?> tutorialId = const Value.absent(),
    Value<String?> tutorialJson = const Value.absent(),
    Value<String?> skill = const Value.absent(),
    String? tools,
    int? totalSteps,
    int? currentStep,
    String? completedSteps,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Project(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    ideaId: ideaId ?? this.ideaId,
    title: title ?? this.title,
    ideaJson: ideaJson ?? this.ideaJson,
    tutorialId: tutorialId.present ? tutorialId.value : this.tutorialId,
    tutorialJson: tutorialJson.present ? tutorialJson.value : this.tutorialJson,
    skill: skill.present ? skill.value : this.skill,
    tools: tools ?? this.tools,
    totalSteps: totalSteps ?? this.totalSteps,
    currentStep: currentStep ?? this.currentStep,
    completedSteps: completedSteps ?? this.completedSteps,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      ideaId: data.ideaId.present ? data.ideaId.value : this.ideaId,
      title: data.title.present ? data.title.value : this.title,
      ideaJson: data.ideaJson.present ? data.ideaJson.value : this.ideaJson,
      tutorialId: data.tutorialId.present
          ? data.tutorialId.value
          : this.tutorialId,
      tutorialJson: data.tutorialJson.present
          ? data.tutorialJson.value
          : this.tutorialJson,
      skill: data.skill.present ? data.skill.value : this.skill,
      tools: data.tools.present ? data.tools.value : this.tools,
      totalSteps: data.totalSteps.present
          ? data.totalSteps.value
          : this.totalSteps,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      completedSteps: data.completedSteps.present
          ? data.completedSteps.value
          : this.completedSteps,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('ideaId: $ideaId, ')
          ..write('title: $title, ')
          ..write('ideaJson: $ideaJson, ')
          ..write('tutorialId: $tutorialId, ')
          ..write('tutorialJson: $tutorialJson, ')
          ..write('skill: $skill, ')
          ..write('tools: $tools, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('currentStep: $currentStep, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scanId,
    ideaId,
    title,
    ideaJson,
    tutorialId,
    tutorialJson,
    skill,
    tools,
    totalSteps,
    currentStep,
    completedSteps,
    status,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.ideaId == this.ideaId &&
          other.title == this.title &&
          other.ideaJson == this.ideaJson &&
          other.tutorialId == this.tutorialId &&
          other.tutorialJson == this.tutorialJson &&
          other.skill == this.skill &&
          other.tools == this.tools &&
          other.totalSteps == this.totalSteps &&
          other.currentStep == this.currentStep &&
          other.completedSteps == this.completedSteps &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> scanId;
  final Value<String> ideaId;
  final Value<String> title;
  final Value<String> ideaJson;
  final Value<String?> tutorialId;
  final Value<String?> tutorialJson;
  final Value<String?> skill;
  final Value<String> tools;
  final Value<int> totalSteps;
  final Value<int> currentStep;
  final Value<String> completedSteps;
  final Value<ProjectStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.title = const Value.absent(),
    this.ideaJson = const Value.absent(),
    this.tutorialId = const Value.absent(),
    this.tutorialJson = const Value.absent(),
    this.skill = const Value.absent(),
    this.tools = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.completedSteps = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String scanId,
    required String ideaId,
    required String title,
    required String ideaJson,
    this.tutorialId = const Value.absent(),
    this.tutorialJson = const Value.absent(),
    this.skill = const Value.absent(),
    this.tools = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.completedSteps = const Value.absent(),
    required ProjectStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scanId = Value(scanId),
       ideaId = Value(ideaId),
       title = Value(title),
       ideaJson = Value(ideaJson),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? scanId,
    Expression<String>? ideaId,
    Expression<String>? title,
    Expression<String>? ideaJson,
    Expression<String>? tutorialId,
    Expression<String>? tutorialJson,
    Expression<String>? skill,
    Expression<String>? tools,
    Expression<int>? totalSteps,
    Expression<int>? currentStep,
    Expression<String>? completedSteps,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (ideaId != null) 'idea_id': ideaId,
      if (title != null) 'title': title,
      if (ideaJson != null) 'idea_json': ideaJson,
      if (tutorialId != null) 'tutorial_id': tutorialId,
      if (tutorialJson != null) 'tutorial_json': tutorialJson,
      if (skill != null) 'skill': skill,
      if (tools != null) 'tools': tools,
      if (totalSteps != null) 'total_steps': totalSteps,
      if (currentStep != null) 'current_step': currentStep,
      if (completedSteps != null) 'completed_steps': completedSteps,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? scanId,
    Value<String>? ideaId,
    Value<String>? title,
    Value<String>? ideaJson,
    Value<String?>? tutorialId,
    Value<String?>? tutorialJson,
    Value<String?>? skill,
    Value<String>? tools,
    Value<int>? totalSteps,
    Value<int>? currentStep,
    Value<String>? completedSteps,
    Value<ProjectStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      ideaId: ideaId ?? this.ideaId,
      title: title ?? this.title,
      ideaJson: ideaJson ?? this.ideaJson,
      tutorialId: tutorialId ?? this.tutorialId,
      tutorialJson: tutorialJson ?? this.tutorialJson,
      skill: skill ?? this.skill,
      tools: tools ?? this.tools,
      totalSteps: totalSteps ?? this.totalSteps,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<String>(scanId.value);
    }
    if (ideaId.present) {
      map['idea_id'] = Variable<String>(ideaId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (ideaJson.present) {
      map['idea_json'] = Variable<String>(ideaJson.value);
    }
    if (tutorialId.present) {
      map['tutorial_id'] = Variable<String>(tutorialId.value);
    }
    if (tutorialJson.present) {
      map['tutorial_json'] = Variable<String>(tutorialJson.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (tools.present) {
      map['tools'] = Variable<String>(tools.value);
    }
    if (totalSteps.present) {
      map['total_steps'] = Variable<int>(totalSteps.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (completedSteps.present) {
      map['completed_steps'] = Variable<String>(completedSteps.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProjectsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('ideaId: $ideaId, ')
          ..write('title: $title, ')
          ..write('ideaJson: $ideaJson, ')
          ..write('tutorialId: $tutorialId, ')
          ..write('tutorialJson: $tutorialJson, ')
          ..write('skill: $skill, ')
          ..write('tools: $tools, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('currentStep: $currentStep, ')
          ..write('completedSteps: $completedSteps, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImpactEventsTable extends ImpactEvents
    with TableInfo<$ImpactEventsTable, ImpactEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpactEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ImpactKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ImpactKind>($ImpactEventsTable.$converterkind);
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pcs'),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<String> scanId = GeneratedColumn<String>(
    'scan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dedupeKey,
    kind,
    material,
    itemName,
    quantity,
    unit,
    scanId,
    projectId,
    itemId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impact_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImpactEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    } else if (isInserting) {
      context.missing(_materialMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImpactEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImpactEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      kind: $ImpactEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_id'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ImpactEventsTable createAlias(String alias) {
    return $ImpactEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ImpactKind, String, String> $converterkind =
      const EnumNameConverter<ImpactKind>(ImpactKind.values);
}

class ImpactEvent extends DataClass implements Insertable<ImpactEvent> {
  final int id;

  /// `kind:scanOrProject:item`, so marking the same item twice counts once.
  final String dedupeKey;
  final ImpactKind kind;

  /// MaterialCategory wire id.
  final String material;
  final String itemName;

  /// Quantity as analyzed ('1 pcs', '0.5 kg'); feeds the CO2e estimate.
  final double quantity;
  final String unit;

  /// No foreign keys: impact stays when a scan is removed from history.
  final String? scanId;
  final String? projectId;
  final String? itemId;
  final DateTime createdAt;
  const ImpactEvent({
    required this.id,
    required this.dedupeKey,
    required this.kind,
    required this.material,
    required this.itemName,
    required this.quantity,
    required this.unit,
    this.scanId,
    this.projectId,
    this.itemId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    {
      map['kind'] = Variable<String>(
        $ImpactEventsTable.$converterkind.toSql(kind),
      );
    }
    map['material'] = Variable<String>(material);
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || scanId != null) {
      map['scan_id'] = Variable<String>(scanId);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ImpactEventsCompanion toCompanion(bool nullToAbsent) {
    return ImpactEventsCompanion(
      id: Value(id),
      dedupeKey: Value(dedupeKey),
      kind: Value(kind),
      material: Value(material),
      itemName: Value(itemName),
      quantity: Value(quantity),
      unit: Value(unit),
      scanId: scanId == null && nullToAbsent
          ? const Value.absent()
          : Value(scanId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      createdAt: Value(createdAt),
    );
  }

  factory ImpactEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImpactEvent(
      id: serializer.fromJson<int>(json['id']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      kind: $ImpactEventsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      material: serializer.fromJson<String>(json['material']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      scanId: serializer.fromJson<String?>(json['scanId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'kind': serializer.toJson<String>(
        $ImpactEventsTable.$converterkind.toJson(kind),
      ),
      'material': serializer.toJson<String>(material),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'scanId': serializer.toJson<String?>(scanId),
      'projectId': serializer.toJson<String?>(projectId),
      'itemId': serializer.toJson<String?>(itemId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImpactEvent copyWith({
    int? id,
    String? dedupeKey,
    ImpactKind? kind,
    String? material,
    String? itemName,
    double? quantity,
    String? unit,
    Value<String?> scanId = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    DateTime? createdAt,
  }) => ImpactEvent(
    id: id ?? this.id,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    kind: kind ?? this.kind,
    material: material ?? this.material,
    itemName: itemName ?? this.itemName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    scanId: scanId.present ? scanId.value : this.scanId,
    projectId: projectId.present ? projectId.value : this.projectId,
    itemId: itemId.present ? itemId.value : this.itemId,
    createdAt: createdAt ?? this.createdAt,
  );
  ImpactEvent copyWithCompanion(ImpactEventsCompanion data) {
    return ImpactEvent(
      id: data.id.present ? data.id.value : this.id,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      material: data.material.present ? data.material.value : this.material,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImpactEvent(')
          ..write('id: $id, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('kind: $kind, ')
          ..write('material: $material, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('scanId: $scanId, ')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dedupeKey,
    kind,
    material,
    itemName,
    quantity,
    unit,
    scanId,
    projectId,
    itemId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImpactEvent &&
          other.id == this.id &&
          other.dedupeKey == this.dedupeKey &&
          other.kind == this.kind &&
          other.material == this.material &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.scanId == this.scanId &&
          other.projectId == this.projectId &&
          other.itemId == this.itemId &&
          other.createdAt == this.createdAt);
}

class ImpactEventsCompanion extends UpdateCompanion<ImpactEvent> {
  final Value<int> id;
  final Value<String> dedupeKey;
  final Value<ImpactKind> kind;
  final Value<String> material;
  final Value<String> itemName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<String?> scanId;
  final Value<String?> projectId;
  final Value<String?> itemId;
  final Value<DateTime> createdAt;
  const ImpactEventsCompanion({
    this.id = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.material = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.scanId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ImpactEventsCompanion.insert({
    this.id = const Value.absent(),
    required String dedupeKey,
    required ImpactKind kind,
    required String material,
    required String itemName,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.scanId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.itemId = const Value.absent(),
    required DateTime createdAt,
  }) : dedupeKey = Value(dedupeKey),
       kind = Value(kind),
       material = Value(material),
       itemName = Value(itemName),
       createdAt = Value(createdAt);
  static Insertable<ImpactEvent> custom({
    Expression<int>? id,
    Expression<String>? dedupeKey,
    Expression<String>? kind,
    Expression<String>? material,
    Expression<String>? itemName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? scanId,
    Expression<String>? projectId,
    Expression<String>? itemId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (kind != null) 'kind': kind,
      if (material != null) 'material': material,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (scanId != null) 'scan_id': scanId,
      if (projectId != null) 'project_id': projectId,
      if (itemId != null) 'item_id': itemId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ImpactEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? dedupeKey,
    Value<ImpactKind>? kind,
    Value<String>? material,
    Value<String>? itemName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<String?>? scanId,
    Value<String?>? projectId,
    Value<String?>? itemId,
    Value<DateTime>? createdAt,
  }) {
    return ImpactEventsCompanion(
      id: id ?? this.id,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      kind: kind ?? this.kind,
      material: material ?? this.material,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      scanId: scanId ?? this.scanId,
      projectId: projectId ?? this.projectId,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ImpactEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<String>(scanId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpactEventsCompanion(')
          ..write('id: $id, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('kind: $kind, ')
          ..write('material: $material, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('scanId: $scanId, ')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImageCacheTable extends ImageCache
    with TableInfo<$ImageCacheTable, ImageCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<String> scanId = GeneratedColumn<String>(
    'scan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ideaIdMeta = const VerificationMeta('ideaId');
  @override
  late final GeneratedColumn<String> ideaId = GeneratedColumn<String>(
    'idea_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tutorialIdMeta = const VerificationMeta(
    'tutorialId',
  );
  @override
  late final GeneratedColumn<String> tutorialId = GeneratedColumn<String>(
    'tutorial_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    remoteUrl,
    localPath,
    kind,
    scanId,
    ideaId,
    tutorialId,
    step,
    width,
    height,
    byteSize,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    }
    if (data.containsKey('idea_id')) {
      context.handle(
        _ideaIdMeta,
        ideaId.isAcceptableOrUnknown(data['idea_id']!, _ideaIdMeta),
      );
    }
    if (data.containsKey('tutorial_id')) {
      context.handle(
        _tutorialIdMeta,
        tutorialId.isAcceptableOrUnknown(data['tutorial_id']!, _tutorialIdMeta),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ImageCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCacheEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_id'],
      ),
      ideaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idea_id'],
      ),
      tutorialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutorial_id'],
      ),
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ImageCacheTable createAlias(String alias) {
    return $ImageCacheTable(attachedDatabase, alias);
  }
}

class ImageCacheEntry extends DataClass implements Insertable<ImageCacheEntry> {
  /// Backend cache key (ImageResponse.key).
  final String key;
  final String remoteUrl;
  final String localPath;

  /// ImageKind wire id: 'after', 'step' or 'bin'.
  final String kind;
  final String? scanId;
  final String? ideaId;
  final String? tutorialId;
  final int? step;
  final int? width;
  final int? height;
  final int byteSize;
  final DateTime createdAt;
  const ImageCacheEntry({
    required this.key,
    required this.remoteUrl,
    required this.localPath,
    required this.kind,
    this.scanId,
    this.ideaId,
    this.tutorialId,
    this.step,
    this.width,
    this.height,
    required this.byteSize,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['remote_url'] = Variable<String>(remoteUrl);
    map['local_path'] = Variable<String>(localPath);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || scanId != null) {
      map['scan_id'] = Variable<String>(scanId);
    }
    if (!nullToAbsent || ideaId != null) {
      map['idea_id'] = Variable<String>(ideaId);
    }
    if (!nullToAbsent || tutorialId != null) {
      map['tutorial_id'] = Variable<String>(tutorialId);
    }
    if (!nullToAbsent || step != null) {
      map['step'] = Variable<int>(step);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['byte_size'] = Variable<int>(byteSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ImageCacheCompanion toCompanion(bool nullToAbsent) {
    return ImageCacheCompanion(
      key: Value(key),
      remoteUrl: Value(remoteUrl),
      localPath: Value(localPath),
      kind: Value(kind),
      scanId: scanId == null && nullToAbsent
          ? const Value.absent()
          : Value(scanId),
      ideaId: ideaId == null && nullToAbsent
          ? const Value.absent()
          : Value(ideaId),
      tutorialId: tutorialId == null && nullToAbsent
          ? const Value.absent()
          : Value(tutorialId),
      step: step == null && nullToAbsent ? const Value.absent() : Value(step),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      byteSize: Value(byteSize),
      createdAt: Value(createdAt),
    );
  }

  factory ImageCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCacheEntry(
      key: serializer.fromJson<String>(json['key']),
      remoteUrl: serializer.fromJson<String>(json['remoteUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      kind: serializer.fromJson<String>(json['kind']),
      scanId: serializer.fromJson<String?>(json['scanId']),
      ideaId: serializer.fromJson<String?>(json['ideaId']),
      tutorialId: serializer.fromJson<String?>(json['tutorialId']),
      step: serializer.fromJson<int?>(json['step']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'remoteUrl': serializer.toJson<String>(remoteUrl),
      'localPath': serializer.toJson<String>(localPath),
      'kind': serializer.toJson<String>(kind),
      'scanId': serializer.toJson<String?>(scanId),
      'ideaId': serializer.toJson<String?>(ideaId),
      'tutorialId': serializer.toJson<String?>(tutorialId),
      'step': serializer.toJson<int?>(step),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'byteSize': serializer.toJson<int>(byteSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImageCacheEntry copyWith({
    String? key,
    String? remoteUrl,
    String? localPath,
    String? kind,
    Value<String?> scanId = const Value.absent(),
    Value<String?> ideaId = const Value.absent(),
    Value<String?> tutorialId = const Value.absent(),
    Value<int?> step = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? byteSize,
    DateTime? createdAt,
  }) => ImageCacheEntry(
    key: key ?? this.key,
    remoteUrl: remoteUrl ?? this.remoteUrl,
    localPath: localPath ?? this.localPath,
    kind: kind ?? this.kind,
    scanId: scanId.present ? scanId.value : this.scanId,
    ideaId: ideaId.present ? ideaId.value : this.ideaId,
    tutorialId: tutorialId.present ? tutorialId.value : this.tutorialId,
    step: step.present ? step.value : this.step,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    byteSize: byteSize ?? this.byteSize,
    createdAt: createdAt ?? this.createdAt,
  );
  ImageCacheEntry copyWithCompanion(ImageCacheCompanion data) {
    return ImageCacheEntry(
      key: data.key.present ? data.key.value : this.key,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      kind: data.kind.present ? data.kind.value : this.kind,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      ideaId: data.ideaId.present ? data.ideaId.value : this.ideaId,
      tutorialId: data.tutorialId.present
          ? data.tutorialId.value
          : this.tutorialId,
      step: data.step.present ? data.step.value : this.step,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheEntry(')
          ..write('key: $key, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('scanId: $scanId, ')
          ..write('ideaId: $ideaId, ')
          ..write('tutorialId: $tutorialId, ')
          ..write('step: $step, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    remoteUrl,
    localPath,
    kind,
    scanId,
    ideaId,
    tutorialId,
    step,
    width,
    height,
    byteSize,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCacheEntry &&
          other.key == this.key &&
          other.remoteUrl == this.remoteUrl &&
          other.localPath == this.localPath &&
          other.kind == this.kind &&
          other.scanId == this.scanId &&
          other.ideaId == this.ideaId &&
          other.tutorialId == this.tutorialId &&
          other.step == this.step &&
          other.width == this.width &&
          other.height == this.height &&
          other.byteSize == this.byteSize &&
          other.createdAt == this.createdAt);
}

class ImageCacheCompanion extends UpdateCompanion<ImageCacheEntry> {
  final Value<String> key;
  final Value<String> remoteUrl;
  final Value<String> localPath;
  final Value<String> kind;
  final Value<String?> scanId;
  final Value<String?> ideaId;
  final Value<String?> tutorialId;
  final Value<int?> step;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> byteSize;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ImageCacheCompanion({
    this.key = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.kind = const Value.absent(),
    this.scanId = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.tutorialId = const Value.absent(),
    this.step = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageCacheCompanion.insert({
    required String key,
    required String remoteUrl,
    required String localPath,
    required String kind,
    this.scanId = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.tutorialId = const Value.absent(),
    this.step = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int byteSize,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       remoteUrl = Value(remoteUrl),
       localPath = Value(localPath),
       kind = Value(kind),
       byteSize = Value(byteSize),
       createdAt = Value(createdAt);
  static Insertable<ImageCacheEntry> custom({
    Expression<String>? key,
    Expression<String>? remoteUrl,
    Expression<String>? localPath,
    Expression<String>? kind,
    Expression<String>? scanId,
    Expression<String>? ideaId,
    Expression<String>? tutorialId,
    Expression<int>? step,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? byteSize,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (localPath != null) 'local_path': localPath,
      if (kind != null) 'kind': kind,
      if (scanId != null) 'scan_id': scanId,
      if (ideaId != null) 'idea_id': ideaId,
      if (tutorialId != null) 'tutorial_id': tutorialId,
      if (step != null) 'step': step,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (byteSize != null) 'byte_size': byteSize,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? remoteUrl,
    Value<String>? localPath,
    Value<String>? kind,
    Value<String?>? scanId,
    Value<String?>? ideaId,
    Value<String?>? tutorialId,
    Value<int?>? step,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? byteSize,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ImageCacheCompanion(
      key: key ?? this.key,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      kind: kind ?? this.kind,
      scanId: scanId ?? this.scanId,
      ideaId: ideaId ?? this.ideaId,
      tutorialId: tutorialId ?? this.tutorialId,
      step: step ?? this.step,
      width: width ?? this.width,
      height: height ?? this.height,
      byteSize: byteSize ?? this.byteSize,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<String>(scanId.value);
    }
    if (ideaId.present) {
      map['idea_id'] = Variable<String>(ideaId.value);
    }
    if (tutorialId.present) {
      map['tutorial_id'] = Variable<String>(tutorialId.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheCompanion(')
          ..write('key: $key, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('scanId: $scanId, ')
          ..write('ideaId: $ideaId, ')
          ..write('tutorialId: $tutorialId, ')
          ..write('step: $step, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScansTable scans = $ScansTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ImpactEventsTable impactEvents = $ImpactEventsTable(this);
  late final $ImageCacheTable imageCache = $ImageCacheTable(this);
  late final Index scansCreatedAt = Index(
    'scans_created_at',
    'CREATE INDEX scans_created_at ON scans (created_at)',
  );
  late final Index projectsScanId = Index(
    'projects_scan_id',
    'CREATE INDEX projects_scan_id ON projects (scan_id)',
  );
  late final Index impactEventsCreatedAt = Index(
    'impact_events_created_at',
    'CREATE INDEX impact_events_created_at ON impact_events (created_at)',
  );
  late final Index imageCacheScan = Index(
    'image_cache_scan',
    'CREATE INDEX image_cache_scan ON image_cache (scan_id, idea_id)',
  );
  late final Index imageCacheStep = Index(
    'image_cache_step',
    'CREATE INDEX image_cache_step ON image_cache (tutorial_id, step)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scans,
    projects,
    impactEvents,
    imageCache,
    scansCreatedAt,
    projectsScanId,
    impactEventsCreatedAt,
    imageCacheScan,
    imageCacheStep,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('projects', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ScansTableCreateCompanionBuilder =
    ScansCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String source,
      required String lang,
      Value<String?> inputText,
      Value<String?> localImagePath,
      Value<String?> imageId,
      Value<String?> imageUrl,
      Value<String?> title,
      Value<String?> primaryCategory,
      Value<int> itemCount,
      Value<String?> analysisJson,
      Value<String?> recommendationJson,
      Value<String?> facilitiesJson,
      Value<String> stagesJson,
      Value<String?> focusItemId,
      Value<int> rowid,
    });
typedef $$ScansTableUpdateCompanionBuilder =
    ScansCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> source,
      Value<String> lang,
      Value<String?> inputText,
      Value<String?> localImagePath,
      Value<String?> imageId,
      Value<String?> imageUrl,
      Value<String?> title,
      Value<String?> primaryCategory,
      Value<int> itemCount,
      Value<String?> analysisJson,
      Value<String?> recommendationJson,
      Value<String?> facilitiesJson,
      Value<String> stagesJson,
      Value<String?> focusItemId,
      Value<int> rowid,
    });

final class $$ScansTableReferences
    extends BaseReferences<_$AppDatabase, $ScansTable, Scan> {
  $$ScansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: 'scans__id__projects__scan_id',
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScansTableFilterComposer extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputText => $composableBuilder(
    column: $table.inputText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendationJson => $composableBuilder(
    column: $table.recommendationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focusItemId => $composableBuilder(
    column: $table.focusItemId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScansTableOrderingComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputText => $composableBuilder(
    column: $table.inputText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendationJson => $composableBuilder(
    column: $table.recommendationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focusItemId => $composableBuilder(
    column: $table.focusItemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScansTable> {
  $$ScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get inputText =>
      $composableBuilder(column: $table.inputText, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageId =>
      $composableBuilder(column: $table.imageId, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get primaryCategory => $composableBuilder(
    column: $table.primaryCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendationJson => $composableBuilder(
    column: $table.recommendationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get focusItemId => $composableBuilder(
    column: $table.focusItemId,
    builder: (column) => column,
  );

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScansTable,
          Scan,
          $$ScansTableFilterComposer,
          $$ScansTableOrderingComposer,
          $$ScansTableAnnotationComposer,
          $$ScansTableCreateCompanionBuilder,
          $$ScansTableUpdateCompanionBuilder,
          (Scan, $$ScansTableReferences),
          Scan,
          PrefetchHooks Function({bool projectsRefs})
        > {
  $$ScansTableTableManager(_$AppDatabase db, $ScansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String?> inputText = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> imageId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> primaryCategory = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<String?> analysisJson = const Value.absent(),
                Value<String?> recommendationJson = const Value.absent(),
                Value<String?> facilitiesJson = const Value.absent(),
                Value<String> stagesJson = const Value.absent(),
                Value<String?> focusItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                lang: lang,
                inputText: inputText,
                localImagePath: localImagePath,
                imageId: imageId,
                imageUrl: imageUrl,
                title: title,
                primaryCategory: primaryCategory,
                itemCount: itemCount,
                analysisJson: analysisJson,
                recommendationJson: recommendationJson,
                facilitiesJson: facilitiesJson,
                stagesJson: stagesJson,
                focusItemId: focusItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String source,
                required String lang,
                Value<String?> inputText = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> imageId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> primaryCategory = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<String?> analysisJson = const Value.absent(),
                Value<String?> recommendationJson = const Value.absent(),
                Value<String?> facilitiesJson = const Value.absent(),
                Value<String> stagesJson = const Value.absent(),
                Value<String?> focusItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                source: source,
                lang: lang,
                inputText: inputText,
                localImagePath: localImagePath,
                imageId: imageId,
                imageUrl: imageUrl,
                title: title,
                primaryCategory: primaryCategory,
                itemCount: itemCount,
                analysisJson: analysisJson,
                recommendationJson: recommendationJson,
                facilitiesJson: facilitiesJson,
                stagesJson: stagesJson,
                focusItemId: focusItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ScansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectsRefs) db.projects],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsRefs)
                    await $_getPrefetchedData<Scan, $ScansTable, Project>(
                      currentTable: table,
                      referencedTable: $$ScansTableReferences
                          ._projectsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScansTableReferences(db, table, p0).projectsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.scanId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScansTable,
      Scan,
      $$ScansTableFilterComposer,
      $$ScansTableOrderingComposer,
      $$ScansTableAnnotationComposer,
      $$ScansTableCreateCompanionBuilder,
      $$ScansTableUpdateCompanionBuilder,
      (Scan, $$ScansTableReferences),
      Scan,
      PrefetchHooks Function({bool projectsRefs})
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String scanId,
      required String ideaId,
      required String title,
      required String ideaJson,
      Value<String?> tutorialId,
      Value<String?> tutorialJson,
      Value<String?> skill,
      Value<String> tools,
      Value<int> totalSteps,
      Value<int> currentStep,
      Value<String> completedSteps,
      required ProjectStatus status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> scanId,
      Value<String> ideaId,
      Value<String> title,
      Value<String> ideaJson,
      Value<String?> tutorialId,
      Value<String?> tutorialJson,
      Value<String?> skill,
      Value<String> tools,
      Value<int> totalSteps,
      Value<int> currentStep,
      Value<String> completedSteps,
      Value<ProjectStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScansTable _scanIdTable(_$AppDatabase db) =>
      db.scans.createAlias('projects__scan_id__scans__id');

  $$ScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<String>('scan_id')!;

    final manager = $$ScansTableTableManager(
      $_db,
      $_db.scans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ideaJson => $composableBuilder(
    column: $table.ideaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutorialJson => $composableBuilder(
    column: $table.tutorialJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProjectStatus, ProjectStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScansTableFilterComposer get scanId {
    final $$ScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableFilterComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ideaJson => $composableBuilder(
    column: $table.ideaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutorialJson => $composableBuilder(
    column: $table.tutorialJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScansTableOrderingComposer get scanId {
    final $$ScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableOrderingComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ideaId =>
      $composableBuilder(column: $table.ideaId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get ideaJson =>
      $composableBuilder(column: $table.ideaJson, builder: (column) => column);

  GeneratedColumn<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tutorialJson => $composableBuilder(
    column: $table.tutorialJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<String> get tools =>
      $composableBuilder(column: $table.tools, builder: (column) => column);

  GeneratedColumn<int> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedSteps => $composableBuilder(
    column: $table.completedSteps,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProjectStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$ScansTableAnnotationComposer get scanId {
    final $$ScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.scans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScansTableAnnotationComposer(
            $db: $db,
            $table: $db.scans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool scanId})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scanId = const Value.absent(),
                Value<String> ideaId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> ideaJson = const Value.absent(),
                Value<String?> tutorialId = const Value.absent(),
                Value<String?> tutorialJson = const Value.absent(),
                Value<String?> skill = const Value.absent(),
                Value<String> tools = const Value.absent(),
                Value<int> totalSteps = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> completedSteps = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                scanId: scanId,
                ideaId: ideaId,
                title: title,
                ideaJson: ideaJson,
                tutorialId: tutorialId,
                tutorialJson: tutorialJson,
                skill: skill,
                tools: tools,
                totalSteps: totalSteps,
                currentStep: currentStep,
                completedSteps: completedSteps,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scanId,
                required String ideaId,
                required String title,
                required String ideaJson,
                Value<String?> tutorialId = const Value.absent(),
                Value<String?> tutorialJson = const Value.absent(),
                Value<String?> skill = const Value.absent(),
                Value<String> tools = const Value.absent(),
                Value<int> totalSteps = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> completedSteps = const Value.absent(),
                required ProjectStatus status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                scanId: scanId,
                ideaId: ideaId,
                title: title,
                ideaJson: ideaJson,
                tutorialId: tutorialId,
                tutorialJson: tutorialJson,
                skill: skill,
                tools: tools,
                totalSteps: totalSteps,
                currentStep: currentStep,
                completedSteps: completedSteps,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$ProjectsTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$ProjectsTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool scanId})
    >;
typedef $$ImpactEventsTableCreateCompanionBuilder =
    ImpactEventsCompanion Function({
      Value<int> id,
      required String dedupeKey,
      required ImpactKind kind,
      required String material,
      required String itemName,
      Value<double> quantity,
      Value<String> unit,
      Value<String?> scanId,
      Value<String?> projectId,
      Value<String?> itemId,
      required DateTime createdAt,
    });
typedef $$ImpactEventsTableUpdateCompanionBuilder =
    ImpactEventsCompanion Function({
      Value<int> id,
      Value<String> dedupeKey,
      Value<ImpactKind> kind,
      Value<String> material,
      Value<String> itemName,
      Value<double> quantity,
      Value<String> unit,
      Value<String?> scanId,
      Value<String?> projectId,
      Value<String?> itemId,
      Value<DateTime> createdAt,
    });

class $$ImpactEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ImpactEventsTable> {
  $$ImpactEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ImpactKind, ImpactKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImpactEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImpactEventsTable> {
  $$ImpactEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImpactEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImpactEventsTable> {
  $$ImpactEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ImpactKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get scanId =>
      $composableBuilder(column: $table.scanId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ImpactEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImpactEventsTable,
          ImpactEvent,
          $$ImpactEventsTableFilterComposer,
          $$ImpactEventsTableOrderingComposer,
          $$ImpactEventsTableAnnotationComposer,
          $$ImpactEventsTableCreateCompanionBuilder,
          $$ImpactEventsTableUpdateCompanionBuilder,
          (
            ImpactEvent,
            BaseReferences<_$AppDatabase, $ImpactEventsTable, ImpactEvent>,
          ),
          ImpactEvent,
          PrefetchHooks Function()
        > {
  $$ImpactEventsTableTableManager(_$AppDatabase db, $ImpactEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpactEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpactEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImpactEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<ImpactKind> kind = const Value.absent(),
                Value<String> material = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> scanId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ImpactEventsCompanion(
                id: id,
                dedupeKey: dedupeKey,
                kind: kind,
                material: material,
                itemName: itemName,
                quantity: quantity,
                unit: unit,
                scanId: scanId,
                projectId: projectId,
                itemId: itemId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dedupeKey,
                required ImpactKind kind,
                required String material,
                required String itemName,
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> scanId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                required DateTime createdAt,
              }) => ImpactEventsCompanion.insert(
                id: id,
                dedupeKey: dedupeKey,
                kind: kind,
                material: material,
                itemName: itemName,
                quantity: quantity,
                unit: unit,
                scanId: scanId,
                projectId: projectId,
                itemId: itemId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImpactEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImpactEventsTable,
      ImpactEvent,
      $$ImpactEventsTableFilterComposer,
      $$ImpactEventsTableOrderingComposer,
      $$ImpactEventsTableAnnotationComposer,
      $$ImpactEventsTableCreateCompanionBuilder,
      $$ImpactEventsTableUpdateCompanionBuilder,
      (
        ImpactEvent,
        BaseReferences<_$AppDatabase, $ImpactEventsTable, ImpactEvent>,
      ),
      ImpactEvent,
      PrefetchHooks Function()
    >;
typedef $$ImageCacheTableCreateCompanionBuilder =
    ImageCacheCompanion Function({
      required String key,
      required String remoteUrl,
      required String localPath,
      required String kind,
      Value<String?> scanId,
      Value<String?> ideaId,
      Value<String?> tutorialId,
      Value<int?> step,
      Value<int?> width,
      Value<int?> height,
      required int byteSize,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ImageCacheTableUpdateCompanionBuilder =
    ImageCacheCompanion Function({
      Value<String> key,
      Value<String> remoteUrl,
      Value<String> localPath,
      Value<String> kind,
      Value<String?> scanId,
      Value<String?> ideaId,
      Value<String?> tutorialId,
      Value<int?> step,
      Value<int?> width,
      Value<int?> height,
      Value<int> byteSize,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ImageCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImageCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get scanId =>
      $composableBuilder(column: $table.scanId, builder: (column) => column);

  GeneratedColumn<String> get ideaId =>
      $composableBuilder(column: $table.ideaId, builder: (column) => column);

  GeneratedColumn<String> get tutorialId => $composableBuilder(
    column: $table.tutorialId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ImageCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageCacheTable,
          ImageCacheEntry,
          $$ImageCacheTableFilterComposer,
          $$ImageCacheTableOrderingComposer,
          $$ImageCacheTableAnnotationComposer,
          $$ImageCacheTableCreateCompanionBuilder,
          $$ImageCacheTableUpdateCompanionBuilder,
          (
            ImageCacheEntry,
            BaseReferences<_$AppDatabase, $ImageCacheTable, ImageCacheEntry>,
          ),
          ImageCacheEntry,
          PrefetchHooks Function()
        > {
  $$ImageCacheTableTableManager(_$AppDatabase db, $ImageCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> remoteUrl = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> scanId = const Value.absent(),
                Value<String?> ideaId = const Value.absent(),
                Value<String?> tutorialId = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageCacheCompanion(
                key: key,
                remoteUrl: remoteUrl,
                localPath: localPath,
                kind: kind,
                scanId: scanId,
                ideaId: ideaId,
                tutorialId: tutorialId,
                step: step,
                width: width,
                height: height,
                byteSize: byteSize,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String remoteUrl,
                required String localPath,
                required String kind,
                Value<String?> scanId = const Value.absent(),
                Value<String?> ideaId = const Value.absent(),
                Value<String?> tutorialId = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int byteSize,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ImageCacheCompanion.insert(
                key: key,
                remoteUrl: remoteUrl,
                localPath: localPath,
                kind: kind,
                scanId: scanId,
                ideaId: ideaId,
                tutorialId: tutorialId,
                step: step,
                width: width,
                height: height,
                byteSize: byteSize,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImageCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageCacheTable,
      ImageCacheEntry,
      $$ImageCacheTableFilterComposer,
      $$ImageCacheTableOrderingComposer,
      $$ImageCacheTableAnnotationComposer,
      $$ImageCacheTableCreateCompanionBuilder,
      $$ImageCacheTableUpdateCompanionBuilder,
      (
        ImageCacheEntry,
        BaseReferences<_$AppDatabase, $ImageCacheTable, ImageCacheEntry>,
      ),
      ImageCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScansTableTableManager get scans =>
      $$ScansTableTableManager(_db, _db.scans);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ImpactEventsTableTableManager get impactEvents =>
      $$ImpactEventsTableTableManager(_db, _db.impactEvents);
  $$ImageCacheTableTableManager get imageCache =>
      $$ImageCacheTableTableManager(_db, _db.imageCache);
}
