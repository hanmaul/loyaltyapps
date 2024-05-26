// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBannerCollection on Isar {
  IsarCollection<Banner> get banners => this.collection();
}

const BannerSchema = CollectionSchema(
  name: r'Banner',
  id: -3303966106017987544,
  properties: {
    r'gambar': PropertySchema(
      id: 0,
      name: r'gambar',
      type: IsarType.string,
    )
  },
  estimateSize: _bannerEstimateSize,
  serialize: _bannerSerialize,
  deserialize: _bannerDeserialize,
  deserializeProp: _bannerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _bannerGetId,
  getLinks: _bannerGetLinks,
  attach: _bannerAttach,
  version: '3.1.0+1',
);

int _bannerEstimateSize(
  Banner object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.gambar.length * 3;
  return bytesCount;
}

void _bannerSerialize(
  Banner object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.gambar);
}

Banner _bannerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Banner(
    gambar: reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _bannerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bannerGetId(Banner object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bannerGetLinks(Banner object) {
  return [];
}

void _bannerAttach(IsarCollection<dynamic> col, Id id, Banner object) {
  object.id = id;
}

extension BannerQueryWhereSort on QueryBuilder<Banner, Banner, QWhere> {
  QueryBuilder<Banner, Banner, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BannerQueryWhere on QueryBuilder<Banner, Banner, QWhereClause> {
  QueryBuilder<Banner, Banner, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Banner, Banner, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Banner, Banner, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Banner, Banner, QAfterWhereClause> idBetween(
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
}

extension BannerQueryFilter on QueryBuilder<Banner, Banner, QFilterCondition> {
  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gambar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gambar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gambar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gambar',
        value: '',
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> gambarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gambar',
        value: '',
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Banner, Banner, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Banner, Banner, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Banner, Banner, QAfterFilterCondition> idBetween(
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
}

extension BannerQueryObject on QueryBuilder<Banner, Banner, QFilterCondition> {}

extension BannerQueryLinks on QueryBuilder<Banner, Banner, QFilterCondition> {}

extension BannerQuerySortBy on QueryBuilder<Banner, Banner, QSortBy> {
  QueryBuilder<Banner, Banner, QAfterSortBy> sortByGambar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gambar', Sort.asc);
    });
  }

  QueryBuilder<Banner, Banner, QAfterSortBy> sortByGambarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gambar', Sort.desc);
    });
  }
}

extension BannerQuerySortThenBy on QueryBuilder<Banner, Banner, QSortThenBy> {
  QueryBuilder<Banner, Banner, QAfterSortBy> thenByGambar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gambar', Sort.asc);
    });
  }

  QueryBuilder<Banner, Banner, QAfterSortBy> thenByGambarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gambar', Sort.desc);
    });
  }

  QueryBuilder<Banner, Banner, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Banner, Banner, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension BannerQueryWhereDistinct on QueryBuilder<Banner, Banner, QDistinct> {
  QueryBuilder<Banner, Banner, QDistinct> distinctByGambar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gambar', caseSensitive: caseSensitive);
    });
  }
}

extension BannerQueryProperty on QueryBuilder<Banner, Banner, QQueryProperty> {
  QueryBuilder<Banner, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Banner, String, QQueryOperations> gambarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gambar');
    });
  }
}
