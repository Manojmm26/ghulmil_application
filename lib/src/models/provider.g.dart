// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Provider _$ProviderFromJson(Map<String, dynamic> json) => _Provider(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String,
  rating: (json['rating'] as num).toDouble(),
  verified: json['verified'] as bool,
  languages: (json['languages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ProviderToJson(_Provider instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'rating': instance.rating,
  'verified': instance.verified,
  'languages': instance.languages,
};
