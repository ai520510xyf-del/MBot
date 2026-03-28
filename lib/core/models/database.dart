import 'dart:io';
import 'dart:async';
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

/// Skills 表定义
@DataClassName('Skill')
class Skills extends Table {
  /// 主键 ID (UUID)
  TextColumn get id => text()();

  /// 技能名称
  TextColumn get name => text()();

  /// 技能描述
  TextColumn get description => text()();

  /// 技能图标 (emoji)
  TextColumn get emoji => text()();

  /// 版本号
  TextColumn get version => text()();

  /// 作者
  TextColumn get author => text()();

  /// 安装数量
  IntColumn get installCount => integer().withDefault(const Constant(0))();

  /// 评分 (0-5)
  RealColumn get rating => real().withDefault(const Constant(0.0))();

  /// 安装时间
  DateTimeColumn get installedAt => dateTime().nullable()();

  /// 状态
  TextColumn get status =>
      text()(); // 'available', 'installed', 'updateAvailable', 'disabled'

  /// 分类
  TextColumn get category =>
      text()(); // 'all', 'ai', 'text', 'image', 'code', 'productivity'

  /// 标签 (逗号分隔)
  TextColumn get tags => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Agents 表定义
@DataClassName('Agent')
class Agents extends Table {
  /// 主键 ID (UUID)
  TextColumn get id => text()();

  /// Agent 名称
  TextColumn get name => text()();

  /// Agent 图标 (emoji)
  TextColumn get emoji => text()();

  /// 状态
  TextColumn get status => text()(); // 'online', 'offline', 'busy'

  /// 模型名称
  TextColumn get model => text()();

  /// 任务数量
  IntColumn get taskCount => integer().withDefault(const Constant(0))();

  /// 最后活跃时间
  DateTimeColumn get lastActive => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Memories 表定义
@DataClassName('Memory')
class Memories extends Table {
  /// 主键 ID (UUID)
  TextColumn get id => text()();

  /// 记忆内容
  TextColumn get content => text()();

  /// 分类
  TextColumn get category =>
      text()(); // 'preference', 'fact', 'decision', 'entity'

  /// 来源
  TextColumn get source => text()(); // 'user', 'ai', 'system'

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// MBot 数据库类
@DriftDatabase(tables: [Conversations, Messages, Skills, Agents, Memories])
class MBotDatabase extends _$MBotDatabase {
  /// 构造函数
  MBotDatabase(super.e);

  /// 数据库版本
  @override
  int get schemaVersion => 3;

  /// 数据库迁移逻辑
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 版本 3: 添加 Memories 表
        if (from < 3) {
          await m.createTable(memories);
        }
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
      try {
        final dataDir = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dataDir.path, 'mbot.db'));
        
        // Ensure directory exists
        if (!await dataDir.exists()) {
          await dataDir.create(recursive: true);
        }
        
        return NativeDatabase.createInBackground(dbFile);
      } catch (e) {
        throw Exception('Failed to open database: $e');
      }
    });
    return MBotDatabase(executor);
  }
}
