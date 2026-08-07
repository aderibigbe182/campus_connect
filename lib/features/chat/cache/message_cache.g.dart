// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageCacheAdapter extends TypeAdapter<MessageCache> {
  @override
  final int typeId = 11;

  @override
  MessageCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageCache(
      id: fields[0] as int,
      conversationId: fields[1] as int,
      senderId: fields[2] as int,
      message: fields[3] as String?,
      messageType: fields[4] as String,
      delivered: fields[5] as bool,
      seen: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageCache obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.messageType)
      ..writeByte(5)
      ..write(obj.delivered)
      ..writeByte(6)
      ..write(obj.seen)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
