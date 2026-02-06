// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAnonymousMeta =
      const VerificationMeta('isAnonymous');
  @override
  late final GeneratedColumn<bool> isAnonymous = GeneratedColumn<bool>(
      'is_anonymous', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_anonymous" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isCurrentMeta =
      const VerificationMeta('isCurrent');
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
      'is_current', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_current" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        displayName,
        email,
        avatarUrl,
        isAnonymous,
        deviceId,
        createdAt,
        updatedAt,
        isCurrent
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('is_anonymous')) {
      context.handle(
          _isAnonymousMeta,
          isAnonymous.isAcceptableOrUnknown(
              data['is_anonymous']!, _isAnonymousMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_current')) {
      context.handle(_isCurrentMeta,
          isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      isAnonymous: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_anonymous'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// Local UUID - primary key, client-generated.
  final String id;

  /// Remote Supabase UUID (null if not synced yet).
  final String? remoteId;

  /// User display name.
  final String displayName;

  /// Email address (null for anonymous users).
  final String? email;

  /// Avatar image URL.
  final String? avatarUrl;

  /// Whether this is an anonymous (local-only) user.
  final bool isAnonymous;

  /// Device ID for anonymous users (used for data migration on account creation).
  final String? deviceId;

  /// Timestamp when the user was created.
  final DateTime createdAt;

  /// Timestamp when the user was last updated.
  final DateTime updatedAt;

  /// Whether this is the currently active user on this device.
  final bool isCurrent;
  const User(
      {required this.id,
      this.remoteId,
      required this.displayName,
      this.email,
      this.avatarUrl,
      required this.isAnonymous,
      this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      required this.isCurrent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_anonymous'] = Variable<bool>(isAnonymous);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      displayName: Value(displayName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isAnonymous: Value(isAnonymous),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isCurrent: Value(isCurrent),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String?>(json['email']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isAnonymous: serializer.fromJson<bool>(json['isAnonymous']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String?>(email),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isAnonymous': serializer.toJson<bool>(isAnonymous),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  User copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? displayName,
          Value<String?> email = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          bool? isAnonymous,
          Value<String?> deviceId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isCurrent}) =>
      User(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        displayName: displayName ?? this.displayName,
        email: email.present ? email.value : this.email,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isCurrent: isCurrent ?? this.isCurrent,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      isAnonymous:
          data.isAnonymous.present ? data.isAnonymous.value : this.isAnonymous,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, displayName, email, avatarUrl,
      isAnonymous, deviceId, createdAt, updatedAt, isCurrent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.isAnonymous == this.isAnonymous &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isCurrent == this.isCurrent);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> displayName;
  final Value<String?> email;
  final Value<String?> avatarUrl;
  final Value<bool> isAnonymous;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isCurrent;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String displayName,
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<bool>? isAnonymous,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isCurrent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isAnonymous != null) 'is_anonymous': isAnonymous,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isCurrent != null) 'is_current': isCurrent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? displayName,
      Value<String?>? email,
      Value<String?>? avatarUrl,
      Value<bool>? isAnonymous,
      Value<String?>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isCurrent,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCurrent: isCurrent ?? this.isCurrent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isAnonymous.present) {
      map['is_anonymous'] = Variable<bool>(isAnonymous.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ForaysTable extends Forays with TableInfo<$ForaysTable, Foray> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creatorIdMeta =
      const VerificationMeta('creatorId');
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
      'creator_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _locationNameMeta =
      const VerificationMeta('locationName');
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
      'location_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PrivacyLevel, String>
      defaultPrivacy = GeneratedColumn<String>(
              'default_privacy', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('private'))
          .withConverter<PrivacyLevel>($ForaysTable.$converterdefaultPrivacy);
  static const VerificationMeta _joinCodeMeta =
      const VerificationMeta('joinCode');
  @override
  late final GeneratedColumn<String> joinCode = GeneratedColumn<String>(
      'join_code', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 6),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ForayStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('active'))
          .withConverter<ForayStatus>($ForaysTable.$converterstatus);
  static const VerificationMeta _isSoloMeta = const VerificationMeta('isSolo');
  @override
  late final GeneratedColumn<bool> isSolo = GeneratedColumn<bool>(
      'is_solo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_solo" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _observationsLockedMeta =
      const VerificationMeta('observationsLocked');
  @override
  late final GeneratedColumn<bool> observationsLocked = GeneratedColumn<bool>(
      'observations_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("observations_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('local'))
          .withConverter<SyncStatus>($ForaysTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        creatorId,
        name,
        description,
        date,
        locationName,
        defaultPrivacy,
        joinCode,
        status,
        isSolo,
        observationsLocked,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forays';
  @override
  VerificationContext validateIntegrity(Insertable<Foray> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('creator_id')) {
      context.handle(_creatorIdMeta,
          creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta));
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('location_name')) {
      context.handle(
          _locationNameMeta,
          locationName.isAcceptableOrUnknown(
              data['location_name']!, _locationNameMeta));
    }
    if (data.containsKey('join_code')) {
      context.handle(_joinCodeMeta,
          joinCode.isAcceptableOrUnknown(data['join_code']!, _joinCodeMeta));
    }
    if (data.containsKey('is_solo')) {
      context.handle(_isSoloMeta,
          isSolo.isAcceptableOrUnknown(data['is_solo']!, _isSoloMeta));
    }
    if (data.containsKey('observations_locked')) {
      context.handle(
          _observationsLockedMeta,
          observationsLocked.isAcceptableOrUnknown(
              data['observations_locked']!, _observationsLockedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Foray map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Foray(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      creatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}creator_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      locationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_name']),
      defaultPrivacy: $ForaysTable.$converterdefaultPrivacy.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}default_privacy'])!),
      joinCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}join_code']),
      status: $ForaysTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      isSolo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_solo'])!,
      observationsLocked: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}observations_locked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: $ForaysTable.$convertersyncStatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $ForaysTable createAlias(String alias) {
    return $ForaysTable(attachedDatabase, alias);
  }

  static TypeConverter<PrivacyLevel, String> $converterdefaultPrivacy =
      const PrivacyLevelConverter();
  static TypeConverter<ForayStatus, String> $converterstatus =
      const ForayStatusConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class Foray extends DataClass implements Insertable<Foray> {
  /// Local UUID - client-generated.
  final String id;

  /// Remote Supabase UUID (null until synced).
  final String? remoteId;

  /// Creator/organizer user ID.
  final String creatorId;

  /// Name of the foray.
  final String name;

  /// Optional description.
  final String? description;

  /// Date of the foray.
  final DateTime date;

  /// Human-readable location name.
  final String? locationName;

  /// Default privacy level for observations in this foray.
  final PrivacyLevel defaultPrivacy;

  /// 6-character join code for group forays.
  final String? joinCode;

  /// Current status of the foray.
  final ForayStatus status;

  /// Whether this is a solo (personal) foray.
  final bool isSolo;

  /// Whether new observations/edits are locked.
  final bool observationsLocked;

  /// Timestamp when created.
  final DateTime createdAt;

  /// Timestamp when last updated.
  final DateTime updatedAt;

  /// Sync status.
  final SyncStatus syncStatus;
  const Foray(
      {required this.id,
      this.remoteId,
      required this.creatorId,
      required this.name,
      this.description,
      required this.date,
      this.locationName,
      required this.defaultPrivacy,
      this.joinCode,
      required this.status,
      required this.isSolo,
      required this.observationsLocked,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['creator_id'] = Variable<String>(creatorId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    {
      map['default_privacy'] = Variable<String>(
          $ForaysTable.$converterdefaultPrivacy.toSql(defaultPrivacy));
    }
    if (!nullToAbsent || joinCode != null) {
      map['join_code'] = Variable<String>(joinCode);
    }
    {
      map['status'] =
          Variable<String>($ForaysTable.$converterstatus.toSql(status));
    }
    map['is_solo'] = Variable<bool>(isSolo);
    map['observations_locked'] = Variable<bool>(observationsLocked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['sync_status'] =
          Variable<String>($ForaysTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  ForaysCompanion toCompanion(bool nullToAbsent) {
    return ForaysCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      creatorId: Value(creatorId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      defaultPrivacy: Value(defaultPrivacy),
      joinCode: joinCode == null && nullToAbsent
          ? const Value.absent()
          : Value(joinCode),
      status: Value(status),
      isSolo: Value(isSolo),
      observationsLocked: Value(observationsLocked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Foray.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Foray(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      creatorId: serializer.fromJson<String>(json['creatorId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      defaultPrivacy: serializer.fromJson<PrivacyLevel>(json['defaultPrivacy']),
      joinCode: serializer.fromJson<String?>(json['joinCode']),
      status: serializer.fromJson<ForayStatus>(json['status']),
      isSolo: serializer.fromJson<bool>(json['isSolo']),
      observationsLocked: serializer.fromJson<bool>(json['observationsLocked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'creatorId': serializer.toJson<String>(creatorId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'locationName': serializer.toJson<String?>(locationName),
      'defaultPrivacy': serializer.toJson<PrivacyLevel>(defaultPrivacy),
      'joinCode': serializer.toJson<String?>(joinCode),
      'status': serializer.toJson<ForayStatus>(status),
      'isSolo': serializer.toJson<bool>(isSolo),
      'observationsLocked': serializer.toJson<bool>(observationsLocked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  Foray copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? creatorId,
          String? name,
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<String?> locationName = const Value.absent(),
          PrivacyLevel? defaultPrivacy,
          Value<String?> joinCode = const Value.absent(),
          ForayStatus? status,
          bool? isSolo,
          bool? observationsLocked,
          DateTime? createdAt,
          DateTime? updatedAt,
          SyncStatus? syncStatus}) =>
      Foray(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        creatorId: creatorId ?? this.creatorId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        locationName:
            locationName.present ? locationName.value : this.locationName,
        defaultPrivacy: defaultPrivacy ?? this.defaultPrivacy,
        joinCode: joinCode.present ? joinCode.value : this.joinCode,
        status: status ?? this.status,
        isSolo: isSolo ?? this.isSolo,
        observationsLocked: observationsLocked ?? this.observationsLocked,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Foray copyWithCompanion(ForaysCompanion data) {
    return Foray(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      defaultPrivacy: data.defaultPrivacy.present
          ? data.defaultPrivacy.value
          : this.defaultPrivacy,
      joinCode: data.joinCode.present ? data.joinCode.value : this.joinCode,
      status: data.status.present ? data.status.value : this.status,
      isSolo: data.isSolo.present ? data.isSolo.value : this.isSolo,
      observationsLocked: data.observationsLocked.present
          ? data.observationsLocked.value
          : this.observationsLocked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Foray(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('creatorId: $creatorId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('locationName: $locationName, ')
          ..write('defaultPrivacy: $defaultPrivacy, ')
          ..write('joinCode: $joinCode, ')
          ..write('status: $status, ')
          ..write('isSolo: $isSolo, ')
          ..write('observationsLocked: $observationsLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      creatorId,
      name,
      description,
      date,
      locationName,
      defaultPrivacy,
      joinCode,
      status,
      isSolo,
      observationsLocked,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Foray &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.creatorId == this.creatorId &&
          other.name == this.name &&
          other.description == this.description &&
          other.date == this.date &&
          other.locationName == this.locationName &&
          other.defaultPrivacy == this.defaultPrivacy &&
          other.joinCode == this.joinCode &&
          other.status == this.status &&
          other.isSolo == this.isSolo &&
          other.observationsLocked == this.observationsLocked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ForaysCompanion extends UpdateCompanion<Foray> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> creatorId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<String?> locationName;
  final Value<PrivacyLevel> defaultPrivacy;
  final Value<String?> joinCode;
  final Value<ForayStatus> status;
  final Value<bool> isSolo;
  final Value<bool> observationsLocked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const ForaysCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.locationName = const Value.absent(),
    this.defaultPrivacy = const Value.absent(),
    this.joinCode = const Value.absent(),
    this.status = const Value.absent(),
    this.isSolo = const Value.absent(),
    this.observationsLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForaysCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String creatorId,
    required String name,
    this.description = const Value.absent(),
    required DateTime date,
    this.locationName = const Value.absent(),
    this.defaultPrivacy = const Value.absent(),
    this.joinCode = const Value.absent(),
    this.status = const Value.absent(),
    this.isSolo = const Value.absent(),
    this.observationsLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        creatorId = Value(creatorId),
        name = Value(name),
        date = Value(date);
  static Insertable<Foray> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? creatorId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? locationName,
    Expression<String>? defaultPrivacy,
    Expression<String>? joinCode,
    Expression<String>? status,
    Expression<bool>? isSolo,
    Expression<bool>? observationsLocked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (creatorId != null) 'creator_id': creatorId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (locationName != null) 'location_name': locationName,
      if (defaultPrivacy != null) 'default_privacy': defaultPrivacy,
      if (joinCode != null) 'join_code': joinCode,
      if (status != null) 'status': status,
      if (isSolo != null) 'is_solo': isSolo,
      if (observationsLocked != null) 'observations_locked': observationsLocked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForaysCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? creatorId,
      Value<String>? name,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<String?>? locationName,
      Value<PrivacyLevel>? defaultPrivacy,
      Value<String?>? joinCode,
      Value<ForayStatus>? status,
      Value<bool>? isSolo,
      Value<bool>? observationsLocked,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return ForaysCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      locationName: locationName ?? this.locationName,
      defaultPrivacy: defaultPrivacy ?? this.defaultPrivacy,
      joinCode: joinCode ?? this.joinCode,
      status: status ?? this.status,
      isSolo: isSolo ?? this.isSolo,
      observationsLocked: observationsLocked ?? this.observationsLocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (defaultPrivacy.present) {
      map['default_privacy'] = Variable<String>(
          $ForaysTable.$converterdefaultPrivacy.toSql(defaultPrivacy.value));
    }
    if (joinCode.present) {
      map['join_code'] = Variable<String>(joinCode.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($ForaysTable.$converterstatus.toSql(status.value));
    }
    if (isSolo.present) {
      map['is_solo'] = Variable<bool>(isSolo.value);
    }
    if (observationsLocked.present) {
      map['observations_locked'] = Variable<bool>(observationsLocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $ForaysTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForaysCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('creatorId: $creatorId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('locationName: $locationName, ')
          ..write('defaultPrivacy: $defaultPrivacy, ')
          ..write('joinCode: $joinCode, ')
          ..write('status: $status, ')
          ..write('isSolo: $isSolo, ')
          ..write('observationsLocked: $observationsLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ForayParticipantsTable extends ForayParticipants
    with TableInfo<$ForayParticipantsTable, ForayParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForayParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _forayIdMeta =
      const VerificationMeta('forayId');
  @override
  late final GeneratedColumn<String> forayId = GeneratedColumn<String>(
      'foray_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES forays (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<ParticipantRole, String> role =
      GeneratedColumn<String>('role', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('participant'))
          .withConverter<ParticipantRole>(
              $ForayParticipantsTable.$converterrole);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [forayId, userId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foray_participants';
  @override
  VerificationContext validateIntegrity(Insertable<ForayParticipant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('foray_id')) {
      context.handle(_forayIdMeta,
          forayId.isAcceptableOrUnknown(data['foray_id']!, _forayIdMeta));
    } else if (isInserting) {
      context.missing(_forayIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {forayId, userId};
  @override
  ForayParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ForayParticipant(
      forayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foray_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: $ForayParticipantsTable.$converterrole.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!),
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $ForayParticipantsTable createAlias(String alias) {
    return $ForayParticipantsTable(attachedDatabase, alias);
  }

  static TypeConverter<ParticipantRole, String> $converterrole =
      const ParticipantRoleConverter();
}

class ForayParticipant extends DataClass
    implements Insertable<ForayParticipant> {
  /// Foreign key to foray.
  final String forayId;

  /// Foreign key to user.
  final String userId;

  /// Role of this participant.
  final ParticipantRole role;

  /// When the user joined this foray.
  final DateTime joinedAt;
  const ForayParticipant(
      {required this.forayId,
      required this.userId,
      required this.role,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['foray_id'] = Variable<String>(forayId);
    map['user_id'] = Variable<String>(userId);
    {
      map['role'] =
          Variable<String>($ForayParticipantsTable.$converterrole.toSql(role));
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  ForayParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ForayParticipantsCompanion(
      forayId: Value(forayId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory ForayParticipant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ForayParticipant(
      forayId: serializer.fromJson<String>(json['forayId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<ParticipantRole>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'forayId': serializer.toJson<String>(forayId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<ParticipantRole>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  ForayParticipant copyWith(
          {String? forayId,
          String? userId,
          ParticipantRole? role,
          DateTime? joinedAt}) =>
      ForayParticipant(
        forayId: forayId ?? this.forayId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  ForayParticipant copyWithCompanion(ForayParticipantsCompanion data) {
    return ForayParticipant(
      forayId: data.forayId.present ? data.forayId.value : this.forayId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ForayParticipant(')
          ..write('forayId: $forayId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(forayId, userId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForayParticipant &&
          other.forayId == this.forayId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class ForayParticipantsCompanion extends UpdateCompanion<ForayParticipant> {
  final Value<String> forayId;
  final Value<String> userId;
  final Value<ParticipantRole> role;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const ForayParticipantsCompanion({
    this.forayId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForayParticipantsCompanion.insert({
    required String forayId,
    required String userId,
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : forayId = Value(forayId),
        userId = Value(userId);
  static Insertable<ForayParticipant> custom({
    Expression<String>? forayId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (forayId != null) 'foray_id': forayId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForayParticipantsCompanion copyWith(
      {Value<String>? forayId,
      Value<String>? userId,
      Value<ParticipantRole>? role,
      Value<DateTime>? joinedAt,
      Value<int>? rowid}) {
    return ForayParticipantsCompanion(
      forayId: forayId ?? this.forayId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (forayId.present) {
      map['foray_id'] = Variable<String>(forayId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
          $ForayParticipantsTable.$converterrole.toSql(role.value));
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForayParticipantsCompanion(')
          ..write('forayId: $forayId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _forayIdMeta =
      const VerificationMeta('forayId');
  @override
  late final GeneratedColumn<String> forayId = GeneratedColumn<String>(
      'foray_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES forays (id)'));
  static const VerificationMeta _collectorIdMeta =
      const VerificationMeta('collectorId');
  @override
  late final GeneratedColumn<String> collectorId = GeneratedColumn<String>(
      'collector_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gpsAccuracyMeta =
      const VerificationMeta('gpsAccuracy');
  @override
  late final GeneratedColumn<double> gpsAccuracy = GeneratedColumn<double>(
      'gps_accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PrivacyLevel, String>
      privacyLevel = GeneratedColumn<String>(
              'privacy_level', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('private'))
          .withConverter<PrivacyLevel>(
              $ObservationsTable.$converterprivacyLevel);
  static const VerificationMeta _observedAtMeta =
      const VerificationMeta('observedAt');
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
      'observed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _specimenIdMeta =
      const VerificationMeta('specimenId');
  @override
  late final GeneratedColumn<String> specimenId = GeneratedColumn<String>(
      'specimen_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collectionNumberMeta =
      const VerificationMeta('collectionNumber');
  @override
  late final GeneratedColumn<String> collectionNumber = GeneratedColumn<String>(
      'collection_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _substrateMeta =
      const VerificationMeta('substrate');
  @override
  late final GeneratedColumn<String> substrate = GeneratedColumn<String>(
      'substrate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _habitatNotesMeta =
      const VerificationMeta('habitatNotes');
  @override
  late final GeneratedColumn<String> habitatNotes = GeneratedColumn<String>(
      'habitat_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fieldNotesMeta =
      const VerificationMeta('fieldNotes');
  @override
  late final GeneratedColumn<String> fieldNotes = GeneratedColumn<String>(
      'field_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sporePrintColorMeta =
      const VerificationMeta('sporePrintColor');
  @override
  late final GeneratedColumn<String> sporePrintColor = GeneratedColumn<String>(
      'spore_print_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preliminaryIdMeta =
      const VerificationMeta('preliminaryId');
  @override
  late final GeneratedColumn<String> preliminaryId = GeneratedColumn<String>(
      'preliminary_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ConfidenceLevel?, String>
      preliminaryIdConfidence = GeneratedColumn<String>(
              'preliminary_id_confidence', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<ConfidenceLevel?>(
              $ObservationsTable.$converterpreliminaryIdConfidencen);
  static const VerificationMeta _isDraftMeta =
      const VerificationMeta('isDraft');
  @override
  late final GeneratedColumn<bool> isDraft = GeneratedColumn<bool>(
      'is_draft', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_draft" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('local'))
          .withConverter<SyncStatus>($ObservationsTable.$convertersyncStatus);
  static const VerificationMeta _lastViewedAtMeta =
      const VerificationMeta('lastViewedAt');
  @override
  late final GeneratedColumn<DateTime> lastViewedAt = GeneratedColumn<DateTime>(
      'last_viewed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        forayId,
        collectorId,
        latitude,
        longitude,
        gpsAccuracy,
        altitude,
        privacyLevel,
        observedAt,
        createdAt,
        updatedAt,
        specimenId,
        collectionNumber,
        substrate,
        habitatNotes,
        fieldNotes,
        sporePrintColor,
        preliminaryId,
        preliminaryIdConfidence,
        isDraft,
        syncStatus,
        lastViewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(Insertable<Observation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('foray_id')) {
      context.handle(_forayIdMeta,
          forayId.isAcceptableOrUnknown(data['foray_id']!, _forayIdMeta));
    } else if (isInserting) {
      context.missing(_forayIdMeta);
    }
    if (data.containsKey('collector_id')) {
      context.handle(
          _collectorIdMeta,
          collectorId.isAcceptableOrUnknown(
              data['collector_id']!, _collectorIdMeta));
    } else if (isInserting) {
      context.missing(_collectorIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
          _gpsAccuracyMeta,
          gpsAccuracy.isAcceptableOrUnknown(
              data['gps_accuracy']!, _gpsAccuracyMeta));
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    }
    if (data.containsKey('observed_at')) {
      context.handle(
          _observedAtMeta,
          observedAt.isAcceptableOrUnknown(
              data['observed_at']!, _observedAtMeta));
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('specimen_id')) {
      context.handle(
          _specimenIdMeta,
          specimenId.isAcceptableOrUnknown(
              data['specimen_id']!, _specimenIdMeta));
    }
    if (data.containsKey('collection_number')) {
      context.handle(
          _collectionNumberMeta,
          collectionNumber.isAcceptableOrUnknown(
              data['collection_number']!, _collectionNumberMeta));
    }
    if (data.containsKey('substrate')) {
      context.handle(_substrateMeta,
          substrate.isAcceptableOrUnknown(data['substrate']!, _substrateMeta));
    }
    if (data.containsKey('habitat_notes')) {
      context.handle(
          _habitatNotesMeta,
          habitatNotes.isAcceptableOrUnknown(
              data['habitat_notes']!, _habitatNotesMeta));
    }
    if (data.containsKey('field_notes')) {
      context.handle(
          _fieldNotesMeta,
          fieldNotes.isAcceptableOrUnknown(
              data['field_notes']!, _fieldNotesMeta));
    }
    if (data.containsKey('spore_print_color')) {
      context.handle(
          _sporePrintColorMeta,
          sporePrintColor.isAcceptableOrUnknown(
              data['spore_print_color']!, _sporePrintColorMeta));
    }
    if (data.containsKey('preliminary_id')) {
      context.handle(
          _preliminaryIdMeta,
          preliminaryId.isAcceptableOrUnknown(
              data['preliminary_id']!, _preliminaryIdMeta));
    }
    if (data.containsKey('is_draft')) {
      context.handle(_isDraftMeta,
          isDraft.isAcceptableOrUnknown(data['is_draft']!, _isDraftMeta));
    }
    if (data.containsKey('last_viewed_at')) {
      context.handle(
          _lastViewedAtMeta,
          lastViewedAt.isAcceptableOrUnknown(
              data['last_viewed_at']!, _lastViewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      forayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foray_id'])!,
      collectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collector_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      gpsAccuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_accuracy']),
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude']),
      privacyLevel: $ObservationsTable.$converterprivacyLevel.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}privacy_level'])!),
      observedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}observed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      specimenId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimen_id']),
      collectionNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collection_number']),
      substrate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}substrate']),
      habitatNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habitat_notes']),
      fieldNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_notes']),
      sporePrintColor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}spore_print_color']),
      preliminaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preliminary_id']),
      preliminaryIdConfidence: $ObservationsTable
          .$converterpreliminaryIdConfidencen
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}preliminary_id_confidence'])),
      isDraft: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_draft'])!,
      syncStatus: $ObservationsTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
      lastViewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_viewed_at']),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }

  static TypeConverter<PrivacyLevel, String> $converterprivacyLevel =
      const PrivacyLevelConverter();
  static TypeConverter<ConfidenceLevel, String>
      $converterpreliminaryIdConfidence = const ConfidenceLevelConverter();
  static TypeConverter<ConfidenceLevel?, String?>
      $converterpreliminaryIdConfidencen =
      NullAwareTypeConverter.wrap($converterpreliminaryIdConfidence);
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class Observation extends DataClass implements Insertable<Observation> {
  /// Local UUID - client-generated.
  final String id;

  /// Remote Supabase UUID (null until synced).
  final String? remoteId;

  /// Foreign key to parent foray.
  final String forayId;

  /// Foreign key to collector/creator.
  final String collectorId;

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// GPS accuracy in meters (null if unknown).
  final double? gpsAccuracy;

  /// Altitude in meters (null if unavailable).
  final double? altitude;

  /// Privacy level for this observation.
  final PrivacyLevel privacyLevel;

  /// When the observation was made in the field.
  final DateTime observedAt;

  /// When the record was created.
  final DateTime createdAt;

  /// When the record was last updated.
  final DateTime updatedAt;

  /// Physical specimen ID (for lookup by barcode/QR).
  final String? specimenId;

  /// Collection number within the foray.
  final String? collectionNumber;

  /// Substrate type (wood, soil, etc.).
  final String? substrate;

  /// Habitat/environment notes.
  final String? habitatNotes;

  /// General field notes.
  final String? fieldNotes;

  /// Spore print color if taken.
  final String? sporePrintColor;

  /// Species name suggested by collector.
  final String? preliminaryId;

  /// Confidence in preliminary ID.
  final ConfidenceLevel? preliminaryIdConfidence;

  /// Whether this is a draft (not yet submitted).
  final bool isDraft;

  /// Sync status.
  final SyncStatus syncStatus;

  /// Last time the user viewed this observation (for "updated" indicator).
  final DateTime? lastViewedAt;
  const Observation(
      {required this.id,
      this.remoteId,
      required this.forayId,
      required this.collectorId,
      required this.latitude,
      required this.longitude,
      this.gpsAccuracy,
      this.altitude,
      required this.privacyLevel,
      required this.observedAt,
      required this.createdAt,
      required this.updatedAt,
      this.specimenId,
      this.collectionNumber,
      this.substrate,
      this.habitatNotes,
      this.fieldNotes,
      this.sporePrintColor,
      this.preliminaryId,
      this.preliminaryIdConfidence,
      required this.isDraft,
      required this.syncStatus,
      this.lastViewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['foray_id'] = Variable<String>(forayId);
    map['collector_id'] = Variable<String>(collectorId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    {
      map['privacy_level'] = Variable<String>(
          $ObservationsTable.$converterprivacyLevel.toSql(privacyLevel));
    }
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || specimenId != null) {
      map['specimen_id'] = Variable<String>(specimenId);
    }
    if (!nullToAbsent || collectionNumber != null) {
      map['collection_number'] = Variable<String>(collectionNumber);
    }
    if (!nullToAbsent || substrate != null) {
      map['substrate'] = Variable<String>(substrate);
    }
    if (!nullToAbsent || habitatNotes != null) {
      map['habitat_notes'] = Variable<String>(habitatNotes);
    }
    if (!nullToAbsent || fieldNotes != null) {
      map['field_notes'] = Variable<String>(fieldNotes);
    }
    if (!nullToAbsent || sporePrintColor != null) {
      map['spore_print_color'] = Variable<String>(sporePrintColor);
    }
    if (!nullToAbsent || preliminaryId != null) {
      map['preliminary_id'] = Variable<String>(preliminaryId);
    }
    if (!nullToAbsent || preliminaryIdConfidence != null) {
      map['preliminary_id_confidence'] = Variable<String>($ObservationsTable
          .$converterpreliminaryIdConfidencen
          .toSql(preliminaryIdConfidence));
    }
    map['is_draft'] = Variable<bool>(isDraft);
    {
      map['sync_status'] = Variable<String>(
          $ObservationsTable.$convertersyncStatus.toSql(syncStatus));
    }
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      forayId: Value(forayId),
      collectorId: Value(collectorId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      privacyLevel: Value(privacyLevel),
      observedAt: Value(observedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      specimenId: specimenId == null && nullToAbsent
          ? const Value.absent()
          : Value(specimenId),
      collectionNumber: collectionNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionNumber),
      substrate: substrate == null && nullToAbsent
          ? const Value.absent()
          : Value(substrate),
      habitatNotes: habitatNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatNotes),
      fieldNotes: fieldNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldNotes),
      sporePrintColor: sporePrintColor == null && nullToAbsent
          ? const Value.absent()
          : Value(sporePrintColor),
      preliminaryId: preliminaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(preliminaryId),
      preliminaryIdConfidence: preliminaryIdConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(preliminaryIdConfidence),
      isDraft: Value(isDraft),
      syncStatus: Value(syncStatus),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
    );
  }

  factory Observation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      forayId: serializer.fromJson<String>(json['forayId']),
      collectorId: serializer.fromJson<String>(json['collectorId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      gpsAccuracy: serializer.fromJson<double?>(json['gpsAccuracy']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      privacyLevel: serializer.fromJson<PrivacyLevel>(json['privacyLevel']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      specimenId: serializer.fromJson<String?>(json['specimenId']),
      collectionNumber: serializer.fromJson<String?>(json['collectionNumber']),
      substrate: serializer.fromJson<String?>(json['substrate']),
      habitatNotes: serializer.fromJson<String?>(json['habitatNotes']),
      fieldNotes: serializer.fromJson<String?>(json['fieldNotes']),
      sporePrintColor: serializer.fromJson<String?>(json['sporePrintColor']),
      preliminaryId: serializer.fromJson<String?>(json['preliminaryId']),
      preliminaryIdConfidence: serializer
          .fromJson<ConfidenceLevel?>(json['preliminaryIdConfidence']),
      isDraft: serializer.fromJson<bool>(json['isDraft']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'forayId': serializer.toJson<String>(forayId),
      'collectorId': serializer.toJson<String>(collectorId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'gpsAccuracy': serializer.toJson<double?>(gpsAccuracy),
      'altitude': serializer.toJson<double?>(altitude),
      'privacyLevel': serializer.toJson<PrivacyLevel>(privacyLevel),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'specimenId': serializer.toJson<String?>(specimenId),
      'collectionNumber': serializer.toJson<String?>(collectionNumber),
      'substrate': serializer.toJson<String?>(substrate),
      'habitatNotes': serializer.toJson<String?>(habitatNotes),
      'fieldNotes': serializer.toJson<String?>(fieldNotes),
      'sporePrintColor': serializer.toJson<String?>(sporePrintColor),
      'preliminaryId': serializer.toJson<String?>(preliminaryId),
      'preliminaryIdConfidence':
          serializer.toJson<ConfidenceLevel?>(preliminaryIdConfidence),
      'isDraft': serializer.toJson<bool>(isDraft),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
    };
  }

  Observation copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? forayId,
          String? collectorId,
          double? latitude,
          double? longitude,
          Value<double?> gpsAccuracy = const Value.absent(),
          Value<double?> altitude = const Value.absent(),
          PrivacyLevel? privacyLevel,
          DateTime? observedAt,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> specimenId = const Value.absent(),
          Value<String?> collectionNumber = const Value.absent(),
          Value<String?> substrate = const Value.absent(),
          Value<String?> habitatNotes = const Value.absent(),
          Value<String?> fieldNotes = const Value.absent(),
          Value<String?> sporePrintColor = const Value.absent(),
          Value<String?> preliminaryId = const Value.absent(),
          Value<ConfidenceLevel?> preliminaryIdConfidence =
              const Value.absent(),
          bool? isDraft,
          SyncStatus? syncStatus,
          Value<DateTime?> lastViewedAt = const Value.absent()}) =>
      Observation(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        forayId: forayId ?? this.forayId,
        collectorId: collectorId ?? this.collectorId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
        altitude: altitude.present ? altitude.value : this.altitude,
        privacyLevel: privacyLevel ?? this.privacyLevel,
        observedAt: observedAt ?? this.observedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        specimenId: specimenId.present ? specimenId.value : this.specimenId,
        collectionNumber: collectionNumber.present
            ? collectionNumber.value
            : this.collectionNumber,
        substrate: substrate.present ? substrate.value : this.substrate,
        habitatNotes:
            habitatNotes.present ? habitatNotes.value : this.habitatNotes,
        fieldNotes: fieldNotes.present ? fieldNotes.value : this.fieldNotes,
        sporePrintColor: sporePrintColor.present
            ? sporePrintColor.value
            : this.sporePrintColor,
        preliminaryId:
            preliminaryId.present ? preliminaryId.value : this.preliminaryId,
        preliminaryIdConfidence: preliminaryIdConfidence.present
            ? preliminaryIdConfidence.value
            : this.preliminaryIdConfidence,
        isDraft: isDraft ?? this.isDraft,
        syncStatus: syncStatus ?? this.syncStatus,
        lastViewedAt:
            lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
      );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      forayId: data.forayId.present ? data.forayId.value : this.forayId,
      collectorId:
          data.collectorId.present ? data.collectorId.value : this.collectorId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gpsAccuracy:
          data.gpsAccuracy.present ? data.gpsAccuracy.value : this.gpsAccuracy,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      privacyLevel: data.privacyLevel.present
          ? data.privacyLevel.value
          : this.privacyLevel,
      observedAt:
          data.observedAt.present ? data.observedAt.value : this.observedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      specimenId:
          data.specimenId.present ? data.specimenId.value : this.specimenId,
      collectionNumber: data.collectionNumber.present
          ? data.collectionNumber.value
          : this.collectionNumber,
      substrate: data.substrate.present ? data.substrate.value : this.substrate,
      habitatNotes: data.habitatNotes.present
          ? data.habitatNotes.value
          : this.habitatNotes,
      fieldNotes:
          data.fieldNotes.present ? data.fieldNotes.value : this.fieldNotes,
      sporePrintColor: data.sporePrintColor.present
          ? data.sporePrintColor.value
          : this.sporePrintColor,
      preliminaryId: data.preliminaryId.present
          ? data.preliminaryId.value
          : this.preliminaryId,
      preliminaryIdConfidence: data.preliminaryIdConfidence.present
          ? data.preliminaryIdConfidence.value
          : this.preliminaryIdConfidence,
      isDraft: data.isDraft.present ? data.isDraft.value : this.isDraft,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('forayId: $forayId, ')
          ..write('collectorId: $collectorId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('altitude: $altitude, ')
          ..write('privacyLevel: $privacyLevel, ')
          ..write('observedAt: $observedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('specimenId: $specimenId, ')
          ..write('collectionNumber: $collectionNumber, ')
          ..write('substrate: $substrate, ')
          ..write('habitatNotes: $habitatNotes, ')
          ..write('fieldNotes: $fieldNotes, ')
          ..write('sporePrintColor: $sporePrintColor, ')
          ..write('preliminaryId: $preliminaryId, ')
          ..write('preliminaryIdConfidence: $preliminaryIdConfidence, ')
          ..write('isDraft: $isDraft, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastViewedAt: $lastViewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        remoteId,
        forayId,
        collectorId,
        latitude,
        longitude,
        gpsAccuracy,
        altitude,
        privacyLevel,
        observedAt,
        createdAt,
        updatedAt,
        specimenId,
        collectionNumber,
        substrate,
        habitatNotes,
        fieldNotes,
        sporePrintColor,
        preliminaryId,
        preliminaryIdConfidence,
        isDraft,
        syncStatus,
        lastViewedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.forayId == this.forayId &&
          other.collectorId == this.collectorId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.altitude == this.altitude &&
          other.privacyLevel == this.privacyLevel &&
          other.observedAt == this.observedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.specimenId == this.specimenId &&
          other.collectionNumber == this.collectionNumber &&
          other.substrate == this.substrate &&
          other.habitatNotes == this.habitatNotes &&
          other.fieldNotes == this.fieldNotes &&
          other.sporePrintColor == this.sporePrintColor &&
          other.preliminaryId == this.preliminaryId &&
          other.preliminaryIdConfidence == this.preliminaryIdConfidence &&
          other.isDraft == this.isDraft &&
          other.syncStatus == this.syncStatus &&
          other.lastViewedAt == this.lastViewedAt);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> forayId;
  final Value<String> collectorId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> gpsAccuracy;
  final Value<double?> altitude;
  final Value<PrivacyLevel> privacyLevel;
  final Value<DateTime> observedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> specimenId;
  final Value<String?> collectionNumber;
  final Value<String?> substrate;
  final Value<String?> habitatNotes;
  final Value<String?> fieldNotes;
  final Value<String?> sporePrintColor;
  final Value<String?> preliminaryId;
  final Value<ConfidenceLevel?> preliminaryIdConfidence;
  final Value<bool> isDraft;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime?> lastViewedAt;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.forayId = const Value.absent(),
    this.collectorId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.privacyLevel = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.specimenId = const Value.absent(),
    this.collectionNumber = const Value.absent(),
    this.substrate = const Value.absent(),
    this.habitatNotes = const Value.absent(),
    this.fieldNotes = const Value.absent(),
    this.sporePrintColor = const Value.absent(),
    this.preliminaryId = const Value.absent(),
    this.preliminaryIdConfidence = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String forayId,
    required String collectorId,
    required double latitude,
    required double longitude,
    this.gpsAccuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.privacyLevel = const Value.absent(),
    required DateTime observedAt,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.specimenId = const Value.absent(),
    this.collectionNumber = const Value.absent(),
    this.substrate = const Value.absent(),
    this.habitatNotes = const Value.absent(),
    this.fieldNotes = const Value.absent(),
    this.sporePrintColor = const Value.absent(),
    this.preliminaryId = const Value.absent(),
    this.preliminaryIdConfidence = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        forayId = Value(forayId),
        collectorId = Value(collectorId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        observedAt = Value(observedAt);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? forayId,
    Expression<String>? collectorId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? gpsAccuracy,
    Expression<double>? altitude,
    Expression<String>? privacyLevel,
    Expression<DateTime>? observedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? specimenId,
    Expression<String>? collectionNumber,
    Expression<String>? substrate,
    Expression<String>? habitatNotes,
    Expression<String>? fieldNotes,
    Expression<String>? sporePrintColor,
    Expression<String>? preliminaryId,
    Expression<String>? preliminaryIdConfidence,
    Expression<bool>? isDraft,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastViewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (forayId != null) 'foray_id': forayId,
      if (collectorId != null) 'collector_id': collectorId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (altitude != null) 'altitude': altitude,
      if (privacyLevel != null) 'privacy_level': privacyLevel,
      if (observedAt != null) 'observed_at': observedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (specimenId != null) 'specimen_id': specimenId,
      if (collectionNumber != null) 'collection_number': collectionNumber,
      if (substrate != null) 'substrate': substrate,
      if (habitatNotes != null) 'habitat_notes': habitatNotes,
      if (fieldNotes != null) 'field_notes': fieldNotes,
      if (sporePrintColor != null) 'spore_print_color': sporePrintColor,
      if (preliminaryId != null) 'preliminary_id': preliminaryId,
      if (preliminaryIdConfidence != null)
        'preliminary_id_confidence': preliminaryIdConfidence,
      if (isDraft != null) 'is_draft': isDraft,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? forayId,
      Value<String>? collectorId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double?>? gpsAccuracy,
      Value<double?>? altitude,
      Value<PrivacyLevel>? privacyLevel,
      Value<DateTime>? observedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? specimenId,
      Value<String?>? collectionNumber,
      Value<String?>? substrate,
      Value<String?>? habitatNotes,
      Value<String?>? fieldNotes,
      Value<String?>? sporePrintColor,
      Value<String?>? preliminaryId,
      Value<ConfidenceLevel?>? preliminaryIdConfidence,
      Value<bool>? isDraft,
      Value<SyncStatus>? syncStatus,
      Value<DateTime?>? lastViewedAt,
      Value<int>? rowid}) {
    return ObservationsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      forayId: forayId ?? this.forayId,
      collectorId: collectorId ?? this.collectorId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      altitude: altitude ?? this.altitude,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      observedAt: observedAt ?? this.observedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specimenId: specimenId ?? this.specimenId,
      collectionNumber: collectionNumber ?? this.collectionNumber,
      substrate: substrate ?? this.substrate,
      habitatNotes: habitatNotes ?? this.habitatNotes,
      fieldNotes: fieldNotes ?? this.fieldNotes,
      sporePrintColor: sporePrintColor ?? this.sporePrintColor,
      preliminaryId: preliminaryId ?? this.preliminaryId,
      preliminaryIdConfidence:
          preliminaryIdConfidence ?? this.preliminaryIdConfidence,
      isDraft: isDraft ?? this.isDraft,
      syncStatus: syncStatus ?? this.syncStatus,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (forayId.present) {
      map['foray_id'] = Variable<String>(forayId.value);
    }
    if (collectorId.present) {
      map['collector_id'] = Variable<String>(collectorId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (privacyLevel.present) {
      map['privacy_level'] = Variable<String>(
          $ObservationsTable.$converterprivacyLevel.toSql(privacyLevel.value));
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (specimenId.present) {
      map['specimen_id'] = Variable<String>(specimenId.value);
    }
    if (collectionNumber.present) {
      map['collection_number'] = Variable<String>(collectionNumber.value);
    }
    if (substrate.present) {
      map['substrate'] = Variable<String>(substrate.value);
    }
    if (habitatNotes.present) {
      map['habitat_notes'] = Variable<String>(habitatNotes.value);
    }
    if (fieldNotes.present) {
      map['field_notes'] = Variable<String>(fieldNotes.value);
    }
    if (sporePrintColor.present) {
      map['spore_print_color'] = Variable<String>(sporePrintColor.value);
    }
    if (preliminaryId.present) {
      map['preliminary_id'] = Variable<String>(preliminaryId.value);
    }
    if (preliminaryIdConfidence.present) {
      map['preliminary_id_confidence'] = Variable<String>($ObservationsTable
          .$converterpreliminaryIdConfidencen
          .toSql(preliminaryIdConfidence.value));
    }
    if (isDraft.present) {
      map['is_draft'] = Variable<bool>(isDraft.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $ObservationsTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('forayId: $forayId, ')
          ..write('collectorId: $collectorId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('altitude: $altitude, ')
          ..write('privacyLevel: $privacyLevel, ')
          ..write('observedAt: $observedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('specimenId: $specimenId, ')
          ..write('collectionNumber: $collectionNumber, ')
          ..write('substrate: $substrate, ')
          ..write('habitatNotes: $habitatNotes, ')
          ..write('fieldNotes: $fieldNotes, ')
          ..write('sporePrintColor: $sporePrintColor, ')
          ..write('preliminaryId: $preliminaryId, ')
          ..write('preliminaryIdConfidence: $preliminaryIdConfidence, ')
          ..write('isDraft: $isDraft, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _observationIdMeta =
      const VerificationMeta('observationId');
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
      'observation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES observations (id)'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<UploadStatus, String>
      uploadStatus = GeneratedColumn<String>(
              'upload_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<UploadStatus>($PhotosTable.$converteruploadStatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        observationId,
        localPath,
        remoteUrl,
        sortOrder,
        caption,
        uploadStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<Photo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('observation_id')) {
      context.handle(
          _observationIdMeta,
          observationId.isAcceptableOrUnknown(
              data['observation_id']!, _observationIdMeta));
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      observationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observation_id'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      uploadStatus: $PhotosTable.$converteruploadStatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<UploadStatus, String> $converteruploadStatus =
      const UploadStatusConverter();
}

class Photo extends DataClass implements Insertable<Photo> {
  /// Local UUID - client-generated.
  final String id;

  /// Remote UUID (null until uploaded).
  final String? remoteId;

  /// Foreign key to parent observation.
  final String observationId;

  /// Local file system path to the image.
  final String localPath;

  /// Remote storage URL (populated after upload).
  final String? remoteUrl;

  /// Display order (0 = primary/first photo).
  final int sortOrder;

  /// Optional caption for the photo.
  final String? caption;

  /// Upload status.
  final UploadStatus uploadStatus;

  /// Timestamp when created.
  final DateTime createdAt;
  const Photo(
      {required this.id,
      this.remoteId,
      required this.observationId,
      required this.localPath,
      this.remoteUrl,
      required this.sortOrder,
      this.caption,
      required this.uploadStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['observation_id'] = Variable<String>(observationId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    {
      map['upload_status'] = Variable<String>(
          $PhotosTable.$converteruploadStatus.toSql(uploadStatus));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      observationId: Value(observationId),
      localPath: Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      sortOrder: Value(sortOrder),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      uploadStatus: Value(uploadStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      observationId: serializer.fromJson<String>(json['observationId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      caption: serializer.fromJson<String?>(json['caption']),
      uploadStatus: serializer.fromJson<UploadStatus>(json['uploadStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'observationId': serializer.toJson<String>(observationId),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'caption': serializer.toJson<String?>(caption),
      'uploadStatus': serializer.toJson<UploadStatus>(uploadStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Photo copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? observationId,
          String? localPath,
          Value<String?> remoteUrl = const Value.absent(),
          int? sortOrder,
          Value<String?> caption = const Value.absent(),
          UploadStatus? uploadStatus,
          DateTime? createdAt}) =>
      Photo(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        observationId: observationId ?? this.observationId,
        localPath: localPath ?? this.localPath,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        sortOrder: sortOrder ?? this.sortOrder,
        caption: caption.present ? caption.value : this.caption,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      caption: data.caption.present ? data.caption.value : this.caption,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('caption: $caption, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, observationId, localPath,
      remoteUrl, sortOrder, caption, uploadStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.observationId == this.observationId &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.sortOrder == this.sortOrder &&
          other.caption == this.caption &&
          other.uploadStatus == this.uploadStatus &&
          other.createdAt == this.createdAt);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> observationId;
  final Value<String> localPath;
  final Value<String?> remoteUrl;
  final Value<int> sortOrder;
  final Value<String?> caption;
  final Value<UploadStatus> uploadStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.observationId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String observationId,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        observationId = Value(observationId),
        localPath = Value(localPath);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? observationId,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<int>? sortOrder,
    Expression<String>? caption,
    Expression<String>? uploadStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (observationId != null) 'observation_id': observationId,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (caption != null) 'caption': caption,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? observationId,
      Value<String>? localPath,
      Value<String?>? remoteUrl,
      Value<int>? sortOrder,
      Value<String?>? caption,
      Value<UploadStatus>? uploadStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PhotosCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      observationId: observationId ?? this.observationId,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      caption: caption ?? this.caption,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(
          $PhotosTable.$converteruploadStatus.toSql(uploadStatus.value));
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
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('caption: $caption, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdentificationsTable extends Identifications
    with TableInfo<$IdentificationsTable, Identification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _observationIdMeta =
      const VerificationMeta('observationId');
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
      'observation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES observations (id)'));
  static const VerificationMeta _identifierIdMeta =
      const VerificationMeta('identifierId');
  @override
  late final GeneratedColumn<String> identifierId = GeneratedColumn<String>(
      'identifier_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _speciesNameMeta =
      const VerificationMeta('speciesName');
  @override
  late final GeneratedColumn<String> speciesName = GeneratedColumn<String>(
      'species_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commonNameMeta =
      const VerificationMeta('commonName');
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
      'common_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ConfidenceLevel, String>
      confidence = GeneratedColumn<String>('confidence', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('likely'))
          .withConverter<ConfidenceLevel>(
              $IdentificationsTable.$converterconfidence);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voteCountMeta =
      const VerificationMeta('voteCount');
  @override
  late final GeneratedColumn<int> voteCount = GeneratedColumn<int>(
      'vote_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('local'))
          .withConverter<SyncStatus>(
              $IdentificationsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        observationId,
        identifierId,
        speciesName,
        commonName,
        confidence,
        notes,
        voteCount,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identifications';
  @override
  VerificationContext validateIntegrity(Insertable<Identification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('observation_id')) {
      context.handle(
          _observationIdMeta,
          observationId.isAcceptableOrUnknown(
              data['observation_id']!, _observationIdMeta));
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('identifier_id')) {
      context.handle(
          _identifierIdMeta,
          identifierId.isAcceptableOrUnknown(
              data['identifier_id']!, _identifierIdMeta));
    } else if (isInserting) {
      context.missing(_identifierIdMeta);
    }
    if (data.containsKey('species_name')) {
      context.handle(
          _speciesNameMeta,
          speciesName.isAcceptableOrUnknown(
              data['species_name']!, _speciesNameMeta));
    } else if (isInserting) {
      context.missing(_speciesNameMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
          _commonNameMeta,
          commonName.isAcceptableOrUnknown(
              data['common_name']!, _commonNameMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('vote_count')) {
      context.handle(_voteCountMeta,
          voteCount.isAcceptableOrUnknown(data['vote_count']!, _voteCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Identification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Identification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      observationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observation_id'])!,
      identifierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}identifier_id'])!,
      speciesName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species_name'])!,
      commonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}common_name']),
      confidence: $IdentificationsTable.$converterconfidence.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}confidence'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      voteCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vote_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $IdentificationsTable.$convertersyncStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $IdentificationsTable createAlias(String alias) {
    return $IdentificationsTable(attachedDatabase, alias);
  }

  static TypeConverter<ConfidenceLevel, String> $converterconfidence =
      const ConfidenceLevelConverter();
  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class Identification extends DataClass implements Insertable<Identification> {
  /// Local UUID - client-generated.
  final String id;

  /// Remote UUID (null until synced).
  final String? remoteId;

  /// Foreign key to the observation being identified.
  final String observationId;

  /// Foreign key to the user who made this identification.
  final String identifierId;

  /// Scientific species name.
  final String speciesName;

  /// Common name (optional).
  final String? commonName;

  /// Confidence level in this identification.
  final ConfidenceLevel confidence;

  /// Optional notes explaining the reasoning.
  final String? notes;

  /// Denormalized vote count for efficient sorting.
  final int voteCount;

  /// Timestamp when created.
  final DateTime createdAt;

  /// Sync status.
  final SyncStatus syncStatus;
  const Identification(
      {required this.id,
      this.remoteId,
      required this.observationId,
      required this.identifierId,
      required this.speciesName,
      this.commonName,
      required this.confidence,
      this.notes,
      required this.voteCount,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['observation_id'] = Variable<String>(observationId);
    map['identifier_id'] = Variable<String>(identifierId);
    map['species_name'] = Variable<String>(speciesName);
    if (!nullToAbsent || commonName != null) {
      map['common_name'] = Variable<String>(commonName);
    }
    {
      map['confidence'] = Variable<String>(
          $IdentificationsTable.$converterconfidence.toSql(confidence));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['vote_count'] = Variable<int>(voteCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $IdentificationsTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  IdentificationsCompanion toCompanion(bool nullToAbsent) {
    return IdentificationsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      observationId: Value(observationId),
      identifierId: Value(identifierId),
      speciesName: Value(speciesName),
      commonName: commonName == null && nullToAbsent
          ? const Value.absent()
          : Value(commonName),
      confidence: Value(confidence),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      voteCount: Value(voteCount),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Identification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Identification(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      observationId: serializer.fromJson<String>(json['observationId']),
      identifierId: serializer.fromJson<String>(json['identifierId']),
      speciesName: serializer.fromJson<String>(json['speciesName']),
      commonName: serializer.fromJson<String?>(json['commonName']),
      confidence: serializer.fromJson<ConfidenceLevel>(json['confidence']),
      notes: serializer.fromJson<String?>(json['notes']),
      voteCount: serializer.fromJson<int>(json['voteCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'observationId': serializer.toJson<String>(observationId),
      'identifierId': serializer.toJson<String>(identifierId),
      'speciesName': serializer.toJson<String>(speciesName),
      'commonName': serializer.toJson<String?>(commonName),
      'confidence': serializer.toJson<ConfidenceLevel>(confidence),
      'notes': serializer.toJson<String?>(notes),
      'voteCount': serializer.toJson<int>(voteCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  Identification copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? observationId,
          String? identifierId,
          String? speciesName,
          Value<String?> commonName = const Value.absent(),
          ConfidenceLevel? confidence,
          Value<String?> notes = const Value.absent(),
          int? voteCount,
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      Identification(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        observationId: observationId ?? this.observationId,
        identifierId: identifierId ?? this.identifierId,
        speciesName: speciesName ?? this.speciesName,
        commonName: commonName.present ? commonName.value : this.commonName,
        confidence: confidence ?? this.confidence,
        notes: notes.present ? notes.value : this.notes,
        voteCount: voteCount ?? this.voteCount,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Identification copyWithCompanion(IdentificationsCompanion data) {
    return Identification(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      identifierId: data.identifierId.present
          ? data.identifierId.value
          : this.identifierId,
      speciesName:
          data.speciesName.present ? data.speciesName.value : this.speciesName,
      commonName:
          data.commonName.present ? data.commonName.value : this.commonName,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      notes: data.notes.present ? data.notes.value : this.notes,
      voteCount: data.voteCount.present ? data.voteCount.value : this.voteCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Identification(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('identifierId: $identifierId, ')
          ..write('speciesName: $speciesName, ')
          ..write('commonName: $commonName, ')
          ..write('confidence: $confidence, ')
          ..write('notes: $notes, ')
          ..write('voteCount: $voteCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      observationId,
      identifierId,
      speciesName,
      commonName,
      confidence,
      notes,
      voteCount,
      createdAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identification &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.observationId == this.observationId &&
          other.identifierId == this.identifierId &&
          other.speciesName == this.speciesName &&
          other.commonName == this.commonName &&
          other.confidence == this.confidence &&
          other.notes == this.notes &&
          other.voteCount == this.voteCount &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class IdentificationsCompanion extends UpdateCompanion<Identification> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> observationId;
  final Value<String> identifierId;
  final Value<String> speciesName;
  final Value<String?> commonName;
  final Value<ConfidenceLevel> confidence;
  final Value<String?> notes;
  final Value<int> voteCount;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const IdentificationsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.observationId = const Value.absent(),
    this.identifierId = const Value.absent(),
    this.speciesName = const Value.absent(),
    this.commonName = const Value.absent(),
    this.confidence = const Value.absent(),
    this.notes = const Value.absent(),
    this.voteCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentificationsCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String observationId,
    required String identifierId,
    required String speciesName,
    this.commonName = const Value.absent(),
    this.confidence = const Value.absent(),
    this.notes = const Value.absent(),
    this.voteCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        observationId = Value(observationId),
        identifierId = Value(identifierId),
        speciesName = Value(speciesName);
  static Insertable<Identification> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? observationId,
    Expression<String>? identifierId,
    Expression<String>? speciesName,
    Expression<String>? commonName,
    Expression<String>? confidence,
    Expression<String>? notes,
    Expression<int>? voteCount,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (observationId != null) 'observation_id': observationId,
      if (identifierId != null) 'identifier_id': identifierId,
      if (speciesName != null) 'species_name': speciesName,
      if (commonName != null) 'common_name': commonName,
      if (confidence != null) 'confidence': confidence,
      if (notes != null) 'notes': notes,
      if (voteCount != null) 'vote_count': voteCount,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentificationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? observationId,
      Value<String>? identifierId,
      Value<String>? speciesName,
      Value<String?>? commonName,
      Value<ConfidenceLevel>? confidence,
      Value<String?>? notes,
      Value<int>? voteCount,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return IdentificationsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      observationId: observationId ?? this.observationId,
      identifierId: identifierId ?? this.identifierId,
      speciesName: speciesName ?? this.speciesName,
      commonName: commonName ?? this.commonName,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      voteCount: voteCount ?? this.voteCount,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (identifierId.present) {
      map['identifier_id'] = Variable<String>(identifierId.value);
    }
    if (speciesName.present) {
      map['species_name'] = Variable<String>(speciesName.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
          $IdentificationsTable.$converterconfidence.toSql(confidence.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (voteCount.present) {
      map['vote_count'] = Variable<int>(voteCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $IdentificationsTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentificationsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('identifierId: $identifierId, ')
          ..write('speciesName: $speciesName, ')
          ..write('commonName: $commonName, ')
          ..write('confidence: $confidence, ')
          ..write('notes: $notes, ')
          ..write('voteCount: $voteCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdentificationVotesTable extends IdentificationVotes
    with TableInfo<$IdentificationVotesTable, IdentificationVote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentificationVotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identificationIdMeta =
      const VerificationMeta('identificationId');
  @override
  late final GeneratedColumn<String> identificationId = GeneratedColumn<String>(
      'identification_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES identifications (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _votedAtMeta =
      const VerificationMeta('votedAt');
  @override
  late final GeneratedColumn<DateTime> votedAt = GeneratedColumn<DateTime>(
      'voted_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [identificationId, userId, votedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identification_votes';
  @override
  VerificationContext validateIntegrity(Insertable<IdentificationVote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identification_id')) {
      context.handle(
          _identificationIdMeta,
          identificationId.isAcceptableOrUnknown(
              data['identification_id']!, _identificationIdMeta));
    } else if (isInserting) {
      context.missing(_identificationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('voted_at')) {
      context.handle(_votedAtMeta,
          votedAt.isAcceptableOrUnknown(data['voted_at']!, _votedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identificationId, userId};
  @override
  IdentificationVote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentificationVote(
      identificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}identification_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      votedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}voted_at'])!,
    );
  }

  @override
  $IdentificationVotesTable createAlias(String alias) {
    return $IdentificationVotesTable(attachedDatabase, alias);
  }
}

class IdentificationVote extends DataClass
    implements Insertable<IdentificationVote> {
  /// Foreign key to the identification being voted on.
  final String identificationId;

  /// Foreign key to the voting user.
  final String userId;

  /// Timestamp when the vote was cast.
  final DateTime votedAt;
  const IdentificationVote(
      {required this.identificationId,
      required this.userId,
      required this.votedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identification_id'] = Variable<String>(identificationId);
    map['user_id'] = Variable<String>(userId);
    map['voted_at'] = Variable<DateTime>(votedAt);
    return map;
  }

  IdentificationVotesCompanion toCompanion(bool nullToAbsent) {
    return IdentificationVotesCompanion(
      identificationId: Value(identificationId),
      userId: Value(userId),
      votedAt: Value(votedAt),
    );
  }

  factory IdentificationVote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentificationVote(
      identificationId: serializer.fromJson<String>(json['identificationId']),
      userId: serializer.fromJson<String>(json['userId']),
      votedAt: serializer.fromJson<DateTime>(json['votedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identificationId': serializer.toJson<String>(identificationId),
      'userId': serializer.toJson<String>(userId),
      'votedAt': serializer.toJson<DateTime>(votedAt),
    };
  }

  IdentificationVote copyWith(
          {String? identificationId, String? userId, DateTime? votedAt}) =>
      IdentificationVote(
        identificationId: identificationId ?? this.identificationId,
        userId: userId ?? this.userId,
        votedAt: votedAt ?? this.votedAt,
      );
  IdentificationVote copyWithCompanion(IdentificationVotesCompanion data) {
    return IdentificationVote(
      identificationId: data.identificationId.present
          ? data.identificationId.value
          : this.identificationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      votedAt: data.votedAt.present ? data.votedAt.value : this.votedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentificationVote(')
          ..write('identificationId: $identificationId, ')
          ..write('userId: $userId, ')
          ..write('votedAt: $votedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identificationId, userId, votedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentificationVote &&
          other.identificationId == this.identificationId &&
          other.userId == this.userId &&
          other.votedAt == this.votedAt);
}

class IdentificationVotesCompanion extends UpdateCompanion<IdentificationVote> {
  final Value<String> identificationId;
  final Value<String> userId;
  final Value<DateTime> votedAt;
  final Value<int> rowid;
  const IdentificationVotesCompanion({
    this.identificationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.votedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentificationVotesCompanion.insert({
    required String identificationId,
    required String userId,
    this.votedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : identificationId = Value(identificationId),
        userId = Value(userId);
  static Insertable<IdentificationVote> custom({
    Expression<String>? identificationId,
    Expression<String>? userId,
    Expression<DateTime>? votedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identificationId != null) 'identification_id': identificationId,
      if (userId != null) 'user_id': userId,
      if (votedAt != null) 'voted_at': votedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentificationVotesCompanion copyWith(
      {Value<String>? identificationId,
      Value<String>? userId,
      Value<DateTime>? votedAt,
      Value<int>? rowid}) {
    return IdentificationVotesCompanion(
      identificationId: identificationId ?? this.identificationId,
      userId: userId ?? this.userId,
      votedAt: votedAt ?? this.votedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identificationId.present) {
      map['identification_id'] = Variable<String>(identificationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (votedAt.present) {
      map['voted_at'] = Variable<DateTime>(votedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentificationVotesCompanion(')
          ..write('identificationId: $identificationId, ')
          ..write('userId: $userId, ')
          ..write('votedAt: $votedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTable extends Comments with TableInfo<$CommentsTable, Comment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _observationIdMeta =
      const VerificationMeta('observationId');
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
      'observation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES observations (id)'));
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
      'author_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1, maxTextLength: 2000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>('sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('local'))
          .withConverter<SyncStatus>($CommentsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, remoteId, observationId, authorId, content, createdAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(Insertable<Comment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('observation_id')) {
      context.handle(
          _observationIdMeta,
          observationId.isAcceptableOrUnknown(
              data['observation_id']!, _observationIdMeta));
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(_authorIdMeta,
          authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta));
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Comment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Comment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      observationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observation_id'])!,
      authorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: $CommentsTable.$convertersyncStatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!),
    );
  }

  @override
  $CommentsTable createAlias(String alias) {
    return $CommentsTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncStatus, String> $convertersyncStatus =
      const SyncStatusConverter();
}

class Comment extends DataClass implements Insertable<Comment> {
  /// Local UUID - client-generated.
  final String id;

  /// Remote UUID (null until synced).
  final String? remoteId;

  /// Foreign key to the observation being discussed.
  final String observationId;

  /// Foreign key to the comment author.
  final String authorId;

  /// Comment content (1-2000 characters).
  final String content;

  /// Timestamp when created.
  final DateTime createdAt;

  /// Sync status.
  final SyncStatus syncStatus;
  const Comment(
      {required this.id,
      this.remoteId,
      required this.observationId,
      required this.authorId,
      required this.content,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['observation_id'] = Variable<String>(observationId);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['sync_status'] = Variable<String>(
          $CommentsTable.$convertersyncStatus.toSql(syncStatus));
    }
    return map;
  }

  CommentsCompanion toCompanion(bool nullToAbsent) {
    return CommentsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      observationId: Value(observationId),
      authorId: Value(authorId),
      content: Value(content),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Comment(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      observationId: serializer.fromJson<String>(json['observationId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<SyncStatus>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'observationId': serializer.toJson<String>(observationId),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<SyncStatus>(syncStatus),
    };
  }

  Comment copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? observationId,
          String? authorId,
          String? content,
          DateTime? createdAt,
          SyncStatus? syncStatus}) =>
      Comment(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        observationId: observationId ?? this.observationId,
        authorId: authorId ?? this.authorId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Comment copyWithCompanion(CommentsCompanion data) {
    return Comment(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Comment(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, remoteId, observationId, authorId, content, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comment &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.observationId == this.observationId &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class CommentsCompanion extends UpdateCompanion<Comment> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> observationId;
  final Value<String> authorId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<SyncStatus> syncStatus;
  final Value<int> rowid;
  const CommentsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.observationId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String observationId,
    required String authorId,
    required String content,
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        observationId = Value(observationId),
        authorId = Value(authorId),
        content = Value(content);
  static Insertable<Comment> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? observationId,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (observationId != null) 'observation_id': observationId,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? observationId,
      Value<String>? authorId,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<SyncStatus>? syncStatus,
      Value<int>? rowid}) {
    return CommentsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      observationId: observationId ?? this.observationId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
          $CommentsTable.$convertersyncStatus.toSql(syncStatus.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('observationId: $observationId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperation, String> operation =
      GeneratedColumn<String>('operation', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SyncOperation>($SyncQueueTable.$converteroperation);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<SyncQueueStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<SyncQueueStatus>($SyncQueueTable.$converterstatus);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAttemptMeta =
      const VerificationMeta('lastAttempt');
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
      'last_attempt', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        status,
        retryCount,
        lastAttempt,
        lastError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
          _lastAttemptMeta,
          lastAttempt.isAcceptableOrUnknown(
              data['last_attempt']!, _lastAttemptMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: $SyncQueueTable.$converteroperation.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      status: $SyncQueueTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastAttempt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_attempt']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static TypeConverter<SyncOperation, String> $converteroperation =
      const SyncOperationConverter();
  static TypeConverter<SyncQueueStatus, String> $converterstatus =
      const SyncQueueStatusConverter();
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  /// Auto-increment ID for FIFO ordering.
  final int id;

  /// Type of entity being synced (foray, observation, identification, etc.).
  final String entityType;

  /// Local ID of the entity.
  final String entityId;

  /// Type of operation (create, update, delete).
  final SyncOperation operation;

  /// Optional JSON payload with additional data.
  final String? payload;

  /// Current processing status.
  final SyncQueueStatus status;

  /// Number of retry attempts.
  final int retryCount;

  /// Timestamp of last sync attempt.
  final DateTime? lastAttempt;

  /// Error message from last failed attempt.
  final String? lastError;

  /// Timestamp when queued.
  final DateTime createdAt;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      this.payload,
      required this.status,
      required this.retryCount,
      this.lastAttempt,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation'] = Variable<String>(
          $SyncQueueTable.$converteroperation.toSql(operation));
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    {
      map['status'] =
          Variable<String>($SyncQueueTable.$converterstatus.toSql(status));
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<SyncOperation>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      status: serializer.fromJson<SyncQueueStatus>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<SyncOperation>(operation),
      'payload': serializer.toJson<String?>(payload),
      'status': serializer.toJson<SyncQueueStatus>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          SyncOperation? operation,
          Value<String?> payload = const Value.absent(),
          SyncQueueStatus? status,
          int? retryCount,
          Value<DateTime?> lastAttempt = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload.present ? payload.value : this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastAttempt:
          data.lastAttempt.present ? data.lastAttempt.value : this.lastAttempt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, payload,
      status, retryCount, lastAttempt, lastError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastAttempt == this.lastAttempt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<SyncOperation> operation;
  final Value<String?> payload;
  final Value<SyncQueueStatus> status;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttempt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttempt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<SyncOperation>? operation,
      Value<String?>? payload,
      Value<SyncQueueStatus>? status,
      Value<int>? retryCount,
      Value<DateTime?>? lastAttempt,
      Value<String?>? lastError,
      Value<DateTime>? createdAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
          $SyncQueueTable.$converteroperation.toSql(operation.value));
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $SyncQueueTable.$converterstatus.toSql(status.value));
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ForaysTable forays = $ForaysTable(this);
  late final $ForayParticipantsTable forayParticipants =
      $ForayParticipantsTable(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $IdentificationsTable identifications =
      $IdentificationsTable(this);
  late final $IdentificationVotesTable identificationVotes =
      $IdentificationVotesTable(this);
  late final $CommentsTable comments = $CommentsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final ForaysDao foraysDao = ForaysDao(this as AppDatabase);
  late final ObservationsDao observationsDao =
      ObservationsDao(this as AppDatabase);
  late final CollaborationDao collaborationDao =
      CollaborationDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        forays,
        forayParticipants,
        observations,
        photos,
        identifications,
        identificationVotes,
        comments,
        syncQueue
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String displayName,
  Value<String?> email,
  Value<String?> avatarUrl,
  Value<bool> isAnonymous,
  Value<String?> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isCurrent,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> displayName,
  Value<String?> email,
  Value<String?> avatarUrl,
  Value<bool> isAnonymous,
  Value<String?> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isCurrent,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ForaysTable, List<Foray>> _foraysRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.forays,
          aliasName: $_aliasNameGenerator(db.users.id, db.forays.creatorId));

  $$ForaysTableProcessedTableManager get foraysRefs {
    final manager = $$ForaysTableTableManager($_db, $_db.forays)
        .filter((f) => f.creatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_foraysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ForayParticipantsTable, List<ForayParticipant>>
      _forayParticipantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.forayParticipants,
              aliasName: $_aliasNameGenerator(
                  db.users.id, db.forayParticipants.userId));

  $$ForayParticipantsTableProcessedTableManager get forayParticipantsRefs {
    final manager =
        $$ForayParticipantsTableTableManager($_db, $_db.forayParticipants)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_forayParticipantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
      _observationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.observations,
          aliasName:
              $_aliasNameGenerator(db.users.id, db.observations.collectorId));

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter((f) => f.collectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$IdentificationsTable, List<Identification>>
      _identificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.identifications,
              aliasName: $_aliasNameGenerator(
                  db.users.id, db.identifications.identifierId));

  $$IdentificationsTableProcessedTableManager get identificationsRefs {
    final manager =
        $$IdentificationsTableTableManager($_db, $_db.identifications).filter(
            (f) => f.identifierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_identificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$IdentificationVotesTable,
      List<IdentificationVote>> _identificationVotesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.identificationVotes,
          aliasName:
              $_aliasNameGenerator(db.users.id, db.identificationVotes.userId));

  $$IdentificationVotesTableProcessedTableManager get identificationVotesRefs {
    final manager =
        $$IdentificationVotesTableTableManager($_db, $_db.identificationVotes)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_identificationVotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CommentsTable, List<Comment>> _commentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.comments,
          aliasName: $_aliasNameGenerator(db.users.id, db.comments.authorId));

  $$CommentsTableProcessedTableManager get commentsRefs {
    final manager = $$CommentsTableTableManager($_db, $_db.comments)
        .filter((f) => f.authorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCurrent => $composableBuilder(
      column: $table.isCurrent, builder: (column) => ColumnFilters(column));

  Expression<bool> foraysRefs(
      Expression<bool> Function($$ForaysTableFilterComposer f) f) {
    final $$ForaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.creatorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableFilterComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> forayParticipantsRefs(
      Expression<bool> Function($$ForayParticipantsTableFilterComposer f) f) {
    final $$ForayParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.forayParticipants,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForayParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.forayParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> observationsRefs(
      Expression<bool> Function($$ObservationsTableFilterComposer f) f) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.collectorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableFilterComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> identificationsRefs(
      Expression<bool> Function($$IdentificationsTableFilterComposer f) f) {
    final $$IdentificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.identifierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableFilterComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> identificationVotesRefs(
      Expression<bool> Function($$IdentificationVotesTableFilterComposer f) f) {
    final $$IdentificationVotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identificationVotes,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationVotesTableFilterComposer(
              $db: $db,
              $table: $db.identificationVotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> commentsRefs(
      Expression<bool> Function($$CommentsTableFilterComposer f) f) {
    final $$CommentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.authorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableFilterComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
      column: $table.isCurrent, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  Expression<T> foraysRefs<T extends Object>(
      Expression<T> Function($$ForaysTableAnnotationComposer a) f) {
    final $$ForaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.creatorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableAnnotationComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> forayParticipantsRefs<T extends Object>(
      Expression<T> Function($$ForayParticipantsTableAnnotationComposer a) f) {
    final $$ForayParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.forayParticipants,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ForayParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.forayParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> observationsRefs<T extends Object>(
      Expression<T> Function($$ObservationsTableAnnotationComposer a) f) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.collectorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableAnnotationComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> identificationsRefs<T extends Object>(
      Expression<T> Function($$IdentificationsTableAnnotationComposer a) f) {
    final $$IdentificationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.identifierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableAnnotationComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> identificationVotesRefs<T extends Object>(
      Expression<T> Function($$IdentificationVotesTableAnnotationComposer a)
          f) {
    final $$IdentificationVotesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.identificationVotes,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$IdentificationVotesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.identificationVotes,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> commentsRefs<T extends Object>(
      Expression<T> Function($$CommentsTableAnnotationComposer a) f) {
    final $$CommentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.authorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableAnnotationComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool foraysRefs,
        bool forayParticipantsRefs,
        bool observationsRefs,
        bool identificationsRefs,
        bool identificationVotesRefs,
        bool commentsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isAnonymous = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isCurrent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            remoteId: remoteId,
            displayName: displayName,
            email: email,
            avatarUrl: avatarUrl,
            isAnonymous: isAnonymous,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isCurrent: isCurrent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String displayName,
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isAnonymous = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isCurrent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            remoteId: remoteId,
            displayName: displayName,
            email: email,
            avatarUrl: avatarUrl,
            isAnonymous: isAnonymous,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isCurrent: isCurrent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {foraysRefs = false,
              forayParticipantsRefs = false,
              observationsRefs = false,
              identificationsRefs = false,
              identificationVotesRefs = false,
              commentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (foraysRefs) db.forays,
                if (forayParticipantsRefs) db.forayParticipants,
                if (observationsRefs) db.observations,
                if (identificationsRefs) db.identifications,
                if (identificationVotesRefs) db.identificationVotes,
                if (commentsRefs) db.comments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (foraysRefs)
                    await $_getPrefetchedData<User, $UsersTable, Foray>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._foraysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).foraysRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.creatorId == item.id),
                        typedResults: items),
                  if (forayParticipantsRefs)
                    await $_getPrefetchedData<User, $UsersTable,
                            ForayParticipant>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._forayParticipantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .forayParticipantsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (observationsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Observation>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._observationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .observationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectorId == item.id),
                        typedResults: items),
                  if (identificationsRefs)
                    await $_getPrefetchedData<User, $UsersTable,
                            Identification>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._identificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .identificationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.identifierId == item.id),
                        typedResults: items),
                  if (identificationVotesRefs)
                    await $_getPrefetchedData<User, $UsersTable,
                            IdentificationVote>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._identificationVotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .identificationVotesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (commentsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Comment>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._commentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).commentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.authorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool foraysRefs,
        bool forayParticipantsRefs,
        bool observationsRefs,
        bool identificationsRefs,
        bool identificationVotesRefs,
        bool commentsRefs})>;
typedef $$ForaysTableCreateCompanionBuilder = ForaysCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String creatorId,
  required String name,
  Value<String?> description,
  required DateTime date,
  Value<String?> locationName,
  Value<PrivacyLevel> defaultPrivacy,
  Value<String?> joinCode,
  Value<ForayStatus> status,
  Value<bool> isSolo,
  Value<bool> observationsLocked,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$ForaysTableUpdateCompanionBuilder = ForaysCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> creatorId,
  Value<String> name,
  Value<String?> description,
  Value<DateTime> date,
  Value<String?> locationName,
  Value<PrivacyLevel> defaultPrivacy,
  Value<String?> joinCode,
  Value<ForayStatus> status,
  Value<bool> isSolo,
  Value<bool> observationsLocked,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$ForaysTableReferences
    extends BaseReferences<_$AppDatabase, $ForaysTable, Foray> {
  $$ForaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _creatorIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.forays.creatorId, db.users.id));

  $$UsersTableProcessedTableManager get creatorId {
    final $_column = $_itemColumn<String>('creator_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ForayParticipantsTable, List<ForayParticipant>>
      _forayParticipantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.forayParticipants,
              aliasName: $_aliasNameGenerator(
                  db.forays.id, db.forayParticipants.forayId));

  $$ForayParticipantsTableProcessedTableManager get forayParticipantsRefs {
    final manager =
        $$ForayParticipantsTableTableManager($_db, $_db.forayParticipants)
            .filter((f) => f.forayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_forayParticipantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
      _observationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.observations,
              aliasName:
                  $_aliasNameGenerator(db.forays.id, db.observations.forayId));

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter((f) => f.forayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ForaysTableFilterComposer
    extends Composer<_$AppDatabase, $ForaysTable> {
  $$ForaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PrivacyLevel, PrivacyLevel, String>
      get defaultPrivacy => $composableBuilder(
          column: $table.defaultPrivacy,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get joinCode => $composableBuilder(
      column: $table.joinCode, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ForayStatus, ForayStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isSolo => $composableBuilder(
      column: $table.isSolo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get observationsLocked => $composableBuilder(
      column: $table.observationsLocked,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$UsersTableFilterComposer get creatorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> forayParticipantsRefs(
      Expression<bool> Function($$ForayParticipantsTableFilterComposer f) f) {
    final $$ForayParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.forayParticipants,
        getReferencedColumn: (t) => t.forayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForayParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.forayParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> observationsRefs(
      Expression<bool> Function($$ObservationsTableFilterComposer f) f) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.forayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableFilterComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ForaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ForaysTable> {
  $$ForaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationName => $composableBuilder(
      column: $table.locationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultPrivacy => $composableBuilder(
      column: $table.defaultPrivacy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joinCode => $composableBuilder(
      column: $table.joinCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSolo => $composableBuilder(
      column: $table.isSolo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get observationsLocked => $composableBuilder(
      column: $table.observationsLocked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get creatorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ForaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ForaysTable> {
  $$ForaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrivacyLevel, String> get defaultPrivacy =>
      $composableBuilder(
          column: $table.defaultPrivacy, builder: (column) => column);

  GeneratedColumn<String> get joinCode =>
      $composableBuilder(column: $table.joinCode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ForayStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isSolo =>
      $composableBuilder(column: $table.isSolo, builder: (column) => column);

  GeneratedColumn<bool> get observationsLocked => $composableBuilder(
      column: $table.observationsLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  $$UsersTableAnnotationComposer get creatorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.creatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> forayParticipantsRefs<T extends Object>(
      Expression<T> Function($$ForayParticipantsTableAnnotationComposer a) f) {
    final $$ForayParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.forayParticipants,
            getReferencedColumn: (t) => t.forayId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ForayParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.forayParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> observationsRefs<T extends Object>(
      Expression<T> Function($$ObservationsTableAnnotationComposer a) f) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.forayId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableAnnotationComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ForaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ForaysTable,
    Foray,
    $$ForaysTableFilterComposer,
    $$ForaysTableOrderingComposer,
    $$ForaysTableAnnotationComposer,
    $$ForaysTableCreateCompanionBuilder,
    $$ForaysTableUpdateCompanionBuilder,
    (Foray, $$ForaysTableReferences),
    Foray,
    PrefetchHooks Function(
        {bool creatorId, bool forayParticipantsRefs, bool observationsRefs})> {
  $$ForaysTableTableManager(_$AppDatabase db, $ForaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> creatorId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> locationName = const Value.absent(),
            Value<PrivacyLevel> defaultPrivacy = const Value.absent(),
            Value<String?> joinCode = const Value.absent(),
            Value<ForayStatus> status = const Value.absent(),
            Value<bool> isSolo = const Value.absent(),
            Value<bool> observationsLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ForaysCompanion(
            id: id,
            remoteId: remoteId,
            creatorId: creatorId,
            name: name,
            description: description,
            date: date,
            locationName: locationName,
            defaultPrivacy: defaultPrivacy,
            joinCode: joinCode,
            status: status,
            isSolo: isSolo,
            observationsLocked: observationsLocked,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String creatorId,
            required String name,
            Value<String?> description = const Value.absent(),
            required DateTime date,
            Value<String?> locationName = const Value.absent(),
            Value<PrivacyLevel> defaultPrivacy = const Value.absent(),
            Value<String?> joinCode = const Value.absent(),
            Value<ForayStatus> status = const Value.absent(),
            Value<bool> isSolo = const Value.absent(),
            Value<bool> observationsLocked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ForaysCompanion.insert(
            id: id,
            remoteId: remoteId,
            creatorId: creatorId,
            name: name,
            description: description,
            date: date,
            locationName: locationName,
            defaultPrivacy: defaultPrivacy,
            joinCode: joinCode,
            status: status,
            isSolo: isSolo,
            observationsLocked: observationsLocked,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ForaysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {creatorId = false,
              forayParticipantsRefs = false,
              observationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (forayParticipantsRefs) db.forayParticipants,
                if (observationsRefs) db.observations
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (creatorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.creatorId,
                    referencedTable:
                        $$ForaysTableReferences._creatorIdTable(db),
                    referencedColumn:
                        $$ForaysTableReferences._creatorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (forayParticipantsRefs)
                    await $_getPrefetchedData<Foray, $ForaysTable,
                            ForayParticipant>(
                        currentTable: table,
                        referencedTable: $$ForaysTableReferences
                            ._forayParticipantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ForaysTableReferences(db, table, p0)
                                .forayParticipantsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.forayId == item.id),
                        typedResults: items),
                  if (observationsRefs)
                    await $_getPrefetchedData<Foray, $ForaysTable, Observation>(
                        currentTable: table,
                        referencedTable:
                            $$ForaysTableReferences._observationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ForaysTableReferences(db, table, p0)
                                .observationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.forayId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ForaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ForaysTable,
    Foray,
    $$ForaysTableFilterComposer,
    $$ForaysTableOrderingComposer,
    $$ForaysTableAnnotationComposer,
    $$ForaysTableCreateCompanionBuilder,
    $$ForaysTableUpdateCompanionBuilder,
    (Foray, $$ForaysTableReferences),
    Foray,
    PrefetchHooks Function(
        {bool creatorId, bool forayParticipantsRefs, bool observationsRefs})>;
typedef $$ForayParticipantsTableCreateCompanionBuilder
    = ForayParticipantsCompanion Function({
  required String forayId,
  required String userId,
  Value<ParticipantRole> role,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});
typedef $$ForayParticipantsTableUpdateCompanionBuilder
    = ForayParticipantsCompanion Function({
  Value<String> forayId,
  Value<String> userId,
  Value<ParticipantRole> role,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

final class $$ForayParticipantsTableReferences extends BaseReferences<
    _$AppDatabase, $ForayParticipantsTable, ForayParticipant> {
  $$ForayParticipantsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ForaysTable _forayIdTable(_$AppDatabase db) => db.forays.createAlias(
      $_aliasNameGenerator(db.forayParticipants.forayId, db.forays.id));

  $$ForaysTableProcessedTableManager get forayId {
    final $_column = $_itemColumn<String>('foray_id')!;

    final manager = $$ForaysTableTableManager($_db, $_db.forays)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_forayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.forayParticipants.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ForayParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ForayParticipantsTable> {
  $$ForayParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ParticipantRole, ParticipantRole, String>
      get role => $composableBuilder(
          column: $table.role,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  $$ForaysTableFilterComposer get forayId {
    final $$ForaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableFilterComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ForayParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ForayParticipantsTable> {
  $$ForayParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  $$ForaysTableOrderingComposer get forayId {
    final $$ForaysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableOrderingComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ForayParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ForayParticipantsTable> {
  $$ForayParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ParticipantRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$ForaysTableAnnotationComposer get forayId {
    final $$ForaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableAnnotationComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ForayParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ForayParticipantsTable,
    ForayParticipant,
    $$ForayParticipantsTableFilterComposer,
    $$ForayParticipantsTableOrderingComposer,
    $$ForayParticipantsTableAnnotationComposer,
    $$ForayParticipantsTableCreateCompanionBuilder,
    $$ForayParticipantsTableUpdateCompanionBuilder,
    (ForayParticipant, $$ForayParticipantsTableReferences),
    ForayParticipant,
    PrefetchHooks Function({bool forayId, bool userId})> {
  $$ForayParticipantsTableTableManager(
      _$AppDatabase db, $ForayParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForayParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForayParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForayParticipantsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> forayId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<ParticipantRole> role = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ForayParticipantsCompanion(
            forayId: forayId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String forayId,
            required String userId,
            Value<ParticipantRole> role = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ForayParticipantsCompanion.insert(
            forayId: forayId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ForayParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({forayId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (forayId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.forayId,
                    referencedTable:
                        $$ForayParticipantsTableReferences._forayIdTable(db),
                    referencedColumn:
                        $$ForayParticipantsTableReferences._forayIdTable(db).id,
                  ) as T;
                }
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$ForayParticipantsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ForayParticipantsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ForayParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ForayParticipantsTable,
    ForayParticipant,
    $$ForayParticipantsTableFilterComposer,
    $$ForayParticipantsTableOrderingComposer,
    $$ForayParticipantsTableAnnotationComposer,
    $$ForayParticipantsTableCreateCompanionBuilder,
    $$ForayParticipantsTableUpdateCompanionBuilder,
    (ForayParticipant, $$ForayParticipantsTableReferences),
    ForayParticipant,
    PrefetchHooks Function({bool forayId, bool userId})>;
typedef $$ObservationsTableCreateCompanionBuilder = ObservationsCompanion
    Function({
  required String id,
  Value<String?> remoteId,
  required String forayId,
  required String collectorId,
  required double latitude,
  required double longitude,
  Value<double?> gpsAccuracy,
  Value<double?> altitude,
  Value<PrivacyLevel> privacyLevel,
  required DateTime observedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> specimenId,
  Value<String?> collectionNumber,
  Value<String?> substrate,
  Value<String?> habitatNotes,
  Value<String?> fieldNotes,
  Value<String?> sporePrintColor,
  Value<String?> preliminaryId,
  Value<ConfidenceLevel?> preliminaryIdConfidence,
  Value<bool> isDraft,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastViewedAt,
  Value<int> rowid,
});
typedef $$ObservationsTableUpdateCompanionBuilder = ObservationsCompanion
    Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> forayId,
  Value<String> collectorId,
  Value<double> latitude,
  Value<double> longitude,
  Value<double?> gpsAccuracy,
  Value<double?> altitude,
  Value<PrivacyLevel> privacyLevel,
  Value<DateTime> observedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> specimenId,
  Value<String?> collectionNumber,
  Value<String?> substrate,
  Value<String?> habitatNotes,
  Value<String?> fieldNotes,
  Value<String?> sporePrintColor,
  Value<String?> preliminaryId,
  Value<ConfidenceLevel?> preliminaryIdConfidence,
  Value<bool> isDraft,
  Value<SyncStatus> syncStatus,
  Value<DateTime?> lastViewedAt,
  Value<int> rowid,
});

final class $$ObservationsTableReferences
    extends BaseReferences<_$AppDatabase, $ObservationsTable, Observation> {
  $$ObservationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ForaysTable _forayIdTable(_$AppDatabase db) => db.forays
      .createAlias($_aliasNameGenerator(db.observations.forayId, db.forays.id));

  $$ForaysTableProcessedTableManager get forayId {
    final $_column = $_itemColumn<String>('foray_id')!;

    final manager = $$ForaysTableTableManager($_db, $_db.forays)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_forayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _collectorIdTable(_$AppDatabase db) =>
      db.users.createAlias(
          $_aliasNameGenerator(db.observations.collectorId, db.users.id));

  $$UsersTableProcessedTableManager get collectorId {
    final $_column = $_itemColumn<String>('collector_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.photos,
          aliasName: $_aliasNameGenerator(
              db.observations.id, db.photos.observationId));

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager($_db, $_db.photos).filter(
        (f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$IdentificationsTable, List<Identification>>
      _identificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.identifications,
              aliasName: $_aliasNameGenerator(
                  db.observations.id, db.identifications.observationId));

  $$IdentificationsTableProcessedTableManager get identificationsRefs {
    final manager =
        $$IdentificationsTableTableManager($_db, $_db.identifications).filter(
            (f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_identificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CommentsTable, List<Comment>> _commentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.comments,
          aliasName: $_aliasNameGenerator(
              db.observations.id, db.comments.observationId));

  $$CommentsTableProcessedTableManager get commentsRefs {
    final manager = $$CommentsTableTableManager($_db, $_db.comments).filter(
        (f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PrivacyLevel, PrivacyLevel, String>
      get privacyLevel => $composableBuilder(
          column: $table.privacyLevel,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specimenId => $composableBuilder(
      column: $table.specimenId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionNumber => $composableBuilder(
      column: $table.collectionNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get substrate => $composableBuilder(
      column: $table.substrate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitatNotes => $composableBuilder(
      column: $table.habitatNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldNotes => $composableBuilder(
      column: $table.fieldNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sporePrintColor => $composableBuilder(
      column: $table.sporePrintColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preliminaryId => $composableBuilder(
      column: $table.preliminaryId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ConfidenceLevel?, ConfidenceLevel, String>
      get preliminaryIdConfidence => $composableBuilder(
          column: $table.preliminaryIdConfidence,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isDraft => $composableBuilder(
      column: $table.isDraft, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastViewedAt => $composableBuilder(
      column: $table.lastViewedAt, builder: (column) => ColumnFilters(column));

  $$ForaysTableFilterComposer get forayId {
    final $$ForaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableFilterComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get collectorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> photosRefs(
      Expression<bool> Function($$PhotosTableFilterComposer f) f) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableFilterComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> identificationsRefs(
      Expression<bool> Function($$IdentificationsTableFilterComposer f) f) {
    final $$IdentificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableFilterComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> commentsRefs(
      Expression<bool> Function($$CommentsTableFilterComposer f) f) {
    final $$CommentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableFilterComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get privacyLevel => $composableBuilder(
      column: $table.privacyLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specimenId => $composableBuilder(
      column: $table.specimenId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionNumber => $composableBuilder(
      column: $table.collectionNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get substrate => $composableBuilder(
      column: $table.substrate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitatNotes => $composableBuilder(
      column: $table.habitatNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldNotes => $composableBuilder(
      column: $table.fieldNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sporePrintColor => $composableBuilder(
      column: $table.sporePrintColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preliminaryId => $composableBuilder(
      column: $table.preliminaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preliminaryIdConfidence => $composableBuilder(
      column: $table.preliminaryIdConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDraft => $composableBuilder(
      column: $table.isDraft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastViewedAt => $composableBuilder(
      column: $table.lastViewedAt,
      builder: (column) => ColumnOrderings(column));

  $$ForaysTableOrderingComposer get forayId {
    final $$ForaysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableOrderingComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get collectorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrivacyLevel, String> get privacyLevel =>
      $composableBuilder(
          column: $table.privacyLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
      column: $table.observedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get specimenId => $composableBuilder(
      column: $table.specimenId, builder: (column) => column);

  GeneratedColumn<String> get collectionNumber => $composableBuilder(
      column: $table.collectionNumber, builder: (column) => column);

  GeneratedColumn<String> get substrate =>
      $composableBuilder(column: $table.substrate, builder: (column) => column);

  GeneratedColumn<String> get habitatNotes => $composableBuilder(
      column: $table.habitatNotes, builder: (column) => column);

  GeneratedColumn<String> get fieldNotes => $composableBuilder(
      column: $table.fieldNotes, builder: (column) => column);

  GeneratedColumn<String> get sporePrintColor => $composableBuilder(
      column: $table.sporePrintColor, builder: (column) => column);

  GeneratedColumn<String> get preliminaryId => $composableBuilder(
      column: $table.preliminaryId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConfidenceLevel?, String>
      get preliminaryIdConfidence => $composableBuilder(
          column: $table.preliminaryIdConfidence, builder: (column) => column);

  GeneratedColumn<bool> get isDraft =>
      $composableBuilder(column: $table.isDraft, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastViewedAt => $composableBuilder(
      column: $table.lastViewedAt, builder: (column) => column);

  $$ForaysTableAnnotationComposer get forayId {
    final $$ForaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.forayId,
        referencedTable: $db.forays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ForaysTableAnnotationComposer(
              $db: $db,
              $table: $db.forays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get collectorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> photosRefs<T extends Object>(
      Expression<T> Function($$PhotosTableAnnotationComposer a) f) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> identificationsRefs<T extends Object>(
      Expression<T> Function($$IdentificationsTableAnnotationComposer a) f) {
    final $$IdentificationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableAnnotationComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> commentsRefs<T extends Object>(
      Expression<T> Function($$CommentsTableAnnotationComposer a) f) {
    final $$CommentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.comments,
        getReferencedColumn: (t) => t.observationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommentsTableAnnotationComposer(
              $db: $db,
              $table: $db.comments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ObservationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ObservationsTable,
    Observation,
    $$ObservationsTableFilterComposer,
    $$ObservationsTableOrderingComposer,
    $$ObservationsTableAnnotationComposer,
    $$ObservationsTableCreateCompanionBuilder,
    $$ObservationsTableUpdateCompanionBuilder,
    (Observation, $$ObservationsTableReferences),
    Observation,
    PrefetchHooks Function(
        {bool forayId,
        bool collectorId,
        bool photosRefs,
        bool identificationsRefs,
        bool commentsRefs})> {
  $$ObservationsTableTableManager(_$AppDatabase db, $ObservationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> forayId = const Value.absent(),
            Value<String> collectorId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<double?> altitude = const Value.absent(),
            Value<PrivacyLevel> privacyLevel = const Value.absent(),
            Value<DateTime> observedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> specimenId = const Value.absent(),
            Value<String?> collectionNumber = const Value.absent(),
            Value<String?> substrate = const Value.absent(),
            Value<String?> habitatNotes = const Value.absent(),
            Value<String?> fieldNotes = const Value.absent(),
            Value<String?> sporePrintColor = const Value.absent(),
            Value<String?> preliminaryId = const Value.absent(),
            Value<ConfidenceLevel?> preliminaryIdConfidence =
                const Value.absent(),
            Value<bool> isDraft = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime?> lastViewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObservationsCompanion(
            id: id,
            remoteId: remoteId,
            forayId: forayId,
            collectorId: collectorId,
            latitude: latitude,
            longitude: longitude,
            gpsAccuracy: gpsAccuracy,
            altitude: altitude,
            privacyLevel: privacyLevel,
            observedAt: observedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            specimenId: specimenId,
            collectionNumber: collectionNumber,
            substrate: substrate,
            habitatNotes: habitatNotes,
            fieldNotes: fieldNotes,
            sporePrintColor: sporePrintColor,
            preliminaryId: preliminaryId,
            preliminaryIdConfidence: preliminaryIdConfidence,
            isDraft: isDraft,
            syncStatus: syncStatus,
            lastViewedAt: lastViewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String forayId,
            required String collectorId,
            required double latitude,
            required double longitude,
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<double?> altitude = const Value.absent(),
            Value<PrivacyLevel> privacyLevel = const Value.absent(),
            required DateTime observedAt,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> specimenId = const Value.absent(),
            Value<String?> collectionNumber = const Value.absent(),
            Value<String?> substrate = const Value.absent(),
            Value<String?> habitatNotes = const Value.absent(),
            Value<String?> fieldNotes = const Value.absent(),
            Value<String?> sporePrintColor = const Value.absent(),
            Value<String?> preliminaryId = const Value.absent(),
            Value<ConfidenceLevel?> preliminaryIdConfidence =
                const Value.absent(),
            Value<bool> isDraft = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<DateTime?> lastViewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObservationsCompanion.insert(
            id: id,
            remoteId: remoteId,
            forayId: forayId,
            collectorId: collectorId,
            latitude: latitude,
            longitude: longitude,
            gpsAccuracy: gpsAccuracy,
            altitude: altitude,
            privacyLevel: privacyLevel,
            observedAt: observedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            specimenId: specimenId,
            collectionNumber: collectionNumber,
            substrate: substrate,
            habitatNotes: habitatNotes,
            fieldNotes: fieldNotes,
            sporePrintColor: sporePrintColor,
            preliminaryId: preliminaryId,
            preliminaryIdConfidence: preliminaryIdConfidence,
            isDraft: isDraft,
            syncStatus: syncStatus,
            lastViewedAt: lastViewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ObservationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {forayId = false,
              collectorId = false,
              photosRefs = false,
              identificationsRefs = false,
              commentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (photosRefs) db.photos,
                if (identificationsRefs) db.identifications,
                if (commentsRefs) db.comments
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (forayId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.forayId,
                    referencedTable:
                        $$ObservationsTableReferences._forayIdTable(db),
                    referencedColumn:
                        $$ObservationsTableReferences._forayIdTable(db).id,
                  ) as T;
                }
                if (collectorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectorId,
                    referencedTable:
                        $$ObservationsTableReferences._collectorIdTable(db),
                    referencedColumn:
                        $$ObservationsTableReferences._collectorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (photosRefs)
                    await $_getPrefetchedData<Observation, $ObservationsTable,
                            Photo>(
                        currentTable: table,
                        referencedTable:
                            $$ObservationsTableReferences._photosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ObservationsTableReferences(db, table, p0)
                                .photosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.observationId == item.id),
                        typedResults: items),
                  if (identificationsRefs)
                    await $_getPrefetchedData<Observation, $ObservationsTable,
                            Identification>(
                        currentTable: table,
                        referencedTable: $$ObservationsTableReferences
                            ._identificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ObservationsTableReferences(db, table, p0)
                                .identificationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.observationId == item.id),
                        typedResults: items),
                  if (commentsRefs)
                    await $_getPrefetchedData<Observation, $ObservationsTable,
                            Comment>(
                        currentTable: table,
                        referencedTable: $$ObservationsTableReferences
                            ._commentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ObservationsTableReferences(db, table, p0)
                                .commentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.observationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ObservationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ObservationsTable,
    Observation,
    $$ObservationsTableFilterComposer,
    $$ObservationsTableOrderingComposer,
    $$ObservationsTableAnnotationComposer,
    $$ObservationsTableCreateCompanionBuilder,
    $$ObservationsTableUpdateCompanionBuilder,
    (Observation, $$ObservationsTableReferences),
    Observation,
    PrefetchHooks Function(
        {bool forayId,
        bool collectorId,
        bool photosRefs,
        bool identificationsRefs,
        bool commentsRefs})>;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String observationId,
  required String localPath,
  Value<String?> remoteUrl,
  Value<int> sortOrder,
  Value<String?> caption,
  Value<UploadStatus> uploadStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> observationId,
  Value<String> localPath,
  Value<String?> remoteUrl,
  Value<int> sortOrder,
  Value<String?> caption,
  Value<UploadStatus> uploadStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.observations.createAlias(
          $_aliasNameGenerator(db.photos.observationId, db.observations.id));

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UploadStatus, UploadStatus, String>
      get uploadStatus => $composableBuilder(
          column: $table.uploadStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableFilterComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableOrderingComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UploadStatus, String> get uploadStatus =>
      $composableBuilder(
          column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableAnnotationComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotosTable,
    Photo,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (Photo, $$PhotosTableReferences),
    Photo,
    PrefetchHooks Function({bool observationId})> {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> observationId = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<UploadStatus> uploadStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            localPath: localPath,
            remoteUrl: remoteUrl,
            sortOrder: sortOrder,
            caption: caption,
            uploadStatus: uploadStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String observationId,
            required String localPath,
            Value<String?> remoteUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<UploadStatus> uploadStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion.insert(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            localPath: localPath,
            remoteUrl: remoteUrl,
            sortOrder: sortOrder,
            caption: caption,
            uploadStatus: uploadStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PhotosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({observationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (observationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.observationId,
                    referencedTable:
                        $$PhotosTableReferences._observationIdTable(db),
                    referencedColumn:
                        $$PhotosTableReferences._observationIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotosTable,
    Photo,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (Photo, $$PhotosTableReferences),
    Photo,
    PrefetchHooks Function({bool observationId})>;
typedef $$IdentificationsTableCreateCompanionBuilder = IdentificationsCompanion
    Function({
  required String id,
  Value<String?> remoteId,
  required String observationId,
  required String identifierId,
  required String speciesName,
  Value<String?> commonName,
  Value<ConfidenceLevel> confidence,
  Value<String?> notes,
  Value<int> voteCount,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$IdentificationsTableUpdateCompanionBuilder = IdentificationsCompanion
    Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> observationId,
  Value<String> identifierId,
  Value<String> speciesName,
  Value<String?> commonName,
  Value<ConfidenceLevel> confidence,
  Value<String?> notes,
  Value<int> voteCount,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$IdentificationsTableReferences extends BaseReferences<
    _$AppDatabase, $IdentificationsTable, Identification> {
  $$IdentificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.observations.createAlias($_aliasNameGenerator(
          db.identifications.observationId, db.observations.id));

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _identifierIdTable(_$AppDatabase db) =>
      db.users.createAlias(
          $_aliasNameGenerator(db.identifications.identifierId, db.users.id));

  $$UsersTableProcessedTableManager get identifierId {
    final $_column = $_itemColumn<String>('identifier_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identifierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$IdentificationVotesTable,
      List<IdentificationVote>> _identificationVotesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.identificationVotes,
          aliasName: $_aliasNameGenerator(
              db.identifications.id, db.identificationVotes.identificationId));

  $$IdentificationVotesTableProcessedTableManager get identificationVotesRefs {
    final manager =
        $$IdentificationVotesTableTableManager($_db, $_db.identificationVotes)
            .filter((f) =>
                f.identificationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_identificationVotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$IdentificationsTableFilterComposer
    extends Composer<_$AppDatabase, $IdentificationsTable> {
  $$IdentificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speciesName => $composableBuilder(
      column: $table.speciesName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ConfidenceLevel, ConfidenceLevel, String>
      get confidence => $composableBuilder(
          column: $table.confidence,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get voteCount => $composableBuilder(
      column: $table.voteCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableFilterComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get identifierId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identifierId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> identificationVotesRefs(
      Expression<bool> Function($$IdentificationVotesTableFilterComposer f) f) {
    final $$IdentificationVotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.identificationVotes,
        getReferencedColumn: (t) => t.identificationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationVotesTableFilterComposer(
              $db: $db,
              $table: $db.identificationVotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IdentificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentificationsTable> {
  $$IdentificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speciesName => $composableBuilder(
      column: $table.speciesName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get voteCount => $composableBuilder(
      column: $table.voteCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableOrderingComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get identifierId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identifierId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IdentificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentificationsTable> {
  $$IdentificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get speciesName => $composableBuilder(
      column: $table.speciesName, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConfidenceLevel, String> get confidence =>
      $composableBuilder(
          column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get voteCount =>
      $composableBuilder(column: $table.voteCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableAnnotationComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get identifierId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identifierId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> identificationVotesRefs<T extends Object>(
      Expression<T> Function($$IdentificationVotesTableAnnotationComposer a)
          f) {
    final $$IdentificationVotesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.identificationVotes,
            getReferencedColumn: (t) => t.identificationId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$IdentificationVotesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.identificationVotes,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$IdentificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IdentificationsTable,
    Identification,
    $$IdentificationsTableFilterComposer,
    $$IdentificationsTableOrderingComposer,
    $$IdentificationsTableAnnotationComposer,
    $$IdentificationsTableCreateCompanionBuilder,
    $$IdentificationsTableUpdateCompanionBuilder,
    (Identification, $$IdentificationsTableReferences),
    Identification,
    PrefetchHooks Function(
        {bool observationId,
        bool identifierId,
        bool identificationVotesRefs})> {
  $$IdentificationsTableTableManager(
      _$AppDatabase db, $IdentificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> observationId = const Value.absent(),
            Value<String> identifierId = const Value.absent(),
            Value<String> speciesName = const Value.absent(),
            Value<String?> commonName = const Value.absent(),
            Value<ConfidenceLevel> confidence = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> voteCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdentificationsCompanion(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            identifierId: identifierId,
            speciesName: speciesName,
            commonName: commonName,
            confidence: confidence,
            notes: notes,
            voteCount: voteCount,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String observationId,
            required String identifierId,
            required String speciesName,
            Value<String?> commonName = const Value.absent(),
            Value<ConfidenceLevel> confidence = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> voteCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdentificationsCompanion.insert(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            identifierId: identifierId,
            speciesName: speciesName,
            commonName: commonName,
            confidence: confidence,
            notes: notes,
            voteCount: voteCount,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$IdentificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {observationId = false,
              identifierId = false,
              identificationVotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (identificationVotesRefs) db.identificationVotes
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (observationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.observationId,
                    referencedTable: $$IdentificationsTableReferences
                        ._observationIdTable(db),
                    referencedColumn: $$IdentificationsTableReferences
                        ._observationIdTable(db)
                        .id,
                  ) as T;
                }
                if (identifierId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.identifierId,
                    referencedTable:
                        $$IdentificationsTableReferences._identifierIdTable(db),
                    referencedColumn: $$IdentificationsTableReferences
                        ._identifierIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (identificationVotesRefs)
                    await $_getPrefetchedData<Identification,
                            $IdentificationsTable, IdentificationVote>(
                        currentTable: table,
                        referencedTable: $$IdentificationsTableReferences
                            ._identificationVotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IdentificationsTableReferences(db, table, p0)
                                .identificationVotesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.identificationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$IdentificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IdentificationsTable,
    Identification,
    $$IdentificationsTableFilterComposer,
    $$IdentificationsTableOrderingComposer,
    $$IdentificationsTableAnnotationComposer,
    $$IdentificationsTableCreateCompanionBuilder,
    $$IdentificationsTableUpdateCompanionBuilder,
    (Identification, $$IdentificationsTableReferences),
    Identification,
    PrefetchHooks Function(
        {bool observationId, bool identifierId, bool identificationVotesRefs})>;
typedef $$IdentificationVotesTableCreateCompanionBuilder
    = IdentificationVotesCompanion Function({
  required String identificationId,
  required String userId,
  Value<DateTime> votedAt,
  Value<int> rowid,
});
typedef $$IdentificationVotesTableUpdateCompanionBuilder
    = IdentificationVotesCompanion Function({
  Value<String> identificationId,
  Value<String> userId,
  Value<DateTime> votedAt,
  Value<int> rowid,
});

final class $$IdentificationVotesTableReferences extends BaseReferences<
    _$AppDatabase, $IdentificationVotesTable, IdentificationVote> {
  $$IdentificationVotesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $IdentificationsTable _identificationIdTable(_$AppDatabase db) =>
      db.identifications.createAlias($_aliasNameGenerator(
          db.identificationVotes.identificationId, db.identifications.id));

  $$IdentificationsTableProcessedTableManager get identificationId {
    final $_column = $_itemColumn<String>('identification_id')!;

    final manager =
        $$IdentificationsTableTableManager($_db, $_db.identifications)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identificationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.identificationVotes.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$IdentificationVotesTableFilterComposer
    extends Composer<_$AppDatabase, $IdentificationVotesTable> {
  $$IdentificationVotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get votedAt => $composableBuilder(
      column: $table.votedAt, builder: (column) => ColumnFilters(column));

  $$IdentificationsTableFilterComposer get identificationId {
    final $$IdentificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identificationId,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableFilterComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IdentificationVotesTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentificationVotesTable> {
  $$IdentificationVotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get votedAt => $composableBuilder(
      column: $table.votedAt, builder: (column) => ColumnOrderings(column));

  $$IdentificationsTableOrderingComposer get identificationId {
    final $$IdentificationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identificationId,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableOrderingComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IdentificationVotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentificationVotesTable> {
  $$IdentificationVotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get votedAt =>
      $composableBuilder(column: $table.votedAt, builder: (column) => column);

  $$IdentificationsTableAnnotationComposer get identificationId {
    final $$IdentificationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identificationId,
        referencedTable: $db.identifications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IdentificationsTableAnnotationComposer(
              $db: $db,
              $table: $db.identifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$IdentificationVotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IdentificationVotesTable,
    IdentificationVote,
    $$IdentificationVotesTableFilterComposer,
    $$IdentificationVotesTableOrderingComposer,
    $$IdentificationVotesTableAnnotationComposer,
    $$IdentificationVotesTableCreateCompanionBuilder,
    $$IdentificationVotesTableUpdateCompanionBuilder,
    (IdentificationVote, $$IdentificationVotesTableReferences),
    IdentificationVote,
    PrefetchHooks Function({bool identificationId, bool userId})> {
  $$IdentificationVotesTableTableManager(
      _$AppDatabase db, $IdentificationVotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentificationVotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentificationVotesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentificationVotesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> identificationId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> votedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdentificationVotesCompanion(
            identificationId: identificationId,
            userId: userId,
            votedAt: votedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String identificationId,
            required String userId,
            Value<DateTime> votedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdentificationVotesCompanion.insert(
            identificationId: identificationId,
            userId: userId,
            votedAt: votedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$IdentificationVotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({identificationId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (identificationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.identificationId,
                    referencedTable: $$IdentificationVotesTableReferences
                        ._identificationIdTable(db),
                    referencedColumn: $$IdentificationVotesTableReferences
                        ._identificationIdTable(db)
                        .id,
                  ) as T;
                }
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$IdentificationVotesTableReferences._userIdTable(db),
                    referencedColumn: $$IdentificationVotesTableReferences
                        ._userIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$IdentificationVotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IdentificationVotesTable,
    IdentificationVote,
    $$IdentificationVotesTableFilterComposer,
    $$IdentificationVotesTableOrderingComposer,
    $$IdentificationVotesTableAnnotationComposer,
    $$IdentificationVotesTableCreateCompanionBuilder,
    $$IdentificationVotesTableUpdateCompanionBuilder,
    (IdentificationVote, $$IdentificationVotesTableReferences),
    IdentificationVote,
    PrefetchHooks Function({bool identificationId, bool userId})>;
typedef $$CommentsTableCreateCompanionBuilder = CommentsCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String observationId,
  required String authorId,
  required String content,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});
typedef $$CommentsTableUpdateCompanionBuilder = CommentsCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> observationId,
  Value<String> authorId,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<SyncStatus> syncStatus,
  Value<int> rowid,
});

final class $$CommentsTableReferences
    extends BaseReferences<_$AppDatabase, $CommentsTable, Comment> {
  $$CommentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.observations.createAlias(
          $_aliasNameGenerator(db.comments.observationId, db.observations.id));

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager($_db, $_db.observations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _authorIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.comments.authorId, db.users.id));

  $$UsersTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<String>('author_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CommentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
      get syncStatus => $composableBuilder(
          column: $table.syncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableFilterComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get authorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableOrderingComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get authorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
          column: $table.syncStatus, builder: (column) => column);

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.observationId,
        referencedTable: $db.observations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ObservationsTableAnnotationComposer(
              $db: $db,
              $table: $db.observations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get authorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommentsTable,
    Comment,
    $$CommentsTableFilterComposer,
    $$CommentsTableOrderingComposer,
    $$CommentsTableAnnotationComposer,
    $$CommentsTableCreateCompanionBuilder,
    $$CommentsTableUpdateCompanionBuilder,
    (Comment, $$CommentsTableReferences),
    Comment,
    PrefetchHooks Function({bool observationId, bool authorId})> {
  $$CommentsTableTableManager(_$AppDatabase db, $CommentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> observationId = const Value.absent(),
            Value<String> authorId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsCompanion(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            authorId: authorId,
            content: content,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String observationId,
            required String authorId,
            required String content,
            Value<DateTime> createdAt = const Value.absent(),
            Value<SyncStatus> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentsCompanion.insert(
            id: id,
            remoteId: remoteId,
            observationId: observationId,
            authorId: authorId,
            content: content,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CommentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({observationId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (observationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.observationId,
                    referencedTable:
                        $$CommentsTableReferences._observationIdTable(db),
                    referencedColumn:
                        $$CommentsTableReferences._observationIdTable(db).id,
                  ) as T;
                }
                if (authorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.authorId,
                    referencedTable:
                        $$CommentsTableReferences._authorIdTable(db),
                    referencedColumn:
                        $$CommentsTableReferences._authorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CommentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommentsTable,
    Comment,
    $$CommentsTableFilterComposer,
    $$CommentsTableOrderingComposer,
    $$CommentsTableAnnotationComposer,
    $$CommentsTableCreateCompanionBuilder,
    $$CommentsTableUpdateCompanionBuilder,
    (Comment, $$CommentsTableReferences),
    Comment,
    PrefetchHooks Function({bool observationId, bool authorId})>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required SyncOperation operation,
  Value<String?> payload,
  Value<SyncQueueStatus> status,
  Value<int> retryCount,
  Value<DateTime?> lastAttempt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<SyncOperation> operation,
  Value<String?> payload,
  Value<SyncQueueStatus> status,
  Value<int> retryCount,
  Value<DateTime?> lastAttempt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncOperation, SyncOperation, String>
      get operation => $composableBuilder(
          column: $table.operation,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SyncQueueStatus, SyncQueueStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncQueueStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<SyncOperation> operation = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<SyncQueueStatus> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> lastAttempt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastAttempt: lastAttempt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required SyncOperation operation,
            Value<String?> payload = const Value.absent(),
            Value<SyncQueueStatus> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> lastAttempt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastAttempt: lastAttempt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ForaysTableTableManager get forays =>
      $$ForaysTableTableManager(_db, _db.forays);
  $$ForayParticipantsTableTableManager get forayParticipants =>
      $$ForayParticipantsTableTableManager(_db, _db.forayParticipants);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$IdentificationsTableTableManager get identifications =>
      $$IdentificationsTableTableManager(_db, _db.identifications);
  $$IdentificationVotesTableTableManager get identificationVotes =>
      $$IdentificationVotesTableTableManager(_db, _db.identificationVotes);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db, _db.comments);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
