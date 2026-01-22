// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AirportsTable extends Airports with TableInfo<$AirportsTable, Airport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AirportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _identMeta = const VerificationMeta('ident');
  @override
  late final GeneratedColumn<String> ident = GeneratedColumn<String>(
      'ident', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _icaoCodeMeta =
      const VerificationMeta('icaoCode');
  @override
  late final GeneratedColumn<String> icaoCode = GeneratedColumn<String>(
      'icao_code', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 4),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _iataCodeMeta =
      const VerificationMeta('iataCode');
  @override
  late final GeneratedColumn<String> iataCode = GeneratedColumn<String>(
      'iata_code', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _municipalityMeta =
      const VerificationMeta('municipality');
  @override
  late final GeneratedColumn<String> municipality = GeneratedColumn<String>(
      'municipality', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isoCountryMeta =
      const VerificationMeta('isoCountry');
  @override
  late final GeneratedColumn<String> isoCountry = GeneratedColumn<String>(
      'iso_country', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ident,
        icaoCode,
        iataCode,
        name,
        municipality,
        isoCountry,
        latitude,
        longitude,
        timezone
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'airports';
  @override
  VerificationContext validateIntegrity(Insertable<Airport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ident')) {
      context.handle(
          _identMeta, ident.isAcceptableOrUnknown(data['ident']!, _identMeta));
    } else if (isInserting) {
      context.missing(_identMeta);
    }
    if (data.containsKey('icao_code')) {
      context.handle(_icaoCodeMeta,
          icaoCode.isAcceptableOrUnknown(data['icao_code']!, _icaoCodeMeta));
    }
    if (data.containsKey('iata_code')) {
      context.handle(_iataCodeMeta,
          iataCode.isAcceptableOrUnknown(data['iata_code']!, _iataCodeMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('municipality')) {
      context.handle(
          _municipalityMeta,
          municipality.isAcceptableOrUnknown(
              data['municipality']!, _municipalityMeta));
    }
    if (data.containsKey('iso_country')) {
      context.handle(
          _isoCountryMeta,
          isoCountry.isAcceptableOrUnknown(
              data['iso_country']!, _isoCountryMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Airport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Airport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ident: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ident'])!,
      icaoCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icao_code']),
      iataCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iata_code']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      municipality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}municipality']),
      isoCountry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iso_country']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone']),
    );
  }

  @override
  $AirportsTable createAlias(String alias) {
    return $AirportsTable(attachedDatabase, alias);
  }
}

class Airport extends DataClass implements Insertable<Airport> {
  final int id;
  final String ident;
  final String? icaoCode;
  final String? iataCode;
  final String name;
  final String? municipality;
  final String? isoCountry;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  const Airport(
      {required this.id,
      required this.ident,
      this.icaoCode,
      this.iataCode,
      required this.name,
      this.municipality,
      this.isoCountry,
      this.latitude,
      this.longitude,
      this.timezone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ident'] = Variable<String>(ident);
    if (!nullToAbsent || icaoCode != null) {
      map['icao_code'] = Variable<String>(icaoCode);
    }
    if (!nullToAbsent || iataCode != null) {
      map['iata_code'] = Variable<String>(iataCode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || municipality != null) {
      map['municipality'] = Variable<String>(municipality);
    }
    if (!nullToAbsent || isoCountry != null) {
      map['iso_country'] = Variable<String>(isoCountry);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    return map;
  }

  AirportsCompanion toCompanion(bool nullToAbsent) {
    return AirportsCompanion(
      id: Value(id),
      ident: Value(ident),
      icaoCode: icaoCode == null && nullToAbsent
          ? const Value.absent()
          : Value(icaoCode),
      iataCode: iataCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iataCode),
      name: Value(name),
      municipality: municipality == null && nullToAbsent
          ? const Value.absent()
          : Value(municipality),
      isoCountry: isoCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(isoCountry),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
    );
  }

  factory Airport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Airport(
      id: serializer.fromJson<int>(json['id']),
      ident: serializer.fromJson<String>(json['ident']),
      icaoCode: serializer.fromJson<String?>(json['icaoCode']),
      iataCode: serializer.fromJson<String?>(json['iataCode']),
      name: serializer.fromJson<String>(json['name']),
      municipality: serializer.fromJson<String?>(json['municipality']),
      isoCountry: serializer.fromJson<String?>(json['isoCountry']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      timezone: serializer.fromJson<String?>(json['timezone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ident': serializer.toJson<String>(ident),
      'icaoCode': serializer.toJson<String?>(icaoCode),
      'iataCode': serializer.toJson<String?>(iataCode),
      'name': serializer.toJson<String>(name),
      'municipality': serializer.toJson<String?>(municipality),
      'isoCountry': serializer.toJson<String?>(isoCountry),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'timezone': serializer.toJson<String?>(timezone),
    };
  }

  Airport copyWith(
          {int? id,
          String? ident,
          Value<String?> icaoCode = const Value.absent(),
          Value<String?> iataCode = const Value.absent(),
          String? name,
          Value<String?> municipality = const Value.absent(),
          Value<String?> isoCountry = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> timezone = const Value.absent()}) =>
      Airport(
        id: id ?? this.id,
        ident: ident ?? this.ident,
        icaoCode: icaoCode.present ? icaoCode.value : this.icaoCode,
        iataCode: iataCode.present ? iataCode.value : this.iataCode,
        name: name ?? this.name,
        municipality:
            municipality.present ? municipality.value : this.municipality,
        isoCountry: isoCountry.present ? isoCountry.value : this.isoCountry,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        timezone: timezone.present ? timezone.value : this.timezone,
      );
  Airport copyWithCompanion(AirportsCompanion data) {
    return Airport(
      id: data.id.present ? data.id.value : this.id,
      ident: data.ident.present ? data.ident.value : this.ident,
      icaoCode: data.icaoCode.present ? data.icaoCode.value : this.icaoCode,
      iataCode: data.iataCode.present ? data.iataCode.value : this.iataCode,
      name: data.name.present ? data.name.value : this.name,
      municipality: data.municipality.present
          ? data.municipality.value
          : this.municipality,
      isoCountry:
          data.isoCountry.present ? data.isoCountry.value : this.isoCountry,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Airport(')
          ..write('id: $id, ')
          ..write('ident: $ident, ')
          ..write('icaoCode: $icaoCode, ')
          ..write('iataCode: $iataCode, ')
          ..write('name: $name, ')
          ..write('municipality: $municipality, ')
          ..write('isoCountry: $isoCountry, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timezone: $timezone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ident, icaoCode, iataCode, name,
      municipality, isoCountry, latitude, longitude, timezone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Airport &&
          other.id == this.id &&
          other.ident == this.ident &&
          other.icaoCode == this.icaoCode &&
          other.iataCode == this.iataCode &&
          other.name == this.name &&
          other.municipality == this.municipality &&
          other.isoCountry == this.isoCountry &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timezone == this.timezone);
}

class AirportsCompanion extends UpdateCompanion<Airport> {
  final Value<int> id;
  final Value<String> ident;
  final Value<String?> icaoCode;
  final Value<String?> iataCode;
  final Value<String> name;
  final Value<String?> municipality;
  final Value<String?> isoCountry;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> timezone;
  const AirportsCompanion({
    this.id = const Value.absent(),
    this.ident = const Value.absent(),
    this.icaoCode = const Value.absent(),
    this.iataCode = const Value.absent(),
    this.name = const Value.absent(),
    this.municipality = const Value.absent(),
    this.isoCountry = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timezone = const Value.absent(),
  });
  AirportsCompanion.insert({
    this.id = const Value.absent(),
    required String ident,
    this.icaoCode = const Value.absent(),
    this.iataCode = const Value.absent(),
    required String name,
    this.municipality = const Value.absent(),
    this.isoCountry = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timezone = const Value.absent(),
  })  : ident = Value(ident),
        name = Value(name);
  static Insertable<Airport> custom({
    Expression<int>? id,
    Expression<String>? ident,
    Expression<String>? icaoCode,
    Expression<String>? iataCode,
    Expression<String>? name,
    Expression<String>? municipality,
    Expression<String>? isoCountry,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? timezone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ident != null) 'ident': ident,
      if (icaoCode != null) 'icao_code': icaoCode,
      if (iataCode != null) 'iata_code': iataCode,
      if (name != null) 'name': name,
      if (municipality != null) 'municipality': municipality,
      if (isoCountry != null) 'iso_country': isoCountry,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timezone != null) 'timezone': timezone,
    });
  }

  AirportsCompanion copyWith(
      {Value<int>? id,
      Value<String>? ident,
      Value<String?>? icaoCode,
      Value<String?>? iataCode,
      Value<String>? name,
      Value<String?>? municipality,
      Value<String?>? isoCountry,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? timezone}) {
    return AirportsCompanion(
      id: id ?? this.id,
      ident: ident ?? this.ident,
      icaoCode: icaoCode ?? this.icaoCode,
      iataCode: iataCode ?? this.iataCode,
      name: name ?? this.name,
      municipality: municipality ?? this.municipality,
      isoCountry: isoCountry ?? this.isoCountry,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ident.present) {
      map['ident'] = Variable<String>(ident.value);
    }
    if (icaoCode.present) {
      map['icao_code'] = Variable<String>(icaoCode.value);
    }
    if (iataCode.present) {
      map['iata_code'] = Variable<String>(iataCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (municipality.present) {
      map['municipality'] = Variable<String>(municipality.value);
    }
    if (isoCountry.present) {
      map['iso_country'] = Variable<String>(isoCountry.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AirportsCompanion(')
          ..write('id: $id, ')
          ..write('ident: $ident, ')
          ..write('icaoCode: $icaoCode, ')
          ..write('iataCode: $iataCode, ')
          ..write('name: $name, ')
          ..write('municipality: $municipality, ')
          ..write('isoCountry: $isoCountry, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timezone: $timezone')
          ..write(')'))
        .toString();
  }
}

class $AircraftTypesTable extends AircraftTypes
    with TableInfo<$AircraftTypesTable, AircraftType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AircraftTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _icaoDesignatorMeta =
      const VerificationMeta('icaoDesignator');
  @override
  late final GeneratedColumn<String> icaoDesignator = GeneratedColumn<String>(
      'icao_designator', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _engineCountMeta =
      const VerificationMeta('engineCount');
  @override
  late final GeneratedColumn<int> engineCount = GeneratedColumn<int>(
      'engine_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _engineTypeMeta =
      const VerificationMeta('engineType');
  @override
  late final GeneratedColumn<String> engineType = GeneratedColumn<String>(
      'engine_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wtcMeta = const VerificationMeta('wtc');
  @override
  late final GeneratedColumn<String> wtc = GeneratedColumn<String>(
      'wtc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _multiPilotMeta =
      const VerificationMeta('multiPilot');
  @override
  late final GeneratedColumn<bool> multiPilot = GeneratedColumn<bool>(
      'multi_pilot', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("multi_pilot" IN (0, 1))'));
  static const VerificationMeta _complexMeta =
      const VerificationMeta('complex');
  @override
  late final GeneratedColumn<bool> complex = GeneratedColumn<bool>(
      'complex', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("complex" IN (0, 1))'));
  static const VerificationMeta _highPerformanceMeta =
      const VerificationMeta('highPerformance');
  @override
  late final GeneratedColumn<bool> highPerformance = GeneratedColumn<bool>(
      'high_performance', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("high_performance" IN (0, 1))'));
  static const VerificationMeta _retractableGearMeta =
      const VerificationMeta('retractableGear');
  @override
  late final GeneratedColumn<bool> retractableGear = GeneratedColumn<bool>(
      'retractable_gear', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("retractable_gear" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        icaoDesignator,
        manufacturer,
        model,
        category,
        engineCount,
        engineType,
        wtc,
        multiPilot,
        complex,
        highPerformance,
        retractableGear
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aircraft_types';
  @override
  VerificationContext validateIntegrity(Insertable<AircraftType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('icao_designator')) {
      context.handle(
          _icaoDesignatorMeta,
          icaoDesignator.isAcceptableOrUnknown(
              data['icao_designator']!, _icaoDesignatorMeta));
    } else if (isInserting) {
      context.missing(_icaoDesignatorMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('engine_count')) {
      context.handle(
          _engineCountMeta,
          engineCount.isAcceptableOrUnknown(
              data['engine_count']!, _engineCountMeta));
    } else if (isInserting) {
      context.missing(_engineCountMeta);
    }
    if (data.containsKey('engine_type')) {
      context.handle(
          _engineTypeMeta,
          engineType.isAcceptableOrUnknown(
              data['engine_type']!, _engineTypeMeta));
    } else if (isInserting) {
      context.missing(_engineTypeMeta);
    }
    if (data.containsKey('wtc')) {
      context.handle(
          _wtcMeta, wtc.isAcceptableOrUnknown(data['wtc']!, _wtcMeta));
    }
    if (data.containsKey('multi_pilot')) {
      context.handle(
          _multiPilotMeta,
          multiPilot.isAcceptableOrUnknown(
              data['multi_pilot']!, _multiPilotMeta));
    }
    if (data.containsKey('complex')) {
      context.handle(_complexMeta,
          complex.isAcceptableOrUnknown(data['complex']!, _complexMeta));
    }
    if (data.containsKey('high_performance')) {
      context.handle(
          _highPerformanceMeta,
          highPerformance.isAcceptableOrUnknown(
              data['high_performance']!, _highPerformanceMeta));
    }
    if (data.containsKey('retractable_gear')) {
      context.handle(
          _retractableGearMeta,
          retractableGear.isAcceptableOrUnknown(
              data['retractable_gear']!, _retractableGearMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AircraftType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AircraftType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      icaoDesignator: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icao_designator'])!,
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      engineCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}engine_count'])!,
      engineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}engine_type'])!,
      wtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wtc']),
      multiPilot: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}multi_pilot']),
      complex: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}complex']),
      highPerformance: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}high_performance']),
      retractableGear: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}retractable_gear']),
    );
  }

  @override
  $AircraftTypesTable createAlias(String alias) {
    return $AircraftTypesTable(attachedDatabase, alias);
  }
}

class AircraftType extends DataClass implements Insertable<AircraftType> {
  final int id;
  final String icaoDesignator;
  final String manufacturer;
  final String model;
  final String category;
  final int engineCount;
  final String engineType;
  final String? wtc;
  final bool? multiPilot;
  final bool? complex;
  final bool? highPerformance;
  final bool? retractableGear;
  const AircraftType(
      {required this.id,
      required this.icaoDesignator,
      required this.manufacturer,
      required this.model,
      required this.category,
      required this.engineCount,
      required this.engineType,
      this.wtc,
      this.multiPilot,
      this.complex,
      this.highPerformance,
      this.retractableGear});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['icao_designator'] = Variable<String>(icaoDesignator);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['model'] = Variable<String>(model);
    map['category'] = Variable<String>(category);
    map['engine_count'] = Variable<int>(engineCount);
    map['engine_type'] = Variable<String>(engineType);
    if (!nullToAbsent || wtc != null) {
      map['wtc'] = Variable<String>(wtc);
    }
    if (!nullToAbsent || multiPilot != null) {
      map['multi_pilot'] = Variable<bool>(multiPilot);
    }
    if (!nullToAbsent || complex != null) {
      map['complex'] = Variable<bool>(complex);
    }
    if (!nullToAbsent || highPerformance != null) {
      map['high_performance'] = Variable<bool>(highPerformance);
    }
    if (!nullToAbsent || retractableGear != null) {
      map['retractable_gear'] = Variable<bool>(retractableGear);
    }
    return map;
  }

  AircraftTypesCompanion toCompanion(bool nullToAbsent) {
    return AircraftTypesCompanion(
      id: Value(id),
      icaoDesignator: Value(icaoDesignator),
      manufacturer: Value(manufacturer),
      model: Value(model),
      category: Value(category),
      engineCount: Value(engineCount),
      engineType: Value(engineType),
      wtc: wtc == null && nullToAbsent ? const Value.absent() : Value(wtc),
      multiPilot: multiPilot == null && nullToAbsent
          ? const Value.absent()
          : Value(multiPilot),
      complex: complex == null && nullToAbsent
          ? const Value.absent()
          : Value(complex),
      highPerformance: highPerformance == null && nullToAbsent
          ? const Value.absent()
          : Value(highPerformance),
      retractableGear: retractableGear == null && nullToAbsent
          ? const Value.absent()
          : Value(retractableGear),
    );
  }

  factory AircraftType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AircraftType(
      id: serializer.fromJson<int>(json['id']),
      icaoDesignator: serializer.fromJson<String>(json['icaoDesignator']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      model: serializer.fromJson<String>(json['model']),
      category: serializer.fromJson<String>(json['category']),
      engineCount: serializer.fromJson<int>(json['engineCount']),
      engineType: serializer.fromJson<String>(json['engineType']),
      wtc: serializer.fromJson<String?>(json['wtc']),
      multiPilot: serializer.fromJson<bool?>(json['multiPilot']),
      complex: serializer.fromJson<bool?>(json['complex']),
      highPerformance: serializer.fromJson<bool?>(json['highPerformance']),
      retractableGear: serializer.fromJson<bool?>(json['retractableGear']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'icaoDesignator': serializer.toJson<String>(icaoDesignator),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'model': serializer.toJson<String>(model),
      'category': serializer.toJson<String>(category),
      'engineCount': serializer.toJson<int>(engineCount),
      'engineType': serializer.toJson<String>(engineType),
      'wtc': serializer.toJson<String?>(wtc),
      'multiPilot': serializer.toJson<bool?>(multiPilot),
      'complex': serializer.toJson<bool?>(complex),
      'highPerformance': serializer.toJson<bool?>(highPerformance),
      'retractableGear': serializer.toJson<bool?>(retractableGear),
    };
  }

  AircraftType copyWith(
          {int? id,
          String? icaoDesignator,
          String? manufacturer,
          String? model,
          String? category,
          int? engineCount,
          String? engineType,
          Value<String?> wtc = const Value.absent(),
          Value<bool?> multiPilot = const Value.absent(),
          Value<bool?> complex = const Value.absent(),
          Value<bool?> highPerformance = const Value.absent(),
          Value<bool?> retractableGear = const Value.absent()}) =>
      AircraftType(
        id: id ?? this.id,
        icaoDesignator: icaoDesignator ?? this.icaoDesignator,
        manufacturer: manufacturer ?? this.manufacturer,
        model: model ?? this.model,
        category: category ?? this.category,
        engineCount: engineCount ?? this.engineCount,
        engineType: engineType ?? this.engineType,
        wtc: wtc.present ? wtc.value : this.wtc,
        multiPilot: multiPilot.present ? multiPilot.value : this.multiPilot,
        complex: complex.present ? complex.value : this.complex,
        highPerformance: highPerformance.present
            ? highPerformance.value
            : this.highPerformance,
        retractableGear: retractableGear.present
            ? retractableGear.value
            : this.retractableGear,
      );
  AircraftType copyWithCompanion(AircraftTypesCompanion data) {
    return AircraftType(
      id: data.id.present ? data.id.value : this.id,
      icaoDesignator: data.icaoDesignator.present
          ? data.icaoDesignator.value
          : this.icaoDesignator,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      category: data.category.present ? data.category.value : this.category,
      engineCount:
          data.engineCount.present ? data.engineCount.value : this.engineCount,
      engineType:
          data.engineType.present ? data.engineType.value : this.engineType,
      wtc: data.wtc.present ? data.wtc.value : this.wtc,
      multiPilot:
          data.multiPilot.present ? data.multiPilot.value : this.multiPilot,
      complex: data.complex.present ? data.complex.value : this.complex,
      highPerformance: data.highPerformance.present
          ? data.highPerformance.value
          : this.highPerformance,
      retractableGear: data.retractableGear.present
          ? data.retractableGear.value
          : this.retractableGear,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AircraftType(')
          ..write('id: $id, ')
          ..write('icaoDesignator: $icaoDesignator, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('category: $category, ')
          ..write('engineCount: $engineCount, ')
          ..write('engineType: $engineType, ')
          ..write('wtc: $wtc, ')
          ..write('multiPilot: $multiPilot, ')
          ..write('complex: $complex, ')
          ..write('highPerformance: $highPerformance, ')
          ..write('retractableGear: $retractableGear')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      icaoDesignator,
      manufacturer,
      model,
      category,
      engineCount,
      engineType,
      wtc,
      multiPilot,
      complex,
      highPerformance,
      retractableGear);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AircraftType &&
          other.id == this.id &&
          other.icaoDesignator == this.icaoDesignator &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.category == this.category &&
          other.engineCount == this.engineCount &&
          other.engineType == this.engineType &&
          other.wtc == this.wtc &&
          other.multiPilot == this.multiPilot &&
          other.complex == this.complex &&
          other.highPerformance == this.highPerformance &&
          other.retractableGear == this.retractableGear);
}

class AircraftTypesCompanion extends UpdateCompanion<AircraftType> {
  final Value<int> id;
  final Value<String> icaoDesignator;
  final Value<String> manufacturer;
  final Value<String> model;
  final Value<String> category;
  final Value<int> engineCount;
  final Value<String> engineType;
  final Value<String?> wtc;
  final Value<bool?> multiPilot;
  final Value<bool?> complex;
  final Value<bool?> highPerformance;
  final Value<bool?> retractableGear;
  const AircraftTypesCompanion({
    this.id = const Value.absent(),
    this.icaoDesignator = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.category = const Value.absent(),
    this.engineCount = const Value.absent(),
    this.engineType = const Value.absent(),
    this.wtc = const Value.absent(),
    this.multiPilot = const Value.absent(),
    this.complex = const Value.absent(),
    this.highPerformance = const Value.absent(),
    this.retractableGear = const Value.absent(),
  });
  AircraftTypesCompanion.insert({
    this.id = const Value.absent(),
    required String icaoDesignator,
    required String manufacturer,
    required String model,
    required String category,
    required int engineCount,
    required String engineType,
    this.wtc = const Value.absent(),
    this.multiPilot = const Value.absent(),
    this.complex = const Value.absent(),
    this.highPerformance = const Value.absent(),
    this.retractableGear = const Value.absent(),
  })  : icaoDesignator = Value(icaoDesignator),
        manufacturer = Value(manufacturer),
        model = Value(model),
        category = Value(category),
        engineCount = Value(engineCount),
        engineType = Value(engineType);
  static Insertable<AircraftType> custom({
    Expression<int>? id,
    Expression<String>? icaoDesignator,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? category,
    Expression<int>? engineCount,
    Expression<String>? engineType,
    Expression<String>? wtc,
    Expression<bool>? multiPilot,
    Expression<bool>? complex,
    Expression<bool>? highPerformance,
    Expression<bool>? retractableGear,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icaoDesignator != null) 'icao_designator': icaoDesignator,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (category != null) 'category': category,
      if (engineCount != null) 'engine_count': engineCount,
      if (engineType != null) 'engine_type': engineType,
      if (wtc != null) 'wtc': wtc,
      if (multiPilot != null) 'multi_pilot': multiPilot,
      if (complex != null) 'complex': complex,
      if (highPerformance != null) 'high_performance': highPerformance,
      if (retractableGear != null) 'retractable_gear': retractableGear,
    });
  }

  AircraftTypesCompanion copyWith(
      {Value<int>? id,
      Value<String>? icaoDesignator,
      Value<String>? manufacturer,
      Value<String>? model,
      Value<String>? category,
      Value<int>? engineCount,
      Value<String>? engineType,
      Value<String?>? wtc,
      Value<bool?>? multiPilot,
      Value<bool?>? complex,
      Value<bool?>? highPerformance,
      Value<bool?>? retractableGear}) {
    return AircraftTypesCompanion(
      id: id ?? this.id,
      icaoDesignator: icaoDesignator ?? this.icaoDesignator,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      category: category ?? this.category,
      engineCount: engineCount ?? this.engineCount,
      engineType: engineType ?? this.engineType,
      wtc: wtc ?? this.wtc,
      multiPilot: multiPilot ?? this.multiPilot,
      complex: complex ?? this.complex,
      highPerformance: highPerformance ?? this.highPerformance,
      retractableGear: retractableGear ?? this.retractableGear,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (icaoDesignator.present) {
      map['icao_designator'] = Variable<String>(icaoDesignator.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (engineCount.present) {
      map['engine_count'] = Variable<int>(engineCount.value);
    }
    if (engineType.present) {
      map['engine_type'] = Variable<String>(engineType.value);
    }
    if (wtc.present) {
      map['wtc'] = Variable<String>(wtc.value);
    }
    if (multiPilot.present) {
      map['multi_pilot'] = Variable<bool>(multiPilot.value);
    }
    if (complex.present) {
      map['complex'] = Variable<bool>(complex.value);
    }
    if (highPerformance.present) {
      map['high_performance'] = Variable<bool>(highPerformance.value);
    }
    if (retractableGear.present) {
      map['retractable_gear'] = Variable<bool>(retractableGear.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AircraftTypesCompanion(')
          ..write('id: $id, ')
          ..write('icaoDesignator: $icaoDesignator, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('category: $category, ')
          ..write('engineCount: $engineCount, ')
          ..write('engineType: $engineType, ')
          ..write('wtc: $wtc, ')
          ..write('multiPilot: $multiPilot, ')
          ..write('complex: $complex, ')
          ..write('highPerformance: $highPerformance, ')
          ..write('retractableGear: $retractableGear')
          ..write(')'))
        .toString();
  }
}

class $FlightsTable extends Flights with TableInfo<$FlightsTable, Flight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creatorUuidMeta =
      const VerificationMeta('creatorUuid');
  @override
  late final GeneratedColumn<String> creatorUuid = GeneratedColumn<String>(
      'creator_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _flightDateMeta =
      const VerificationMeta('flightDate');
  @override
  late final GeneratedColumn<String> flightDate = GeneratedColumn<String>(
      'flight_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _flightNumberMeta =
      const VerificationMeta('flightNumber');
  @override
  late final GeneratedColumn<String> flightNumber = GeneratedColumn<String>(
      'flight_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _depMeta = const VerificationMeta('dep');
  @override
  late final GeneratedColumn<String> dep = GeneratedColumn<String>(
      'dep', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destMeta = const VerificationMeta('dest');
  @override
  late final GeneratedColumn<String> dest = GeneratedColumn<String>(
      'dest', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _depIcaoMeta =
      const VerificationMeta('depIcao');
  @override
  late final GeneratedColumn<String> depIcao = GeneratedColumn<String>(
      'dep_icao', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _depIataMeta =
      const VerificationMeta('depIata');
  @override
  late final GeneratedColumn<String> depIata = GeneratedColumn<String>(
      'dep_iata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _destIcaoMeta =
      const VerificationMeta('destIcao');
  @override
  late final GeneratedColumn<String> destIcao = GeneratedColumn<String>(
      'dest_icao', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _destIataMeta =
      const VerificationMeta('destIata');
  @override
  late final GeneratedColumn<String> destIata = GeneratedColumn<String>(
      'dest_iata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _blockOffMeta =
      const VerificationMeta('blockOff');
  @override
  late final GeneratedColumn<String> blockOff = GeneratedColumn<String>(
      'block_off', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _blockOnMeta =
      const VerificationMeta('blockOn');
  @override
  late final GeneratedColumn<String> blockOn = GeneratedColumn<String>(
      'block_on', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takeoffAtMeta =
      const VerificationMeta('takeoffAt');
  @override
  late final GeneratedColumn<String> takeoffAt = GeneratedColumn<String>(
      'takeoff_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _landingAtMeta =
      const VerificationMeta('landingAt');
  @override
  late final GeneratedColumn<String> landingAt = GeneratedColumn<String>(
      'landing_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aircraftTypeMeta =
      const VerificationMeta('aircraftType');
  @override
  late final GeneratedColumn<String> aircraftType = GeneratedColumn<String>(
      'aircraft_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aircraftRegMeta =
      const VerificationMeta('aircraftReg');
  @override
  late final GeneratedColumn<String> aircraftReg = GeneratedColumn<String>(
      'aircraft_reg', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _flightTimeJsonMeta =
      const VerificationMeta('flightTimeJson');
  @override
  late final GeneratedColumn<String> flightTimeJson = GeneratedColumn<String>(
      'flight_time_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPilotFlyingMeta =
      const VerificationMeta('isPilotFlying');
  @override
  late final GeneratedColumn<bool> isPilotFlying = GeneratedColumn<bool>(
      'is_pilot_flying', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_pilot_flying" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _approachesJsonMeta =
      const VerificationMeta('approachesJson');
  @override
  late final GeneratedColumn<String> approachesJson = GeneratedColumn<String>(
      'approaches_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _crewJsonMeta =
      const VerificationMeta('crewJson');
  @override
  late final GeneratedColumn<String> crewJson = GeneratedColumn<String>(
      'crew_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verificationsJsonMeta =
      const VerificationMeta('verificationsJson');
  @override
  late final GeneratedColumn<String> verificationsJson =
      GeneratedColumn<String>('verifications_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endorsementsJsonMeta =
      const VerificationMeta('endorsementsJson');
  @override
  late final GeneratedColumn<String> endorsementsJson = GeneratedColumn<String>(
      'endorsements_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<String> localUpdatedAt = GeneratedColumn<String>(
      'local_updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        creatorUuid,
        flightDate,
        flightNumber,
        dep,
        dest,
        depIcao,
        depIata,
        destIcao,
        destIata,
        blockOff,
        blockOn,
        takeoffAt,
        landingAt,
        aircraftType,
        aircraftReg,
        flightTimeJson,
        isPilotFlying,
        approachesJson,
        crewJson,
        verificationsJson,
        endorsementsJson,
        createdAt,
        updatedAt,
        syncStatus,
        serverUpdatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flights';
  @override
  VerificationContext validateIntegrity(Insertable<Flight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('creator_uuid')) {
      context.handle(
          _creatorUuidMeta,
          creatorUuid.isAcceptableOrUnknown(
              data['creator_uuid']!, _creatorUuidMeta));
    } else if (isInserting) {
      context.missing(_creatorUuidMeta);
    }
    if (data.containsKey('flight_date')) {
      context.handle(
          _flightDateMeta,
          flightDate.isAcceptableOrUnknown(
              data['flight_date']!, _flightDateMeta));
    } else if (isInserting) {
      context.missing(_flightDateMeta);
    }
    if (data.containsKey('flight_number')) {
      context.handle(
          _flightNumberMeta,
          flightNumber.isAcceptableOrUnknown(
              data['flight_number']!, _flightNumberMeta));
    }
    if (data.containsKey('dep')) {
      context.handle(
          _depMeta, dep.isAcceptableOrUnknown(data['dep']!, _depMeta));
    } else if (isInserting) {
      context.missing(_depMeta);
    }
    if (data.containsKey('dest')) {
      context.handle(
          _destMeta, dest.isAcceptableOrUnknown(data['dest']!, _destMeta));
    } else if (isInserting) {
      context.missing(_destMeta);
    }
    if (data.containsKey('dep_icao')) {
      context.handle(_depIcaoMeta,
          depIcao.isAcceptableOrUnknown(data['dep_icao']!, _depIcaoMeta));
    }
    if (data.containsKey('dep_iata')) {
      context.handle(_depIataMeta,
          depIata.isAcceptableOrUnknown(data['dep_iata']!, _depIataMeta));
    }
    if (data.containsKey('dest_icao')) {
      context.handle(_destIcaoMeta,
          destIcao.isAcceptableOrUnknown(data['dest_icao']!, _destIcaoMeta));
    }
    if (data.containsKey('dest_iata')) {
      context.handle(_destIataMeta,
          destIata.isAcceptableOrUnknown(data['dest_iata']!, _destIataMeta));
    }
    if (data.containsKey('block_off')) {
      context.handle(_blockOffMeta,
          blockOff.isAcceptableOrUnknown(data['block_off']!, _blockOffMeta));
    } else if (isInserting) {
      context.missing(_blockOffMeta);
    }
    if (data.containsKey('block_on')) {
      context.handle(_blockOnMeta,
          blockOn.isAcceptableOrUnknown(data['block_on']!, _blockOnMeta));
    } else if (isInserting) {
      context.missing(_blockOnMeta);
    }
    if (data.containsKey('takeoff_at')) {
      context.handle(_takeoffAtMeta,
          takeoffAt.isAcceptableOrUnknown(data['takeoff_at']!, _takeoffAtMeta));
    }
    if (data.containsKey('landing_at')) {
      context.handle(_landingAtMeta,
          landingAt.isAcceptableOrUnknown(data['landing_at']!, _landingAtMeta));
    }
    if (data.containsKey('aircraft_type')) {
      context.handle(
          _aircraftTypeMeta,
          aircraftType.isAcceptableOrUnknown(
              data['aircraft_type']!, _aircraftTypeMeta));
    } else if (isInserting) {
      context.missing(_aircraftTypeMeta);
    }
    if (data.containsKey('aircraft_reg')) {
      context.handle(
          _aircraftRegMeta,
          aircraftReg.isAcceptableOrUnknown(
              data['aircraft_reg']!, _aircraftRegMeta));
    } else if (isInserting) {
      context.missing(_aircraftRegMeta);
    }
    if (data.containsKey('flight_time_json')) {
      context.handle(
          _flightTimeJsonMeta,
          flightTimeJson.isAcceptableOrUnknown(
              data['flight_time_json']!, _flightTimeJsonMeta));
    } else if (isInserting) {
      context.missing(_flightTimeJsonMeta);
    }
    if (data.containsKey('is_pilot_flying')) {
      context.handle(
          _isPilotFlyingMeta,
          isPilotFlying.isAcceptableOrUnknown(
              data['is_pilot_flying']!, _isPilotFlyingMeta));
    }
    if (data.containsKey('approaches_json')) {
      context.handle(
          _approachesJsonMeta,
          approachesJson.isAcceptableOrUnknown(
              data['approaches_json']!, _approachesJsonMeta));
    }
    if (data.containsKey('crew_json')) {
      context.handle(_crewJsonMeta,
          crewJson.isAcceptableOrUnknown(data['crew_json']!, _crewJsonMeta));
    } else if (isInserting) {
      context.missing(_crewJsonMeta);
    }
    if (data.containsKey('verifications_json')) {
      context.handle(
          _verificationsJsonMeta,
          verificationsJson.isAcceptableOrUnknown(
              data['verifications_json']!, _verificationsJsonMeta));
    }
    if (data.containsKey('endorsements_json')) {
      context.handle(
          _endorsementsJsonMeta,
          endorsementsJson.isAcceptableOrUnknown(
              data['endorsements_json']!, _endorsementsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flight(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      creatorUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}creator_uuid'])!,
      flightDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flight_date'])!,
      flightNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flight_number']),
      dep: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dep'])!,
      dest: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dest'])!,
      depIcao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dep_icao']),
      depIata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dep_iata']),
      destIcao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dest_icao']),
      destIata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dest_iata']),
      blockOff: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}block_off'])!,
      blockOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}block_on'])!,
      takeoffAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}takeoff_at']),
      landingAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}landing_at']),
      aircraftType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aircraft_type'])!,
      aircraftReg: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aircraft_reg'])!,
      flightTimeJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}flight_time_json'])!,
      isPilotFlying: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pilot_flying'])!,
      approachesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approaches_json']),
      crewJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crew_json'])!,
      verificationsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verifications_json']),
      endorsementsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}endorsements_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}server_updated_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $FlightsTable createAlias(String alias) {
    return $FlightsTable(attachedDatabase, alias);
  }
}

class Flight extends DataClass implements Insertable<Flight> {
  final String id;
  final String creatorUuid;
  final String flightDate;
  final String? flightNumber;
  final String dep;
  final String dest;
  final String? depIcao;
  final String? depIata;
  final String? destIcao;
  final String? destIata;
  final String blockOff;
  final String blockOn;
  final String? takeoffAt;
  final String? landingAt;
  final String aircraftType;
  final String aircraftReg;
  final String flightTimeJson;
  final bool isPilotFlying;
  final String? approachesJson;
  final String crewJson;
  final String? verificationsJson;
  final String? endorsementsJson;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final String? serverUpdatedAt;
  final String localUpdatedAt;
  const Flight(
      {required this.id,
      required this.creatorUuid,
      required this.flightDate,
      this.flightNumber,
      required this.dep,
      required this.dest,
      this.depIcao,
      this.depIata,
      this.destIcao,
      this.destIata,
      required this.blockOff,
      required this.blockOn,
      this.takeoffAt,
      this.landingAt,
      required this.aircraftType,
      required this.aircraftReg,
      required this.flightTimeJson,
      required this.isPilotFlying,
      this.approachesJson,
      required this.crewJson,
      this.verificationsJson,
      this.endorsementsJson,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.serverUpdatedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['creator_uuid'] = Variable<String>(creatorUuid);
    map['flight_date'] = Variable<String>(flightDate);
    if (!nullToAbsent || flightNumber != null) {
      map['flight_number'] = Variable<String>(flightNumber);
    }
    map['dep'] = Variable<String>(dep);
    map['dest'] = Variable<String>(dest);
    if (!nullToAbsent || depIcao != null) {
      map['dep_icao'] = Variable<String>(depIcao);
    }
    if (!nullToAbsent || depIata != null) {
      map['dep_iata'] = Variable<String>(depIata);
    }
    if (!nullToAbsent || destIcao != null) {
      map['dest_icao'] = Variable<String>(destIcao);
    }
    if (!nullToAbsent || destIata != null) {
      map['dest_iata'] = Variable<String>(destIata);
    }
    map['block_off'] = Variable<String>(blockOff);
    map['block_on'] = Variable<String>(blockOn);
    if (!nullToAbsent || takeoffAt != null) {
      map['takeoff_at'] = Variable<String>(takeoffAt);
    }
    if (!nullToAbsent || landingAt != null) {
      map['landing_at'] = Variable<String>(landingAt);
    }
    map['aircraft_type'] = Variable<String>(aircraftType);
    map['aircraft_reg'] = Variable<String>(aircraftReg);
    map['flight_time_json'] = Variable<String>(flightTimeJson);
    map['is_pilot_flying'] = Variable<bool>(isPilotFlying);
    if (!nullToAbsent || approachesJson != null) {
      map['approaches_json'] = Variable<String>(approachesJson);
    }
    map['crew_json'] = Variable<String>(crewJson);
    if (!nullToAbsent || verificationsJson != null) {
      map['verifications_json'] = Variable<String>(verificationsJson);
    }
    if (!nullToAbsent || endorsementsJson != null) {
      map['endorsements_json'] = Variable<String>(endorsementsJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    map['local_updated_at'] = Variable<String>(localUpdatedAt);
    return map;
  }

  FlightsCompanion toCompanion(bool nullToAbsent) {
    return FlightsCompanion(
      id: Value(id),
      creatorUuid: Value(creatorUuid),
      flightDate: Value(flightDate),
      flightNumber: flightNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(flightNumber),
      dep: Value(dep),
      dest: Value(dest),
      depIcao: depIcao == null && nullToAbsent
          ? const Value.absent()
          : Value(depIcao),
      depIata: depIata == null && nullToAbsent
          ? const Value.absent()
          : Value(depIata),
      destIcao: destIcao == null && nullToAbsent
          ? const Value.absent()
          : Value(destIcao),
      destIata: destIata == null && nullToAbsent
          ? const Value.absent()
          : Value(destIata),
      blockOff: Value(blockOff),
      blockOn: Value(blockOn),
      takeoffAt: takeoffAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takeoffAt),
      landingAt: landingAt == null && nullToAbsent
          ? const Value.absent()
          : Value(landingAt),
      aircraftType: Value(aircraftType),
      aircraftReg: Value(aircraftReg),
      flightTimeJson: Value(flightTimeJson),
      isPilotFlying: Value(isPilotFlying),
      approachesJson: approachesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(approachesJson),
      crewJson: Value(crewJson),
      verificationsJson: verificationsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(verificationsJson),
      endorsementsJson: endorsementsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(endorsementsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory Flight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flight(
      id: serializer.fromJson<String>(json['id']),
      creatorUuid: serializer.fromJson<String>(json['creatorUuid']),
      flightDate: serializer.fromJson<String>(json['flightDate']),
      flightNumber: serializer.fromJson<String?>(json['flightNumber']),
      dep: serializer.fromJson<String>(json['dep']),
      dest: serializer.fromJson<String>(json['dest']),
      depIcao: serializer.fromJson<String?>(json['depIcao']),
      depIata: serializer.fromJson<String?>(json['depIata']),
      destIcao: serializer.fromJson<String?>(json['destIcao']),
      destIata: serializer.fromJson<String?>(json['destIata']),
      blockOff: serializer.fromJson<String>(json['blockOff']),
      blockOn: serializer.fromJson<String>(json['blockOn']),
      takeoffAt: serializer.fromJson<String?>(json['takeoffAt']),
      landingAt: serializer.fromJson<String?>(json['landingAt']),
      aircraftType: serializer.fromJson<String>(json['aircraftType']),
      aircraftReg: serializer.fromJson<String>(json['aircraftReg']),
      flightTimeJson: serializer.fromJson<String>(json['flightTimeJson']),
      isPilotFlying: serializer.fromJson<bool>(json['isPilotFlying']),
      approachesJson: serializer.fromJson<String?>(json['approachesJson']),
      crewJson: serializer.fromJson<String>(json['crewJson']),
      verificationsJson:
          serializer.fromJson<String?>(json['verificationsJson']),
      endorsementsJson: serializer.fromJson<String?>(json['endorsementsJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      localUpdatedAt: serializer.fromJson<String>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'creatorUuid': serializer.toJson<String>(creatorUuid),
      'flightDate': serializer.toJson<String>(flightDate),
      'flightNumber': serializer.toJson<String?>(flightNumber),
      'dep': serializer.toJson<String>(dep),
      'dest': serializer.toJson<String>(dest),
      'depIcao': serializer.toJson<String?>(depIcao),
      'depIata': serializer.toJson<String?>(depIata),
      'destIcao': serializer.toJson<String?>(destIcao),
      'destIata': serializer.toJson<String?>(destIata),
      'blockOff': serializer.toJson<String>(blockOff),
      'blockOn': serializer.toJson<String>(blockOn),
      'takeoffAt': serializer.toJson<String?>(takeoffAt),
      'landingAt': serializer.toJson<String?>(landingAt),
      'aircraftType': serializer.toJson<String>(aircraftType),
      'aircraftReg': serializer.toJson<String>(aircraftReg),
      'flightTimeJson': serializer.toJson<String>(flightTimeJson),
      'isPilotFlying': serializer.toJson<bool>(isPilotFlying),
      'approachesJson': serializer.toJson<String?>(approachesJson),
      'crewJson': serializer.toJson<String>(crewJson),
      'verificationsJson': serializer.toJson<String?>(verificationsJson),
      'endorsementsJson': serializer.toJson<String?>(endorsementsJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
      'localUpdatedAt': serializer.toJson<String>(localUpdatedAt),
    };
  }

  Flight copyWith(
          {String? id,
          String? creatorUuid,
          String? flightDate,
          Value<String?> flightNumber = const Value.absent(),
          String? dep,
          String? dest,
          Value<String?> depIcao = const Value.absent(),
          Value<String?> depIata = const Value.absent(),
          Value<String?> destIcao = const Value.absent(),
          Value<String?> destIata = const Value.absent(),
          String? blockOff,
          String? blockOn,
          Value<String?> takeoffAt = const Value.absent(),
          Value<String?> landingAt = const Value.absent(),
          String? aircraftType,
          String? aircraftReg,
          String? flightTimeJson,
          bool? isPilotFlying,
          Value<String?> approachesJson = const Value.absent(),
          String? crewJson,
          Value<String?> verificationsJson = const Value.absent(),
          Value<String?> endorsementsJson = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          String? syncStatus,
          Value<String?> serverUpdatedAt = const Value.absent(),
          String? localUpdatedAt}) =>
      Flight(
        id: id ?? this.id,
        creatorUuid: creatorUuid ?? this.creatorUuid,
        flightDate: flightDate ?? this.flightDate,
        flightNumber:
            flightNumber.present ? flightNumber.value : this.flightNumber,
        dep: dep ?? this.dep,
        dest: dest ?? this.dest,
        depIcao: depIcao.present ? depIcao.value : this.depIcao,
        depIata: depIata.present ? depIata.value : this.depIata,
        destIcao: destIcao.present ? destIcao.value : this.destIcao,
        destIata: destIata.present ? destIata.value : this.destIata,
        blockOff: blockOff ?? this.blockOff,
        blockOn: blockOn ?? this.blockOn,
        takeoffAt: takeoffAt.present ? takeoffAt.value : this.takeoffAt,
        landingAt: landingAt.present ? landingAt.value : this.landingAt,
        aircraftType: aircraftType ?? this.aircraftType,
        aircraftReg: aircraftReg ?? this.aircraftReg,
        flightTimeJson: flightTimeJson ?? this.flightTimeJson,
        isPilotFlying: isPilotFlying ?? this.isPilotFlying,
        approachesJson:
            approachesJson.present ? approachesJson.value : this.approachesJson,
        crewJson: crewJson ?? this.crewJson,
        verificationsJson: verificationsJson.present
            ? verificationsJson.value
            : this.verificationsJson,
        endorsementsJson: endorsementsJson.present
            ? endorsementsJson.value
            : this.endorsementsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  Flight copyWithCompanion(FlightsCompanion data) {
    return Flight(
      id: data.id.present ? data.id.value : this.id,
      creatorUuid:
          data.creatorUuid.present ? data.creatorUuid.value : this.creatorUuid,
      flightDate:
          data.flightDate.present ? data.flightDate.value : this.flightDate,
      flightNumber: data.flightNumber.present
          ? data.flightNumber.value
          : this.flightNumber,
      dep: data.dep.present ? data.dep.value : this.dep,
      dest: data.dest.present ? data.dest.value : this.dest,
      depIcao: data.depIcao.present ? data.depIcao.value : this.depIcao,
      depIata: data.depIata.present ? data.depIata.value : this.depIata,
      destIcao: data.destIcao.present ? data.destIcao.value : this.destIcao,
      destIata: data.destIata.present ? data.destIata.value : this.destIata,
      blockOff: data.blockOff.present ? data.blockOff.value : this.blockOff,
      blockOn: data.blockOn.present ? data.blockOn.value : this.blockOn,
      takeoffAt: data.takeoffAt.present ? data.takeoffAt.value : this.takeoffAt,
      landingAt: data.landingAt.present ? data.landingAt.value : this.landingAt,
      aircraftType: data.aircraftType.present
          ? data.aircraftType.value
          : this.aircraftType,
      aircraftReg:
          data.aircraftReg.present ? data.aircraftReg.value : this.aircraftReg,
      flightTimeJson: data.flightTimeJson.present
          ? data.flightTimeJson.value
          : this.flightTimeJson,
      isPilotFlying: data.isPilotFlying.present
          ? data.isPilotFlying.value
          : this.isPilotFlying,
      approachesJson: data.approachesJson.present
          ? data.approachesJson.value
          : this.approachesJson,
      crewJson: data.crewJson.present ? data.crewJson.value : this.crewJson,
      verificationsJson: data.verificationsJson.present
          ? data.verificationsJson.value
          : this.verificationsJson,
      endorsementsJson: data.endorsementsJson.present
          ? data.endorsementsJson.value
          : this.endorsementsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flight(')
          ..write('id: $id, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('flightDate: $flightDate, ')
          ..write('flightNumber: $flightNumber, ')
          ..write('dep: $dep, ')
          ..write('dest: $dest, ')
          ..write('depIcao: $depIcao, ')
          ..write('depIata: $depIata, ')
          ..write('destIcao: $destIcao, ')
          ..write('destIata: $destIata, ')
          ..write('blockOff: $blockOff, ')
          ..write('blockOn: $blockOn, ')
          ..write('takeoffAt: $takeoffAt, ')
          ..write('landingAt: $landingAt, ')
          ..write('aircraftType: $aircraftType, ')
          ..write('aircraftReg: $aircraftReg, ')
          ..write('flightTimeJson: $flightTimeJson, ')
          ..write('isPilotFlying: $isPilotFlying, ')
          ..write('approachesJson: $approachesJson, ')
          ..write('crewJson: $crewJson, ')
          ..write('verificationsJson: $verificationsJson, ')
          ..write('endorsementsJson: $endorsementsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        creatorUuid,
        flightDate,
        flightNumber,
        dep,
        dest,
        depIcao,
        depIata,
        destIcao,
        destIata,
        blockOff,
        blockOn,
        takeoffAt,
        landingAt,
        aircraftType,
        aircraftReg,
        flightTimeJson,
        isPilotFlying,
        approachesJson,
        crewJson,
        verificationsJson,
        endorsementsJson,
        createdAt,
        updatedAt,
        syncStatus,
        serverUpdatedAt,
        localUpdatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flight &&
          other.id == this.id &&
          other.creatorUuid == this.creatorUuid &&
          other.flightDate == this.flightDate &&
          other.flightNumber == this.flightNumber &&
          other.dep == this.dep &&
          other.dest == this.dest &&
          other.depIcao == this.depIcao &&
          other.depIata == this.depIata &&
          other.destIcao == this.destIcao &&
          other.destIata == this.destIata &&
          other.blockOff == this.blockOff &&
          other.blockOn == this.blockOn &&
          other.takeoffAt == this.takeoffAt &&
          other.landingAt == this.landingAt &&
          other.aircraftType == this.aircraftType &&
          other.aircraftReg == this.aircraftReg &&
          other.flightTimeJson == this.flightTimeJson &&
          other.isPilotFlying == this.isPilotFlying &&
          other.approachesJson == this.approachesJson &&
          other.crewJson == this.crewJson &&
          other.verificationsJson == this.verificationsJson &&
          other.endorsementsJson == this.endorsementsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class FlightsCompanion extends UpdateCompanion<Flight> {
  final Value<String> id;
  final Value<String> creatorUuid;
  final Value<String> flightDate;
  final Value<String?> flightNumber;
  final Value<String> dep;
  final Value<String> dest;
  final Value<String?> depIcao;
  final Value<String?> depIata;
  final Value<String?> destIcao;
  final Value<String?> destIata;
  final Value<String> blockOff;
  final Value<String> blockOn;
  final Value<String?> takeoffAt;
  final Value<String?> landingAt;
  final Value<String> aircraftType;
  final Value<String> aircraftReg;
  final Value<String> flightTimeJson;
  final Value<bool> isPilotFlying;
  final Value<String?> approachesJson;
  final Value<String> crewJson;
  final Value<String?> verificationsJson;
  final Value<String?> endorsementsJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> serverUpdatedAt;
  final Value<String> localUpdatedAt;
  final Value<int> rowid;
  const FlightsCompanion({
    this.id = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.flightDate = const Value.absent(),
    this.flightNumber = const Value.absent(),
    this.dep = const Value.absent(),
    this.dest = const Value.absent(),
    this.depIcao = const Value.absent(),
    this.depIata = const Value.absent(),
    this.destIcao = const Value.absent(),
    this.destIata = const Value.absent(),
    this.blockOff = const Value.absent(),
    this.blockOn = const Value.absent(),
    this.takeoffAt = const Value.absent(),
    this.landingAt = const Value.absent(),
    this.aircraftType = const Value.absent(),
    this.aircraftReg = const Value.absent(),
    this.flightTimeJson = const Value.absent(),
    this.isPilotFlying = const Value.absent(),
    this.approachesJson = const Value.absent(),
    this.crewJson = const Value.absent(),
    this.verificationsJson = const Value.absent(),
    this.endorsementsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlightsCompanion.insert({
    required String id,
    required String creatorUuid,
    required String flightDate,
    this.flightNumber = const Value.absent(),
    required String dep,
    required String dest,
    this.depIcao = const Value.absent(),
    this.depIata = const Value.absent(),
    this.destIcao = const Value.absent(),
    this.destIata = const Value.absent(),
    required String blockOff,
    required String blockOn,
    this.takeoffAt = const Value.absent(),
    this.landingAt = const Value.absent(),
    required String aircraftType,
    required String aircraftReg,
    required String flightTimeJson,
    this.isPilotFlying = const Value.absent(),
    this.approachesJson = const Value.absent(),
    required String crewJson,
    this.verificationsJson = const Value.absent(),
    this.endorsementsJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String localUpdatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        creatorUuid = Value(creatorUuid),
        flightDate = Value(flightDate),
        dep = Value(dep),
        dest = Value(dest),
        blockOff = Value(blockOff),
        blockOn = Value(blockOn),
        aircraftType = Value(aircraftType),
        aircraftReg = Value(aircraftReg),
        flightTimeJson = Value(flightTimeJson),
        crewJson = Value(crewJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        localUpdatedAt = Value(localUpdatedAt);
  static Insertable<Flight> custom({
    Expression<String>? id,
    Expression<String>? creatorUuid,
    Expression<String>? flightDate,
    Expression<String>? flightNumber,
    Expression<String>? dep,
    Expression<String>? dest,
    Expression<String>? depIcao,
    Expression<String>? depIata,
    Expression<String>? destIcao,
    Expression<String>? destIata,
    Expression<String>? blockOff,
    Expression<String>? blockOn,
    Expression<String>? takeoffAt,
    Expression<String>? landingAt,
    Expression<String>? aircraftType,
    Expression<String>? aircraftReg,
    Expression<String>? flightTimeJson,
    Expression<bool>? isPilotFlying,
    Expression<String>? approachesJson,
    Expression<String>? crewJson,
    Expression<String>? verificationsJson,
    Expression<String>? endorsementsJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? serverUpdatedAt,
    Expression<String>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creatorUuid != null) 'creator_uuid': creatorUuid,
      if (flightDate != null) 'flight_date': flightDate,
      if (flightNumber != null) 'flight_number': flightNumber,
      if (dep != null) 'dep': dep,
      if (dest != null) 'dest': dest,
      if (depIcao != null) 'dep_icao': depIcao,
      if (depIata != null) 'dep_iata': depIata,
      if (destIcao != null) 'dest_icao': destIcao,
      if (destIata != null) 'dest_iata': destIata,
      if (blockOff != null) 'block_off': blockOff,
      if (blockOn != null) 'block_on': blockOn,
      if (takeoffAt != null) 'takeoff_at': takeoffAt,
      if (landingAt != null) 'landing_at': landingAt,
      if (aircraftType != null) 'aircraft_type': aircraftType,
      if (aircraftReg != null) 'aircraft_reg': aircraftReg,
      if (flightTimeJson != null) 'flight_time_json': flightTimeJson,
      if (isPilotFlying != null) 'is_pilot_flying': isPilotFlying,
      if (approachesJson != null) 'approaches_json': approachesJson,
      if (crewJson != null) 'crew_json': crewJson,
      if (verificationsJson != null) 'verifications_json': verificationsJson,
      if (endorsementsJson != null) 'endorsements_json': endorsementsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlightsCompanion copyWith(
      {Value<String>? id,
      Value<String>? creatorUuid,
      Value<String>? flightDate,
      Value<String?>? flightNumber,
      Value<String>? dep,
      Value<String>? dest,
      Value<String?>? depIcao,
      Value<String?>? depIata,
      Value<String?>? destIcao,
      Value<String?>? destIata,
      Value<String>? blockOff,
      Value<String>? blockOn,
      Value<String?>? takeoffAt,
      Value<String?>? landingAt,
      Value<String>? aircraftType,
      Value<String>? aircraftReg,
      Value<String>? flightTimeJson,
      Value<bool>? isPilotFlying,
      Value<String?>? approachesJson,
      Value<String>? crewJson,
      Value<String?>? verificationsJson,
      Value<String?>? endorsementsJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? syncStatus,
      Value<String?>? serverUpdatedAt,
      Value<String>? localUpdatedAt,
      Value<int>? rowid}) {
    return FlightsCompanion(
      id: id ?? this.id,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      flightDate: flightDate ?? this.flightDate,
      flightNumber: flightNumber ?? this.flightNumber,
      dep: dep ?? this.dep,
      dest: dest ?? this.dest,
      depIcao: depIcao ?? this.depIcao,
      depIata: depIata ?? this.depIata,
      destIcao: destIcao ?? this.destIcao,
      destIata: destIata ?? this.destIata,
      blockOff: blockOff ?? this.blockOff,
      blockOn: blockOn ?? this.blockOn,
      takeoffAt: takeoffAt ?? this.takeoffAt,
      landingAt: landingAt ?? this.landingAt,
      aircraftType: aircraftType ?? this.aircraftType,
      aircraftReg: aircraftReg ?? this.aircraftReg,
      flightTimeJson: flightTimeJson ?? this.flightTimeJson,
      isPilotFlying: isPilotFlying ?? this.isPilotFlying,
      approachesJson: approachesJson ?? this.approachesJson,
      crewJson: crewJson ?? this.crewJson,
      verificationsJson: verificationsJson ?? this.verificationsJson,
      endorsementsJson: endorsementsJson ?? this.endorsementsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (creatorUuid.present) {
      map['creator_uuid'] = Variable<String>(creatorUuid.value);
    }
    if (flightDate.present) {
      map['flight_date'] = Variable<String>(flightDate.value);
    }
    if (flightNumber.present) {
      map['flight_number'] = Variable<String>(flightNumber.value);
    }
    if (dep.present) {
      map['dep'] = Variable<String>(dep.value);
    }
    if (dest.present) {
      map['dest'] = Variable<String>(dest.value);
    }
    if (depIcao.present) {
      map['dep_icao'] = Variable<String>(depIcao.value);
    }
    if (depIata.present) {
      map['dep_iata'] = Variable<String>(depIata.value);
    }
    if (destIcao.present) {
      map['dest_icao'] = Variable<String>(destIcao.value);
    }
    if (destIata.present) {
      map['dest_iata'] = Variable<String>(destIata.value);
    }
    if (blockOff.present) {
      map['block_off'] = Variable<String>(blockOff.value);
    }
    if (blockOn.present) {
      map['block_on'] = Variable<String>(blockOn.value);
    }
    if (takeoffAt.present) {
      map['takeoff_at'] = Variable<String>(takeoffAt.value);
    }
    if (landingAt.present) {
      map['landing_at'] = Variable<String>(landingAt.value);
    }
    if (aircraftType.present) {
      map['aircraft_type'] = Variable<String>(aircraftType.value);
    }
    if (aircraftReg.present) {
      map['aircraft_reg'] = Variable<String>(aircraftReg.value);
    }
    if (flightTimeJson.present) {
      map['flight_time_json'] = Variable<String>(flightTimeJson.value);
    }
    if (isPilotFlying.present) {
      map['is_pilot_flying'] = Variable<bool>(isPilotFlying.value);
    }
    if (approachesJson.present) {
      map['approaches_json'] = Variable<String>(approachesJson.value);
    }
    if (crewJson.present) {
      map['crew_json'] = Variable<String>(crewJson.value);
    }
    if (verificationsJson.present) {
      map['verifications_json'] = Variable<String>(verificationsJson.value);
    }
    if (endorsementsJson.present) {
      map['endorsements_json'] = Variable<String>(endorsementsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<String>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlightsCompanion(')
          ..write('id: $id, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('flightDate: $flightDate, ')
          ..write('flightNumber: $flightNumber, ')
          ..write('dep: $dep, ')
          ..write('dest: $dest, ')
          ..write('depIcao: $depIcao, ')
          ..write('depIata: $depIata, ')
          ..write('destIcao: $destIcao, ')
          ..write('destIata: $destIata, ')
          ..write('blockOff: $blockOff, ')
          ..write('blockOn: $blockOn, ')
          ..write('takeoffAt: $takeoffAt, ')
          ..write('landingAt: $landingAt, ')
          ..write('aircraftType: $aircraftType, ')
          ..write('aircraftReg: $aircraftReg, ')
          ..write('flightTimeJson: $flightTimeJson, ')
          ..write('isPilotFlying: $isPilotFlying, ')
          ..write('approachesJson: $approachesJson, ')
          ..write('crewJson: $crewJson, ')
          ..write('verificationsJson: $verificationsJson, ')
          ..write('endorsementsJson: $endorsementsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordCountMeta =
      const VerificationMeta('recordCount');
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
      'record_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [entityType, lastSyncAt, recordCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('record_count')) {
      context.handle(
          _recordCountMeta,
          recordCount.isAcceptableOrUnknown(
              data['record_count']!, _recordCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_sync_at']),
      recordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}record_count']),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String entityType;
  final String? lastSyncAt;
  final int? recordCount;
  const SyncMetadataData(
      {required this.entityType, this.lastSyncAt, this.recordCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<String>(lastSyncAt);
    }
    if (!nullToAbsent || recordCount != null) {
      map['record_count'] = Variable<int>(recordCount);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      entityType: Value(entityType),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      recordCount: recordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(recordCount),
    );
  }

  factory SyncMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastSyncAt: serializer.fromJson<String?>(json['lastSyncAt']),
      recordCount: serializer.fromJson<int?>(json['recordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastSyncAt': serializer.toJson<String?>(lastSyncAt),
      'recordCount': serializer.toJson<int?>(recordCount),
    };
  }

  SyncMetadataData copyWith(
          {String? entityType,
          Value<String?> lastSyncAt = const Value.absent(),
          Value<int?> recordCount = const Value.absent()}) =>
      SyncMetadataData(
        entityType: entityType ?? this.entityType,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        recordCount: recordCount.present ? recordCount.value : this.recordCount,
      );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      recordCount:
          data.recordCount.present ? data.recordCount.value : this.recordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastSyncAt, recordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.entityType == this.entityType &&
          other.lastSyncAt == this.lastSyncAt &&
          other.recordCount == this.recordCount);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> entityType;
  final Value<String?> lastSyncAt;
  final Value<int?> recordCount;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.entityType = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String entityType,
    this.lastSyncAt = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? entityType,
    Expression<String>? lastSyncAt,
    Expression<int>? recordCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (recordCount != null) 'record_count': recordCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith(
      {Value<String>? entityType,
      Value<String?>? lastSyncAt,
      Value<int?>? recordCount,
      Value<int>? rowid}) {
    return SyncMetadataCompanion(
      entityType: entityType ?? this.entityType,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      recordCount: recordCount ?? this.recordCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('recordCount: $recordCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingDeletionsTable extends PendingDeletions
    with TableInfo<$PendingDeletionsTable, PendingDeletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingDeletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, entityType, entityId, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_deletions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingDeletion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingDeletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDeletion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at'])!,
    );
  }

  @override
  $PendingDeletionsTable createAlias(String alias) {
    return $PendingDeletionsTable(attachedDatabase, alias);
  }
}

class PendingDeletion extends DataClass implements Insertable<PendingDeletion> {
  final String id;
  final String entityType;
  final String entityId;
  final String deletedAt;
  const PendingDeletion(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['deleted_at'] = Variable<String>(deletedAt);
    return map;
  }

  PendingDeletionsCompanion toCompanion(bool nullToAbsent) {
    return PendingDeletionsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      deletedAt: Value(deletedAt),
    );
  }

  factory PendingDeletion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDeletion(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deletedAt: serializer.fromJson<String>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deletedAt': serializer.toJson<String>(deletedAt),
    };
  }

  PendingDeletion copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? deletedAt}) =>
      PendingDeletion(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  PendingDeletion copyWithCompanion(PendingDeletionsCompanion data) {
    return PendingDeletion(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDeletion &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deletedAt == this.deletedAt);
}

class PendingDeletionsCompanion extends UpdateCompanion<PendingDeletion> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> deletedAt;
  final Value<int> rowid;
  const PendingDeletionsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingDeletionsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String deletedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        deletedAt = Value(deletedAt);
  static Insertable<PendingDeletion> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingDeletionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? deletedAt,
      Value<int>? rowid}) {
    return PendingDeletionsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletionsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlightDraftsTable extends FlightDrafts
    with TableInfo<$FlightDraftsTable, FlightDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlightDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formDataMeta =
      const VerificationMeta('formData');
  @override
  late final GeneratedColumn<String> formData = GeneratedColumn<String>(
      'form_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, formData, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flight_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<FlightDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('form_data')) {
      context.handle(_formDataMeta,
          formData.isAcceptableOrUnknown(data['form_data']!, _formDataMeta));
    } else if (isInserting) {
      context.missing(_formDataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlightDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlightDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      formData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}form_data'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FlightDraftsTable createAlias(String alias) {
    return $FlightDraftsTable(attachedDatabase, alias);
  }
}

class FlightDraft extends DataClass implements Insertable<FlightDraft> {
  final String id;
  final String formData;
  final int createdAt;
  final int updatedAt;
  const FlightDraft(
      {required this.id,
      required this.formData,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['form_data'] = Variable<String>(formData);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FlightDraftsCompanion toCompanion(bool nullToAbsent) {
    return FlightDraftsCompanion(
      id: Value(id),
      formData: Value(formData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FlightDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlightDraft(
      id: serializer.fromJson<String>(json['id']),
      formData: serializer.fromJson<String>(json['formData']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formData': serializer.toJson<String>(formData),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FlightDraft copyWith(
          {String? id, String? formData, int? createdAt, int? updatedAt}) =>
      FlightDraft(
        id: id ?? this.id,
        formData: formData ?? this.formData,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FlightDraft copyWithCompanion(FlightDraftsCompanion data) {
    return FlightDraft(
      id: data.id.present ? data.id.value : this.id,
      formData: data.formData.present ? data.formData.value : this.formData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlightDraft(')
          ..write('id: $id, ')
          ..write('formData: $formData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, formData, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlightDraft &&
          other.id == this.id &&
          other.formData == this.formData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FlightDraftsCompanion extends UpdateCompanion<FlightDraft> {
  final Value<String> id;
  final Value<String> formData;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const FlightDraftsCompanion({
    this.id = const Value.absent(),
    this.formData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlightDraftsCompanion.insert({
    required String id,
    required String formData,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        formData = Value(formData),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FlightDraft> custom({
    Expression<String>? id,
    Expression<String>? formData,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formData != null) 'form_data': formData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlightDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? formData,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return FlightDraftsCompanion(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formData.present) {
      map['form_data'] = Variable<String>(formData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlightDraftsCompanion(')
          ..write('id: $id, ')
          ..write('formData: $formData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedPilotsTable extends SavedPilots
    with TableInfo<$SavedPilotsTable, SavedPilot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedPilotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseNumberMeta =
      const VerificationMeta('licenseNumber');
  @override
  late final GeneratedColumn<String> licenseNumber = GeneratedColumn<String>(
      'license_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pilotUuidMeta =
      const VerificationMeta('pilotUuid');
  @override
  late final GeneratedColumn<String> pilotUuid = GeneratedColumn<String>(
      'pilot_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<String> localUpdatedAt = GeneratedColumn<String>(
      'local_updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        licenseNumber,
        pilotUuid,
        createdAt,
        updatedAt,
        syncStatus,
        serverUpdatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_pilots';
  @override
  VerificationContext validateIntegrity(Insertable<SavedPilot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('license_number')) {
      context.handle(
          _licenseNumberMeta,
          licenseNumber.isAcceptableOrUnknown(
              data['license_number']!, _licenseNumberMeta));
    }
    if (data.containsKey('pilot_uuid')) {
      context.handle(_pilotUuidMeta,
          pilotUuid.isAcceptableOrUnknown(data['pilot_uuid']!, _pilotUuidMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedPilot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedPilot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      licenseNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_number']),
      pilotUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pilot_uuid']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}server_updated_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $SavedPilotsTable createAlias(String alias) {
    return $SavedPilotsTable(attachedDatabase, alias);
  }
}

class SavedPilot extends DataClass implements Insertable<SavedPilot> {
  final String id;
  final String userId;
  final String name;
  final String? licenseNumber;
  final String? pilotUuid;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final String? serverUpdatedAt;
  final String localUpdatedAt;
  const SavedPilot(
      {required this.id,
      required this.userId,
      required this.name,
      this.licenseNumber,
      this.pilotUuid,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.serverUpdatedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || licenseNumber != null) {
      map['license_number'] = Variable<String>(licenseNumber);
    }
    if (!nullToAbsent || pilotUuid != null) {
      map['pilot_uuid'] = Variable<String>(pilotUuid);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    map['local_updated_at'] = Variable<String>(localUpdatedAt);
    return map;
  }

  SavedPilotsCompanion toCompanion(bool nullToAbsent) {
    return SavedPilotsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      licenseNumber: licenseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNumber),
      pilotUuid: pilotUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(pilotUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory SavedPilot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedPilot(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      licenseNumber: serializer.fromJson<String?>(json['licenseNumber']),
      pilotUuid: serializer.fromJson<String?>(json['pilotUuid']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
      localUpdatedAt: serializer.fromJson<String>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'licenseNumber': serializer.toJson<String?>(licenseNumber),
      'pilotUuid': serializer.toJson<String?>(pilotUuid),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
      'localUpdatedAt': serializer.toJson<String>(localUpdatedAt),
    };
  }

  SavedPilot copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> licenseNumber = const Value.absent(),
          Value<String?> pilotUuid = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          String? syncStatus,
          Value<String?> serverUpdatedAt = const Value.absent(),
          String? localUpdatedAt}) =>
      SavedPilot(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        licenseNumber:
            licenseNumber.present ? licenseNumber.value : this.licenseNumber,
        pilotUuid: pilotUuid.present ? pilotUuid.value : this.pilotUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  SavedPilot copyWithCompanion(SavedPilotsCompanion data) {
    return SavedPilot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      licenseNumber: data.licenseNumber.present
          ? data.licenseNumber.value
          : this.licenseNumber,
      pilotUuid: data.pilotUuid.present ? data.pilotUuid.value : this.pilotUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedPilot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('pilotUuid: $pilotUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, licenseNumber, pilotUuid,
      createdAt, updatedAt, syncStatus, serverUpdatedAt, localUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedPilot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.licenseNumber == this.licenseNumber &&
          other.pilotUuid == this.pilotUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class SavedPilotsCompanion extends UpdateCompanion<SavedPilot> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> licenseNumber;
  final Value<String?> pilotUuid;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> serverUpdatedAt;
  final Value<String> localUpdatedAt;
  final Value<int> rowid;
  const SavedPilotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.licenseNumber = const Value.absent(),
    this.pilotUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedPilotsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.licenseNumber = const Value.absent(),
    this.pilotUuid = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required String localUpdatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        localUpdatedAt = Value(localUpdatedAt);
  static Insertable<SavedPilot> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? licenseNumber,
    Expression<String>? pilotUuid,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? serverUpdatedAt,
    Expression<String>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (pilotUuid != null) 'pilot_uuid': pilotUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedPilotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? licenseNumber,
      Value<String?>? pilotUuid,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? syncStatus,
      Value<String?>? serverUpdatedAt,
      Value<String>? localUpdatedAt,
      Value<int>? rowid}) {
    return SavedPilotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      pilotUuid: pilotUuid ?? this.pilotUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (licenseNumber.present) {
      map['license_number'] = Variable<String>(licenseNumber.value);
    }
    if (pilotUuid.present) {
      map['pilot_uuid'] = Variable<String>(pilotUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<String>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedPilotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('pilotUuid: $pilotUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HyperlogDatabase extends GeneratedDatabase {
  _$HyperlogDatabase(QueryExecutor e) : super(e);
  $HyperlogDatabaseManager get managers => $HyperlogDatabaseManager(this);
  late final $AirportsTable airports = $AirportsTable(this);
  late final $AircraftTypesTable aircraftTypes = $AircraftTypesTable(this);
  late final $FlightsTable flights = $FlightsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $PendingDeletionsTable pendingDeletions =
      $PendingDeletionsTable(this);
  late final $FlightDraftsTable flightDrafts = $FlightDraftsTable(this);
  late final $SavedPilotsTable savedPilots = $SavedPilotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        airports,
        aircraftTypes,
        flights,
        syncMetadata,
        pendingDeletions,
        flightDrafts,
        savedPilots
      ];
}

typedef $$AirportsTableCreateCompanionBuilder = AirportsCompanion Function({
  Value<int> id,
  required String ident,
  Value<String?> icaoCode,
  Value<String?> iataCode,
  required String name,
  Value<String?> municipality,
  Value<String?> isoCountry,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> timezone,
});
typedef $$AirportsTableUpdateCompanionBuilder = AirportsCompanion Function({
  Value<int> id,
  Value<String> ident,
  Value<String?> icaoCode,
  Value<String?> iataCode,
  Value<String> name,
  Value<String?> municipality,
  Value<String?> isoCountry,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> timezone,
});

class $$AirportsTableFilterComposer
    extends Composer<_$HyperlogDatabase, $AirportsTable> {
  $$AirportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ident => $composableBuilder(
      column: $table.ident, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icaoCode => $composableBuilder(
      column: $table.icaoCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iataCode => $composableBuilder(
      column: $table.iataCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isoCountry => $composableBuilder(
      column: $table.isoCountry, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));
}

class $$AirportsTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $AirportsTable> {
  $$AirportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ident => $composableBuilder(
      column: $table.ident, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icaoCode => $composableBuilder(
      column: $table.icaoCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iataCode => $composableBuilder(
      column: $table.iataCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get municipality => $composableBuilder(
      column: $table.municipality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isoCountry => $composableBuilder(
      column: $table.isoCountry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));
}

class $$AirportsTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $AirportsTable> {
  $$AirportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ident =>
      $composableBuilder(column: $table.ident, builder: (column) => column);

  GeneratedColumn<String> get icaoCode =>
      $composableBuilder(column: $table.icaoCode, builder: (column) => column);

  GeneratedColumn<String> get iataCode =>
      $composableBuilder(column: $table.iataCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => column);

  GeneratedColumn<String> get isoCountry => $composableBuilder(
      column: $table.isoCountry, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);
}

class $$AirportsTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $AirportsTable,
    Airport,
    $$AirportsTableFilterComposer,
    $$AirportsTableOrderingComposer,
    $$AirportsTableAnnotationComposer,
    $$AirportsTableCreateCompanionBuilder,
    $$AirportsTableUpdateCompanionBuilder,
    (Airport, BaseReferences<_$HyperlogDatabase, $AirportsTable, Airport>),
    Airport,
    PrefetchHooks Function()> {
  $$AirportsTableTableManager(_$HyperlogDatabase db, $AirportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AirportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AirportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AirportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> ident = const Value.absent(),
            Value<String?> icaoCode = const Value.absent(),
            Value<String?> iataCode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> municipality = const Value.absent(),
            Value<String?> isoCountry = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
          }) =>
              AirportsCompanion(
            id: id,
            ident: ident,
            icaoCode: icaoCode,
            iataCode: iataCode,
            name: name,
            municipality: municipality,
            isoCountry: isoCountry,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String ident,
            Value<String?> icaoCode = const Value.absent(),
            Value<String?> iataCode = const Value.absent(),
            required String name,
            Value<String?> municipality = const Value.absent(),
            Value<String?> isoCountry = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
          }) =>
              AirportsCompanion.insert(
            id: id,
            ident: ident,
            icaoCode: icaoCode,
            iataCode: iataCode,
            name: name,
            municipality: municipality,
            isoCountry: isoCountry,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AirportsTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $AirportsTable,
    Airport,
    $$AirportsTableFilterComposer,
    $$AirportsTableOrderingComposer,
    $$AirportsTableAnnotationComposer,
    $$AirportsTableCreateCompanionBuilder,
    $$AirportsTableUpdateCompanionBuilder,
    (Airport, BaseReferences<_$HyperlogDatabase, $AirportsTable, Airport>),
    Airport,
    PrefetchHooks Function()>;
typedef $$AircraftTypesTableCreateCompanionBuilder = AircraftTypesCompanion
    Function({
  Value<int> id,
  required String icaoDesignator,
  required String manufacturer,
  required String model,
  required String category,
  required int engineCount,
  required String engineType,
  Value<String?> wtc,
  Value<bool?> multiPilot,
  Value<bool?> complex,
  Value<bool?> highPerformance,
  Value<bool?> retractableGear,
});
typedef $$AircraftTypesTableUpdateCompanionBuilder = AircraftTypesCompanion
    Function({
  Value<int> id,
  Value<String> icaoDesignator,
  Value<String> manufacturer,
  Value<String> model,
  Value<String> category,
  Value<int> engineCount,
  Value<String> engineType,
  Value<String?> wtc,
  Value<bool?> multiPilot,
  Value<bool?> complex,
  Value<bool?> highPerformance,
  Value<bool?> retractableGear,
});

class $$AircraftTypesTableFilterComposer
    extends Composer<_$HyperlogDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icaoDesignator => $composableBuilder(
      column: $table.icaoDesignator,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get engineCount => $composableBuilder(
      column: $table.engineCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get engineType => $composableBuilder(
      column: $table.engineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wtc => $composableBuilder(
      column: $table.wtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get multiPilot => $composableBuilder(
      column: $table.multiPilot, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get complex => $composableBuilder(
      column: $table.complex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get highPerformance => $composableBuilder(
      column: $table.highPerformance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get retractableGear => $composableBuilder(
      column: $table.retractableGear,
      builder: (column) => ColumnFilters(column));
}

class $$AircraftTypesTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icaoDesignator => $composableBuilder(
      column: $table.icaoDesignator,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get engineCount => $composableBuilder(
      column: $table.engineCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get engineType => $composableBuilder(
      column: $table.engineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wtc => $composableBuilder(
      column: $table.wtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get multiPilot => $composableBuilder(
      column: $table.multiPilot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get complex => $composableBuilder(
      column: $table.complex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get highPerformance => $composableBuilder(
      column: $table.highPerformance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get retractableGear => $composableBuilder(
      column: $table.retractableGear,
      builder: (column) => ColumnOrderings(column));
}

class $$AircraftTypesTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icaoDesignator => $composableBuilder(
      column: $table.icaoDesignator, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get engineCount => $composableBuilder(
      column: $table.engineCount, builder: (column) => column);

  GeneratedColumn<String> get engineType => $composableBuilder(
      column: $table.engineType, builder: (column) => column);

  GeneratedColumn<String> get wtc =>
      $composableBuilder(column: $table.wtc, builder: (column) => column);

  GeneratedColumn<bool> get multiPilot => $composableBuilder(
      column: $table.multiPilot, builder: (column) => column);

  GeneratedColumn<bool> get complex =>
      $composableBuilder(column: $table.complex, builder: (column) => column);

  GeneratedColumn<bool> get highPerformance => $composableBuilder(
      column: $table.highPerformance, builder: (column) => column);

  GeneratedColumn<bool> get retractableGear => $composableBuilder(
      column: $table.retractableGear, builder: (column) => column);
}

class $$AircraftTypesTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $AircraftTypesTable,
    AircraftType,
    $$AircraftTypesTableFilterComposer,
    $$AircraftTypesTableOrderingComposer,
    $$AircraftTypesTableAnnotationComposer,
    $$AircraftTypesTableCreateCompanionBuilder,
    $$AircraftTypesTableUpdateCompanionBuilder,
    (
      AircraftType,
      BaseReferences<_$HyperlogDatabase, $AircraftTypesTable, AircraftType>
    ),
    AircraftType,
    PrefetchHooks Function()> {
  $$AircraftTypesTableTableManager(
      _$HyperlogDatabase db, $AircraftTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AircraftTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AircraftTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AircraftTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> icaoDesignator = const Value.absent(),
            Value<String> manufacturer = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> engineCount = const Value.absent(),
            Value<String> engineType = const Value.absent(),
            Value<String?> wtc = const Value.absent(),
            Value<bool?> multiPilot = const Value.absent(),
            Value<bool?> complex = const Value.absent(),
            Value<bool?> highPerformance = const Value.absent(),
            Value<bool?> retractableGear = const Value.absent(),
          }) =>
              AircraftTypesCompanion(
            id: id,
            icaoDesignator: icaoDesignator,
            manufacturer: manufacturer,
            model: model,
            category: category,
            engineCount: engineCount,
            engineType: engineType,
            wtc: wtc,
            multiPilot: multiPilot,
            complex: complex,
            highPerformance: highPerformance,
            retractableGear: retractableGear,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String icaoDesignator,
            required String manufacturer,
            required String model,
            required String category,
            required int engineCount,
            required String engineType,
            Value<String?> wtc = const Value.absent(),
            Value<bool?> multiPilot = const Value.absent(),
            Value<bool?> complex = const Value.absent(),
            Value<bool?> highPerformance = const Value.absent(),
            Value<bool?> retractableGear = const Value.absent(),
          }) =>
              AircraftTypesCompanion.insert(
            id: id,
            icaoDesignator: icaoDesignator,
            manufacturer: manufacturer,
            model: model,
            category: category,
            engineCount: engineCount,
            engineType: engineType,
            wtc: wtc,
            multiPilot: multiPilot,
            complex: complex,
            highPerformance: highPerformance,
            retractableGear: retractableGear,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AircraftTypesTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $AircraftTypesTable,
    AircraftType,
    $$AircraftTypesTableFilterComposer,
    $$AircraftTypesTableOrderingComposer,
    $$AircraftTypesTableAnnotationComposer,
    $$AircraftTypesTableCreateCompanionBuilder,
    $$AircraftTypesTableUpdateCompanionBuilder,
    (
      AircraftType,
      BaseReferences<_$HyperlogDatabase, $AircraftTypesTable, AircraftType>
    ),
    AircraftType,
    PrefetchHooks Function()>;
typedef $$FlightsTableCreateCompanionBuilder = FlightsCompanion Function({
  required String id,
  required String creatorUuid,
  required String flightDate,
  Value<String?> flightNumber,
  required String dep,
  required String dest,
  Value<String?> depIcao,
  Value<String?> depIata,
  Value<String?> destIcao,
  Value<String?> destIata,
  required String blockOff,
  required String blockOn,
  Value<String?> takeoffAt,
  Value<String?> landingAt,
  required String aircraftType,
  required String aircraftReg,
  required String flightTimeJson,
  Value<bool> isPilotFlying,
  Value<String?> approachesJson,
  required String crewJson,
  Value<String?> verificationsJson,
  Value<String?> endorsementsJson,
  required String createdAt,
  required String updatedAt,
  Value<String> syncStatus,
  Value<String?> serverUpdatedAt,
  required String localUpdatedAt,
  Value<int> rowid,
});
typedef $$FlightsTableUpdateCompanionBuilder = FlightsCompanion Function({
  Value<String> id,
  Value<String> creatorUuid,
  Value<String> flightDate,
  Value<String?> flightNumber,
  Value<String> dep,
  Value<String> dest,
  Value<String?> depIcao,
  Value<String?> depIata,
  Value<String?> destIcao,
  Value<String?> destIata,
  Value<String> blockOff,
  Value<String> blockOn,
  Value<String?> takeoffAt,
  Value<String?> landingAt,
  Value<String> aircraftType,
  Value<String> aircraftReg,
  Value<String> flightTimeJson,
  Value<bool> isPilotFlying,
  Value<String?> approachesJson,
  Value<String> crewJson,
  Value<String?> verificationsJson,
  Value<String?> endorsementsJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> syncStatus,
  Value<String?> serverUpdatedAt,
  Value<String> localUpdatedAt,
  Value<int> rowid,
});

class $$FlightsTableFilterComposer
    extends Composer<_$HyperlogDatabase, $FlightsTable> {
  $$FlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorUuid => $composableBuilder(
      column: $table.creatorUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flightDate => $composableBuilder(
      column: $table.flightDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flightNumber => $composableBuilder(
      column: $table.flightNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dep => $composableBuilder(
      column: $table.dep, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dest => $composableBuilder(
      column: $table.dest, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depIcao => $composableBuilder(
      column: $table.depIcao, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depIata => $composableBuilder(
      column: $table.depIata, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destIcao => $composableBuilder(
      column: $table.destIcao, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destIata => $composableBuilder(
      column: $table.destIata, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blockOff => $composableBuilder(
      column: $table.blockOff, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blockOn => $composableBuilder(
      column: $table.blockOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get takeoffAt => $composableBuilder(
      column: $table.takeoffAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get landingAt => $composableBuilder(
      column: $table.landingAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aircraftType => $composableBuilder(
      column: $table.aircraftType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aircraftReg => $composableBuilder(
      column: $table.aircraftReg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flightTimeJson => $composableBuilder(
      column: $table.flightTimeJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPilotFlying => $composableBuilder(
      column: $table.isPilotFlying, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approachesJson => $composableBuilder(
      column: $table.approachesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get crewJson => $composableBuilder(
      column: $table.crewJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationsJson => $composableBuilder(
      column: $table.verificationsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endorsementsJson => $composableBuilder(
      column: $table.endorsementsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$FlightsTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $FlightsTable> {
  $$FlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorUuid => $composableBuilder(
      column: $table.creatorUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flightDate => $composableBuilder(
      column: $table.flightDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flightNumber => $composableBuilder(
      column: $table.flightNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dep => $composableBuilder(
      column: $table.dep, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dest => $composableBuilder(
      column: $table.dest, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depIcao => $composableBuilder(
      column: $table.depIcao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depIata => $composableBuilder(
      column: $table.depIata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destIcao => $composableBuilder(
      column: $table.destIcao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destIata => $composableBuilder(
      column: $table.destIata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockOff => $composableBuilder(
      column: $table.blockOff, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockOn => $composableBuilder(
      column: $table.blockOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get takeoffAt => $composableBuilder(
      column: $table.takeoffAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get landingAt => $composableBuilder(
      column: $table.landingAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aircraftType => $composableBuilder(
      column: $table.aircraftType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aircraftReg => $composableBuilder(
      column: $table.aircraftReg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flightTimeJson => $composableBuilder(
      column: $table.flightTimeJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPilotFlying => $composableBuilder(
      column: $table.isPilotFlying,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approachesJson => $composableBuilder(
      column: $table.approachesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get crewJson => $composableBuilder(
      column: $table.crewJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationsJson => $composableBuilder(
      column: $table.verificationsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endorsementsJson => $composableBuilder(
      column: $table.endorsementsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$FlightsTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $FlightsTable> {
  $$FlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get creatorUuid => $composableBuilder(
      column: $table.creatorUuid, builder: (column) => column);

  GeneratedColumn<String> get flightDate => $composableBuilder(
      column: $table.flightDate, builder: (column) => column);

  GeneratedColumn<String> get flightNumber => $composableBuilder(
      column: $table.flightNumber, builder: (column) => column);

  GeneratedColumn<String> get dep =>
      $composableBuilder(column: $table.dep, builder: (column) => column);

  GeneratedColumn<String> get dest =>
      $composableBuilder(column: $table.dest, builder: (column) => column);

  GeneratedColumn<String> get depIcao =>
      $composableBuilder(column: $table.depIcao, builder: (column) => column);

  GeneratedColumn<String> get depIata =>
      $composableBuilder(column: $table.depIata, builder: (column) => column);

  GeneratedColumn<String> get destIcao =>
      $composableBuilder(column: $table.destIcao, builder: (column) => column);

  GeneratedColumn<String> get destIata =>
      $composableBuilder(column: $table.destIata, builder: (column) => column);

  GeneratedColumn<String> get blockOff =>
      $composableBuilder(column: $table.blockOff, builder: (column) => column);

  GeneratedColumn<String> get blockOn =>
      $composableBuilder(column: $table.blockOn, builder: (column) => column);

  GeneratedColumn<String> get takeoffAt =>
      $composableBuilder(column: $table.takeoffAt, builder: (column) => column);

  GeneratedColumn<String> get landingAt =>
      $composableBuilder(column: $table.landingAt, builder: (column) => column);

  GeneratedColumn<String> get aircraftType => $composableBuilder(
      column: $table.aircraftType, builder: (column) => column);

  GeneratedColumn<String> get aircraftReg => $composableBuilder(
      column: $table.aircraftReg, builder: (column) => column);

  GeneratedColumn<String> get flightTimeJson => $composableBuilder(
      column: $table.flightTimeJson, builder: (column) => column);

  GeneratedColumn<bool> get isPilotFlying => $composableBuilder(
      column: $table.isPilotFlying, builder: (column) => column);

  GeneratedColumn<String> get approachesJson => $composableBuilder(
      column: $table.approachesJson, builder: (column) => column);

  GeneratedColumn<String> get crewJson =>
      $composableBuilder(column: $table.crewJson, builder: (column) => column);

  GeneratedColumn<String> get verificationsJson => $composableBuilder(
      column: $table.verificationsJson, builder: (column) => column);

  GeneratedColumn<String> get endorsementsJson => $composableBuilder(
      column: $table.endorsementsJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);
}

class $$FlightsTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $FlightsTable,
    Flight,
    $$FlightsTableFilterComposer,
    $$FlightsTableOrderingComposer,
    $$FlightsTableAnnotationComposer,
    $$FlightsTableCreateCompanionBuilder,
    $$FlightsTableUpdateCompanionBuilder,
    (Flight, BaseReferences<_$HyperlogDatabase, $FlightsTable, Flight>),
    Flight,
    PrefetchHooks Function()> {
  $$FlightsTableTableManager(_$HyperlogDatabase db, $FlightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> creatorUuid = const Value.absent(),
            Value<String> flightDate = const Value.absent(),
            Value<String?> flightNumber = const Value.absent(),
            Value<String> dep = const Value.absent(),
            Value<String> dest = const Value.absent(),
            Value<String?> depIcao = const Value.absent(),
            Value<String?> depIata = const Value.absent(),
            Value<String?> destIcao = const Value.absent(),
            Value<String?> destIata = const Value.absent(),
            Value<String> blockOff = const Value.absent(),
            Value<String> blockOn = const Value.absent(),
            Value<String?> takeoffAt = const Value.absent(),
            Value<String?> landingAt = const Value.absent(),
            Value<String> aircraftType = const Value.absent(),
            Value<String> aircraftReg = const Value.absent(),
            Value<String> flightTimeJson = const Value.absent(),
            Value<bool> isPilotFlying = const Value.absent(),
            Value<String?> approachesJson = const Value.absent(),
            Value<String> crewJson = const Value.absent(),
            Value<String?> verificationsJson = const Value.absent(),
            Value<String?> endorsementsJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverUpdatedAt = const Value.absent(),
            Value<String> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlightsCompanion(
            id: id,
            creatorUuid: creatorUuid,
            flightDate: flightDate,
            flightNumber: flightNumber,
            dep: dep,
            dest: dest,
            depIcao: depIcao,
            depIata: depIata,
            destIcao: destIcao,
            destIata: destIata,
            blockOff: blockOff,
            blockOn: blockOn,
            takeoffAt: takeoffAt,
            landingAt: landingAt,
            aircraftType: aircraftType,
            aircraftReg: aircraftReg,
            flightTimeJson: flightTimeJson,
            isPilotFlying: isPilotFlying,
            approachesJson: approachesJson,
            crewJson: crewJson,
            verificationsJson: verificationsJson,
            endorsementsJson: endorsementsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverUpdatedAt: serverUpdatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String creatorUuid,
            required String flightDate,
            Value<String?> flightNumber = const Value.absent(),
            required String dep,
            required String dest,
            Value<String?> depIcao = const Value.absent(),
            Value<String?> depIata = const Value.absent(),
            Value<String?> destIcao = const Value.absent(),
            Value<String?> destIata = const Value.absent(),
            required String blockOff,
            required String blockOn,
            Value<String?> takeoffAt = const Value.absent(),
            Value<String?> landingAt = const Value.absent(),
            required String aircraftType,
            required String aircraftReg,
            required String flightTimeJson,
            Value<bool> isPilotFlying = const Value.absent(),
            Value<String?> approachesJson = const Value.absent(),
            required String crewJson,
            Value<String?> verificationsJson = const Value.absent(),
            Value<String?> endorsementsJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverUpdatedAt = const Value.absent(),
            required String localUpdatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FlightsCompanion.insert(
            id: id,
            creatorUuid: creatorUuid,
            flightDate: flightDate,
            flightNumber: flightNumber,
            dep: dep,
            dest: dest,
            depIcao: depIcao,
            depIata: depIata,
            destIcao: destIcao,
            destIata: destIata,
            blockOff: blockOff,
            blockOn: blockOn,
            takeoffAt: takeoffAt,
            landingAt: landingAt,
            aircraftType: aircraftType,
            aircraftReg: aircraftReg,
            flightTimeJson: flightTimeJson,
            isPilotFlying: isPilotFlying,
            approachesJson: approachesJson,
            crewJson: crewJson,
            verificationsJson: verificationsJson,
            endorsementsJson: endorsementsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverUpdatedAt: serverUpdatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlightsTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $FlightsTable,
    Flight,
    $$FlightsTableFilterComposer,
    $$FlightsTableOrderingComposer,
    $$FlightsTableAnnotationComposer,
    $$FlightsTableCreateCompanionBuilder,
    $$FlightsTableUpdateCompanionBuilder,
    (Flight, BaseReferences<_$HyperlogDatabase, $FlightsTable, Flight>),
    Flight,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableCreateCompanionBuilder = SyncMetadataCompanion
    Function({
  required String entityType,
  Value<String?> lastSyncAt,
  Value<int?> recordCount,
  Value<int> rowid,
});
typedef $$SyncMetadataTableUpdateCompanionBuilder = SyncMetadataCompanion
    Function({
  Value<String> entityType,
  Value<String?> lastSyncAt,
  Value<int?> recordCount,
  Value<int> rowid,
});

class $$SyncMetadataTableFilterComposer
    extends Composer<_$HyperlogDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => column);
}

class $$SyncMetadataTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$HyperlogDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableManager(
      _$HyperlogDatabase db, $SyncMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<String?> lastSyncAt = const Value.absent(),
            Value<int?> recordCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion(
            entityType: entityType,
            lastSyncAt: lastSyncAt,
            recordCount: recordCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            Value<String?> lastSyncAt = const Value.absent(),
            Value<int?> recordCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion.insert(
            entityType: entityType,
            lastSyncAt: lastSyncAt,
            recordCount: recordCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$HyperlogDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()>;
typedef $$PendingDeletionsTableCreateCompanionBuilder
    = PendingDeletionsCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String deletedAt,
  Value<int> rowid,
});
typedef $$PendingDeletionsTableUpdateCompanionBuilder
    = PendingDeletionsCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> deletedAt,
  Value<int> rowid,
});

class $$PendingDeletionsTableFilterComposer
    extends Composer<_$HyperlogDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PendingDeletionsTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PendingDeletionsTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $PendingDeletionsTable> {
  $$PendingDeletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PendingDeletionsTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $PendingDeletionsTable,
    PendingDeletion,
    $$PendingDeletionsTableFilterComposer,
    $$PendingDeletionsTableOrderingComposer,
    $$PendingDeletionsTableAnnotationComposer,
    $$PendingDeletionsTableCreateCompanionBuilder,
    $$PendingDeletionsTableUpdateCompanionBuilder,
    (
      PendingDeletion,
      BaseReferences<_$HyperlogDatabase, $PendingDeletionsTable,
          PendingDeletion>
    ),
    PendingDeletion,
    PrefetchHooks Function()> {
  $$PendingDeletionsTableTableManager(
      _$HyperlogDatabase db, $PendingDeletionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingDeletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingDeletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingDeletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingDeletionsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String deletedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingDeletionsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingDeletionsTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $PendingDeletionsTable,
    PendingDeletion,
    $$PendingDeletionsTableFilterComposer,
    $$PendingDeletionsTableOrderingComposer,
    $$PendingDeletionsTableAnnotationComposer,
    $$PendingDeletionsTableCreateCompanionBuilder,
    $$PendingDeletionsTableUpdateCompanionBuilder,
    (
      PendingDeletion,
      BaseReferences<_$HyperlogDatabase, $PendingDeletionsTable,
          PendingDeletion>
    ),
    PendingDeletion,
    PrefetchHooks Function()>;
typedef $$FlightDraftsTableCreateCompanionBuilder = FlightDraftsCompanion
    Function({
  required String id,
  required String formData,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$FlightDraftsTableUpdateCompanionBuilder = FlightDraftsCompanion
    Function({
  Value<String> id,
  Value<String> formData,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$FlightDraftsTableFilterComposer
    extends Composer<_$HyperlogDatabase, $FlightDraftsTable> {
  $$FlightDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formData => $composableBuilder(
      column: $table.formData, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FlightDraftsTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $FlightDraftsTable> {
  $$FlightDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formData => $composableBuilder(
      column: $table.formData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FlightDraftsTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $FlightDraftsTable> {
  $$FlightDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formData =>
      $composableBuilder(column: $table.formData, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlightDraftsTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $FlightDraftsTable,
    FlightDraft,
    $$FlightDraftsTableFilterComposer,
    $$FlightDraftsTableOrderingComposer,
    $$FlightDraftsTableAnnotationComposer,
    $$FlightDraftsTableCreateCompanionBuilder,
    $$FlightDraftsTableUpdateCompanionBuilder,
    (
      FlightDraft,
      BaseReferences<_$HyperlogDatabase, $FlightDraftsTable, FlightDraft>
    ),
    FlightDraft,
    PrefetchHooks Function()> {
  $$FlightDraftsTableTableManager(
      _$HyperlogDatabase db, $FlightDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlightDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlightDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlightDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> formData = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlightDraftsCompanion(
            id: id,
            formData: formData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String formData,
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FlightDraftsCompanion.insert(
            id: id,
            formData: formData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlightDraftsTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $FlightDraftsTable,
    FlightDraft,
    $$FlightDraftsTableFilterComposer,
    $$FlightDraftsTableOrderingComposer,
    $$FlightDraftsTableAnnotationComposer,
    $$FlightDraftsTableCreateCompanionBuilder,
    $$FlightDraftsTableUpdateCompanionBuilder,
    (
      FlightDraft,
      BaseReferences<_$HyperlogDatabase, $FlightDraftsTable, FlightDraft>
    ),
    FlightDraft,
    PrefetchHooks Function()>;
typedef $$SavedPilotsTableCreateCompanionBuilder = SavedPilotsCompanion
    Function({
  required String id,
  required String userId,
  required String name,
  Value<String?> licenseNumber,
  Value<String?> pilotUuid,
  required String createdAt,
  required String updatedAt,
  Value<String> syncStatus,
  Value<String?> serverUpdatedAt,
  required String localUpdatedAt,
  Value<int> rowid,
});
typedef $$SavedPilotsTableUpdateCompanionBuilder = SavedPilotsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String?> licenseNumber,
  Value<String?> pilotUuid,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> syncStatus,
  Value<String?> serverUpdatedAt,
  Value<String> localUpdatedAt,
  Value<int> rowid,
});

class $$SavedPilotsTableFilterComposer
    extends Composer<_$HyperlogDatabase, $SavedPilotsTable> {
  $$SavedPilotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseNumber => $composableBuilder(
      column: $table.licenseNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pilotUuid => $composableBuilder(
      column: $table.pilotUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$SavedPilotsTableOrderingComposer
    extends Composer<_$HyperlogDatabase, $SavedPilotsTable> {
  $$SavedPilotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseNumber => $composableBuilder(
      column: $table.licenseNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pilotUuid => $composableBuilder(
      column: $table.pilotUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SavedPilotsTableAnnotationComposer
    extends Composer<_$HyperlogDatabase, $SavedPilotsTable> {
  $$SavedPilotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get licenseNumber => $composableBuilder(
      column: $table.licenseNumber, builder: (column) => column);

  GeneratedColumn<String> get pilotUuid =>
      $composableBuilder(column: $table.pilotUuid, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);
}

class $$SavedPilotsTableTableManager extends RootTableManager<
    _$HyperlogDatabase,
    $SavedPilotsTable,
    SavedPilot,
    $$SavedPilotsTableFilterComposer,
    $$SavedPilotsTableOrderingComposer,
    $$SavedPilotsTableAnnotationComposer,
    $$SavedPilotsTableCreateCompanionBuilder,
    $$SavedPilotsTableUpdateCompanionBuilder,
    (
      SavedPilot,
      BaseReferences<_$HyperlogDatabase, $SavedPilotsTable, SavedPilot>
    ),
    SavedPilot,
    PrefetchHooks Function()> {
  $$SavedPilotsTableTableManager(_$HyperlogDatabase db, $SavedPilotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedPilotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedPilotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedPilotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> licenseNumber = const Value.absent(),
            Value<String?> pilotUuid = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverUpdatedAt = const Value.absent(),
            Value<String> localUpdatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedPilotsCompanion(
            id: id,
            userId: userId,
            name: name,
            licenseNumber: licenseNumber,
            pilotUuid: pilotUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverUpdatedAt: serverUpdatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<String?> licenseNumber = const Value.absent(),
            Value<String?> pilotUuid = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverUpdatedAt = const Value.absent(),
            required String localUpdatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedPilotsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            licenseNumber: licenseNumber,
            pilotUuid: pilotUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverUpdatedAt: serverUpdatedAt,
            localUpdatedAt: localUpdatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedPilotsTableProcessedTableManager = ProcessedTableManager<
    _$HyperlogDatabase,
    $SavedPilotsTable,
    SavedPilot,
    $$SavedPilotsTableFilterComposer,
    $$SavedPilotsTableOrderingComposer,
    $$SavedPilotsTableAnnotationComposer,
    $$SavedPilotsTableCreateCompanionBuilder,
    $$SavedPilotsTableUpdateCompanionBuilder,
    (
      SavedPilot,
      BaseReferences<_$HyperlogDatabase, $SavedPilotsTable, SavedPilot>
    ),
    SavedPilot,
    PrefetchHooks Function()>;

class $HyperlogDatabaseManager {
  final _$HyperlogDatabase _db;
  $HyperlogDatabaseManager(this._db);
  $$AirportsTableTableManager get airports =>
      $$AirportsTableTableManager(_db, _db.airports);
  $$AircraftTypesTableTableManager get aircraftTypes =>
      $$AircraftTypesTableTableManager(_db, _db.aircraftTypes);
  $$FlightsTableTableManager get flights =>
      $$FlightsTableTableManager(_db, _db.flights);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$PendingDeletionsTableTableManager get pendingDeletions =>
      $$PendingDeletionsTableTableManager(_db, _db.pendingDeletions);
  $$FlightDraftsTableTableManager get flightDrafts =>
      $$FlightDraftsTableTableManager(_db, _db.flightDrafts);
  $$SavedPilotsTableTableManager get savedPilots =>
      $$SavedPilotsTableTableManager(_db, _db.savedPilots);
}
