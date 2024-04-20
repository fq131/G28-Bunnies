// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localdb.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Restaurant extends _Restaurant
    with RealmEntity, RealmObjectBase, RealmObject {
  Restaurant(
    ObjectId id,
    String name,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
  }

  Restaurant._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<Restaurant>> get changes =>
      RealmObjectBase.getChanges<Restaurant>(this);

  @override
  Restaurant freeze() => RealmObjectBase.freezeObject<Restaurant>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Restaurant._);
    return const SchemaObject(
        ObjectType.realmObject, Restaurant, 'Restaurant', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }
}
