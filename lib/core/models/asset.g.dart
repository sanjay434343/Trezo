// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssetCollection on Isar {
  IsarCollection<Asset> get assets => this.collection();
}

const AssetSchema = CollectionSchema(
  name: r'Asset',
  id: -2933289051367723566,
  properties: {
    r'brand': PropertySchema(
      id: 0,
      name: r'brand',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customReminderDate': PropertySchema(
      id: 3,
      name: r'customReminderDate',
      type: IsarType.dateTime,
    ),
    r'customReminderEnabled': PropertySchema(
      id: 4,
      name: r'customReminderEnabled',
      type: IsarType.bool,
    ),
    r'documentName': PropertySchema(
      id: 5,
      name: r'documentName',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 6,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'iconCodePoint': PropertySchema(
      id: 7,
      name: r'iconCodePoint',
      type: IsarType.long,
    ),
    r'iconFontFamily': PropertySchema(
      id: 8,
      name: r'iconFontFamily',
      type: IsarType.string,
    ),
    r'iconFontPackage': PropertySchema(
      id: 9,
      name: r'iconFontPackage',
      type: IsarType.string,
    ),
    r'indexEndDate': PropertySchema(
      id: 10,
      name: r'indexEndDate',
      type: IsarType.dateTime,
    ),
    r'indexIsDeleted': PropertySchema(
      id: 11,
      name: r'indexIsDeleted',
      type: IsarType.bool,
    ),
    r'isAvailable': PropertySchema(
      id: 12,
      name: r'isAvailable',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 13,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 15,
      name: r'notes',
      type: IsarType.string,
    ),
    r'price': PropertySchema(
      id: 16,
      name: r'price',
      type: IsarType.double,
    ),
    r'reminderOnDay': PropertySchema(
      id: 17,
      name: r'reminderOnDay',
      type: IsarType.bool,
    ),
    r'reminderOneDay': PropertySchema(
      id: 18,
      name: r'reminderOneDay',
      type: IsarType.bool,
    ),
    r'reminderOneMonth': PropertySchema(
      id: 19,
      name: r'reminderOneMonth',
      type: IsarType.bool,
    ),
    r'reminderOneWeek': PropertySchema(
      id: 20,
      name: r'reminderOneWeek',
      type: IsarType.bool,
    ),
    r'reminderSentDays': PropertySchema(
      id: 21,
      name: r'reminderSentDays',
      type: IsarType.longList,
    ),
    r'scannedRawText': PropertySchema(
      id: 22,
      name: r'scannedRawText',
      type: IsarType.string,
    ),
    r'serial': PropertySchema(
      id: 23,
      name: r'serial',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 24,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 25,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _assetEstimateSize,
  serialize: _assetSerialize,
  deserialize: _assetDeserialize,
  deserializeProp: _assetDeserializeProp,
  idName: r'id',
  indexes: {
    r'indexEndDate': IndexSchema(
      id: -1386288141018432289,
      name: r'indexEndDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'indexEndDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'indexIsDeleted': IndexSchema(
      id: 4082632551403552213,
      name: r'indexIsDeleted',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'indexIsDeleted',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _assetGetId,
  getLinks: _assetGetLinks,
  attach: _assetAttach,
  version: '3.1.0+1',
);

int _assetEstimateSize(
  Asset object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.brand.length * 3;
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.documentName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.iconFontFamily.length * 3;
  {
    final value = object.iconFontPackage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reminderSentDays.length * 8;
  {
    final value = object.scannedRawText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serial.length * 3;
  return bytesCount;
}

void _assetSerialize(
  Asset object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.brand);
  writer.writeString(offsets[1], object.category);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.customReminderDate);
  writer.writeBool(offsets[4], object.customReminderEnabled);
  writer.writeString(offsets[5], object.documentName);
  writer.writeDateTime(offsets[6], object.endDate);
  writer.writeLong(offsets[7], object.iconCodePoint);
  writer.writeString(offsets[8], object.iconFontFamily);
  writer.writeString(offsets[9], object.iconFontPackage);
  writer.writeDateTime(offsets[10], object.indexEndDate);
  writer.writeBool(offsets[11], object.indexIsDeleted);
  writer.writeBool(offsets[12], object.isAvailable);
  writer.writeBool(offsets[13], object.isDeleted);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.notes);
  writer.writeDouble(offsets[16], object.price);
  writer.writeBool(offsets[17], object.reminderOnDay);
  writer.writeBool(offsets[18], object.reminderOneDay);
  writer.writeBool(offsets[19], object.reminderOneMonth);
  writer.writeBool(offsets[20], object.reminderOneWeek);
  writer.writeLongList(offsets[21], object.reminderSentDays);
  writer.writeString(offsets[22], object.scannedRawText);
  writer.writeString(offsets[23], object.serial);
  writer.writeDateTime(offsets[24], object.startDate);
  writer.writeDateTime(offsets[25], object.updatedAt);
}

Asset _assetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Asset();
  object.brand = reader.readString(offsets[0]);
  object.category = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.customReminderDate = reader.readDateTimeOrNull(offsets[3]);
  object.customReminderEnabled = reader.readBool(offsets[4]);
  object.documentName = reader.readStringOrNull(offsets[5]);
  object.endDate = reader.readDateTimeOrNull(offsets[6]);
  object.iconCodePoint = reader.readLong(offsets[7]);
  object.iconFontFamily = reader.readString(offsets[8]);
  object.iconFontPackage = reader.readStringOrNull(offsets[9]);
  object.id = id;
  object.isAvailable = reader.readBool(offsets[12]);
  object.isDeleted = reader.readBool(offsets[13]);
  object.name = reader.readString(offsets[14]);
  object.notes = reader.readStringOrNull(offsets[15]);
  object.price = reader.readDouble(offsets[16]);
  object.reminderOnDay = reader.readBool(offsets[17]);
  object.reminderOneDay = reader.readBool(offsets[18]);
  object.reminderOneMonth = reader.readBool(offsets[19]);
  object.reminderOneWeek = reader.readBool(offsets[20]);
  object.reminderSentDays = reader.readLongList(offsets[21]) ?? [];
  object.scannedRawText = reader.readStringOrNull(offsets[22]);
  object.serial = reader.readString(offsets[23]);
  object.startDate = reader.readDateTimeOrNull(offsets[24]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[25]);
  return object;
}

P _assetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readLongList(offset) ?? []) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _assetGetId(Asset object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _assetGetLinks(Asset object) {
  return [];
}

void _assetAttach(IsarCollection<dynamic> col, Id id, Asset object) {
  object.id = id;
}

extension AssetQueryWhereSort on QueryBuilder<Asset, Asset, QWhere> {
  QueryBuilder<Asset, Asset, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhere> anyIndexEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'indexEndDate'),
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhere> anyIndexIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'indexIsDeleted'),
      );
    });
  }
}

extension AssetQueryWhere on QueryBuilder<Asset, Asset, QWhereClause> {
  QueryBuilder<Asset, Asset, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'indexEndDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexEndDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateEqualTo(
      DateTime? indexEndDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'indexEndDate',
        value: [indexEndDate],
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateNotEqualTo(
      DateTime? indexEndDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexEndDate',
              lower: [],
              upper: [indexEndDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexEndDate',
              lower: [indexEndDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexEndDate',
              lower: [indexEndDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexEndDate',
              lower: [],
              upper: [indexEndDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateGreaterThan(
    DateTime? indexEndDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexEndDate',
        lower: [indexEndDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateLessThan(
    DateTime? indexEndDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexEndDate',
        lower: [],
        upper: [indexEndDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexEndDateBetween(
    DateTime? lowerIndexEndDate,
    DateTime? upperIndexEndDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexEndDate',
        lower: [lowerIndexEndDate],
        includeLower: includeLower,
        upper: [upperIndexEndDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexIsDeletedEqualTo(
      bool indexIsDeleted) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'indexIsDeleted',
        value: [indexIsDeleted],
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterWhereClause> indexIsDeletedNotEqualTo(
      bool indexIsDeleted) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexIsDeleted',
              lower: [],
              upper: [indexIsDeleted],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexIsDeleted',
              lower: [indexIsDeleted],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexIsDeleted',
              lower: [indexIsDeleted],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexIsDeleted',
              lower: [],
              upper: [indexIsDeleted],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AssetQueryFilter on QueryBuilder<Asset, Asset, QFilterCondition> {
  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'brand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> brandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> customReminderDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customReminderDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      customReminderDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customReminderDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> customReminderDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customReminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      customReminderDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customReminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> customReminderDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customReminderDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> customReminderDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customReminderDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      customReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customReminderEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'documentName',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'documentName',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentName',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> documentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentName',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconCodePointEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconCodePointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconCodePointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconCodePointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCodePoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'iconFontPackage',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'iconFontPackage',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconFontPackage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconFontPackage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> iconFontPackageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      iconFontPackageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconFontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'indexEndDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'indexEndDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'indexEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'indexEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'indexEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'indexEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> indexIsDeletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'indexIsDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> isAvailableEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAvailable',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> isDeletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> priceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> priceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> priceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> priceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'price',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> reminderOnDayEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderOnDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> reminderOneDayEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderOneDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> reminderOneMonthEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderOneMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> reminderOneWeekEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderOneWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderSentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderSentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderSentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderSentDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> reminderSentDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition>
      reminderSentDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderSentDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scannedRawText',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scannedRawText',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scannedRawText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scannedRawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scannedRawText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scannedRawText',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> scannedRawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scannedRawText',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serial',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serial',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> serialIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serial',
        value: '',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Asset, Asset, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AssetQueryObject on QueryBuilder<Asset, Asset, QFilterCondition> {}

extension AssetQueryLinks on QueryBuilder<Asset, Asset, QFilterCondition> {}

extension AssetQuerySortBy on QueryBuilder<Asset, Asset, QSortBy> {
  QueryBuilder<Asset, Asset, QAfterSortBy> sortByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCustomReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCustomReminderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCustomReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByCustomReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByDocumentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentName', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByDocumentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentName', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconFontPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIconFontPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIndexEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexEndDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIndexEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexEndDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIndexIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexIsDeleted', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIndexIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexIsDeleted', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIsAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOnDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOnDay', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOnDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOnDay', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneDay', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneDay', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneMonth', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneMonth', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneWeek', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByReminderOneWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneWeek', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByScannedRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedRawText', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByScannedRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedRawText', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortBySerial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serial', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortBySerialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serial', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AssetQuerySortThenBy on QueryBuilder<Asset, Asset, QSortThenBy> {
  QueryBuilder<Asset, Asset, QAfterSortBy> thenByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCustomReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCustomReminderDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCustomReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByCustomReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByDocumentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentName', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByDocumentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentName', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconFontPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIconFontPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIndexEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexEndDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIndexEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexEndDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIndexIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexIsDeleted', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIndexIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexIsDeleted', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIsAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAvailable', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOnDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOnDay', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOnDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOnDay', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneDay', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneDay', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneMonth', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneMonth', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneWeek', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByReminderOneWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderOneWeek', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByScannedRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedRawText', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByScannedRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedRawText', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenBySerial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serial', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenBySerialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serial', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Asset, Asset, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AssetQueryWhereDistinct on QueryBuilder<Asset, Asset, QDistinct> {
  QueryBuilder<Asset, Asset, QDistinct> distinctByBrand(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByCustomReminderDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customReminderDate');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByCustomReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customReminderEnabled');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByDocumentName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCodePoint');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIconFontFamily(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIconFontPackage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconFontPackage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIndexEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexEndDate');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIndexIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexIsDeleted');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIsAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAvailable');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByReminderOnDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderOnDay');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByReminderOneDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderOneDay');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByReminderOneMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderOneMonth');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByReminderOneWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderOneWeek');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByReminderSentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderSentDays');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByScannedRawText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scannedRawText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctBySerial(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serial', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<Asset, Asset, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AssetQueryProperty on QueryBuilder<Asset, Asset, QQueryProperty> {
  QueryBuilder<Asset, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Asset, String, QQueryOperations> brandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brand');
    });
  }

  QueryBuilder<Asset, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Asset, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Asset, DateTime?, QQueryOperations>
      customReminderDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customReminderDate');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> customReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customReminderEnabled');
    });
  }

  QueryBuilder<Asset, String?, QQueryOperations> documentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentName');
    });
  }

  QueryBuilder<Asset, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<Asset, int, QQueryOperations> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCodePoint');
    });
  }

  QueryBuilder<Asset, String, QQueryOperations> iconFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconFontFamily');
    });
  }

  QueryBuilder<Asset, String?, QQueryOperations> iconFontPackageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconFontPackage');
    });
  }

  QueryBuilder<Asset, DateTime?, QQueryOperations> indexEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexEndDate');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> indexIsDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexIsDeleted');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> isAvailableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAvailable');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<Asset, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Asset, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Asset, double, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> reminderOnDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderOnDay');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> reminderOneDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderOneDay');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> reminderOneMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderOneMonth');
    });
  }

  QueryBuilder<Asset, bool, QQueryOperations> reminderOneWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderOneWeek');
    });
  }

  QueryBuilder<Asset, List<int>, QQueryOperations> reminderSentDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderSentDays');
    });
  }

  QueryBuilder<Asset, String?, QQueryOperations> scannedRawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scannedRawText');
    });
  }

  QueryBuilder<Asset, String, QQueryOperations> serialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serial');
    });
  }

  QueryBuilder<Asset, DateTime?, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<Asset, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
