import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Conversations 表定义
@DataClassName('Conversation')
class Conversations extends Table {
  /// 主键 ID (UUID)
  TextColumn get id => text()();

  /// 会话标题
  TextColumn get title => text()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  /// 最后一条消息预览
  TextColumn get lastMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Messages 表定义
@DataClassName('Message')
class Messages extends Table {
  /// 主键 ID (UUID)
  TextColumn get id => text()();

  /// 所属会话 ID
  TextColumn get conversationId => text()();

  /// 消息内容
  TextColumn get content => text()();

  /// 发送者类型
  TextColumn get sender => text()(); // 'user', 'ai', 'tool'

  /// 时间戳
  DateTimeColumn get timestamp => dateTime()();

  /// 工具名称 (仅当 sender='tool' 时有值)
  TextColumn get toolName => text().nullable()();

  /// 工具执行结果 (仅当 sender='tool' 时有值)
  TextColumn get toolResult => text().nullable()();

  /// 消息状态
  TextColumn get status => text()(); // 'pending', 'sending', 'sent', 'failed'

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {conversationId, id}, // 确保消息在会话内唯一
      ];
}

/// MBot 数据库类
@DriftDatabase(tables: [Conversations, Messages])
class MBotDatabase extends _$MBotDatabase {
  /// 构造函数
  MBotDatabase(super.e);

  /// 数据库版本
  @override
  int get schemaVersion => 1;

  /// 数据库迁移逻辑
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 未来版本迁移逻辑
      },
    );
  }

  /// 创建单例实例
  static MBotDatabase? _instance;

  static MBotDatabase get instance {
    _instance ??= MBotDatabase._open();
    return _instance!;
  }

  /// 打开数据库连接
  static MBotDatabase _open() {
    // 使用 Flutter 的 native 数据库引擎
    final executor = LazyDatabase(() async {
      final dataDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dataDir.path, 'mbot.db'));
      return NativeDatabase.createInBackground(dbFile);
    });
    return MBotDatabase(executor);
  }
}
