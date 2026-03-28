import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 文件类型
enum FileType {
  file('file', '文件', Icons.insert_drive_file_outlined),
  folder('folder', '文件夹', Icons.folder_outlined),
  image('image', '图片', Icons.image_outlined),
  video('video', '视频', Icons.videocam_outlined),
  audio('audio', '音频', Icons.audio_file_outlined),
  document('document', '文档', Icons.description_outlined),
  code('code', '代码', Icons.code_outlined),
  archive('archive', '压缩包', Icons.folder_zip_outlined);

  final String value;
  final String label;
  final IconData icon;

  const FileType(this.value, this.label, this.icon);

  static FileType fromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FileType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return FileType.video;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return FileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'md':
        return FileType.document;
      case 'js':
      case 'ts':
      case 'dart':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'html':
      case 'css':
      case 'json':
        return FileType.code;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileType.archive;
      default:
        return FileType.file;
    }
  }
}

/// 文件项模型
class FileItem {
  final String name;
  final FileType type;
  final int size;
  final DateTime modifiedAt;
  final String path;

  FileItem({
    required this.name,
    required this.type,
    required this.size,
    required this.modifiedAt,
    required this.path,
  });

  String get extension {
    if (type == FileType.folder) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : '';
  }
}

/// 远程文件浏览器页面
class FileBrowserPage extends ConsumerStatefulWidget {
  const FileBrowserPage({super.key});

  @override
  ConsumerState<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends ConsumerState<FileBrowserPage> {
  final List<String> _pathHistory = ['/'];
  final List<FileItem> _mockFiles = _generateMockFiles();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;

  String get _currentPath => _pathHistory.last;

  List<FileItem> get _filteredFiles {
    var files = _mockFiles;

    if (_searchQuery.isNotEmpty) {
      files = files
          .where(
            (f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 文件夹优先，然后按名称排序
    files.sort((a, b) {
      if (a.type == FileType.folder && b.type != FileType.folder) return -1;
      if (a.type != FileType.folder && b.type == FileType.folder) return 1;
      return a.name.compareTo(b.name);
    });

    return files;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件浏览器'),
        actions: [
          // 视图切换按钮
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 路径面包屑
          _buildPathBreadcrumb(),

          // 搜索框
          _buildSearchBar(),

          // 文件列表
          Expanded(
            child: _filteredFiles.isEmpty
                ? _buildEmptyState()
                : _isGridView
                ? _buildGridView()
                : _buildListView(),
          ),

          // 底部状态栏
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildPathBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 18,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildBreadcrumbItems()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems() {
    final items = <Widget>[];
    final parts = _currentPath.split('/')..removeWhere((p) => p.isEmpty);

    items.add(
      InkWell(
        onTap: () => _navigateToPath('/'),
        child: Text(
          '根目录',
          style: const TextStyle(color: AppColors.primary, fontSize: 14),
        ),
      ),
    );

    for (var i = 0; i < parts.length; i++) {
      items.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('/', style: TextStyle(color: AppColors.textTertiary)),
        ),
      );

      final isLast = i == parts.length - 1;
      items.add(
        InkWell(
          onTap: isLast
              ? null
              : () {
                  final newPath = '/${parts.sublist(0, i + 1).join('/')}';
                  _navigateToPath(newPath);
                },
          child: Text(
            parts[i],
            style: TextStyle(
              color: isLast ? AppColors.textPrimary : AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索文件...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMD,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: AppSpace.s2,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        return _buildFileListItem(_filteredFiles[index]);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpace.s4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpace.s3,
        mainAxisSpacing: AppSpace.s3,
        childAspectRatio: 1,
      ),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        return _buildFileGridItem(_filteredFiles[index]);
      },
    );
  }

  Widget _buildFileListItem(FileItem file) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: _buildFileIcon(file),
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatFileSize(file.size),
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        trailing: _buildFileTrailing(file),
        onTap: () => _handleFileTap(file),
      ),
    );
  }

  Widget _buildFileGridItem(FileItem file) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _handleFileTap(file),
        borderRadius: AppRadius.radiusMD,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFileIcon(file, size: 48),
            const SizedBox(height: AppSpace.s2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                file.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(FileItem file, {double size = 32}) {
    Color iconColor;

    switch (file.type) {
      case FileType.folder:
        iconColor = AppColors.warning;
        break;
      case FileType.image:
        iconColor = AppColors.success;
        break;
      case FileType.video:
        iconColor = AppColors.error;
        break;
      case FileType.audio:
        iconColor = AppColors.primary;
        break;
      case FileType.document:
        iconColor = AppColors.info;
        break;
      case FileType.code:
        iconColor = const Color(0xFF7C4DFF);
        break;
      case FileType.archive:
        iconColor = const Color(0xFF78909C);
        break;
      default:
        iconColor = AppColors.textSecondary;
    }

    return Icon(file.type.icon, size: size, color: iconColor);
  }

  Widget _buildFileTrailing(FileItem file) {
    if (file.type == FileType.folder) {
      return const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.textTertiary,
      );
    }
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: 实现文件操作
        if (value == 'download') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('下载 ${file.name}')));
        } else if (value == 'delete') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除 ${file.name}')));
        }
      },
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: AppColors.textTertiary,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download_outlined, size: 18),
              SizedBox(width: 12),
              Text('下载'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              SizedBox(width: 12),
              Text('删除'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final folderCount = _filteredFiles
        .where((f) => f.type == FileType.folder)
        .length;
    final fileCount = _filteredFiles
        .where((f) => f.type != FileType.folder)
        .length;
    final totalSize = _filteredFiles
        .where((f) => f.type != FileType.folder)
        .fold<int>(0, (sum, f) => sum + f.size);

    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('文件夹', '$folderCount', Icons.folder),
          _buildStatusItem('文件', '$fileCount', Icons.insert_drive_file),
          _buildStatusItem('总大小', _formatFileSize(totalSize), Icons.storage),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.folder_off_outlined : Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            _searchQuery.isEmpty ? '此目录为空' : '未找到匹配的文件',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFileTap(FileItem file) {
    if (file.type == FileType.folder) {
      final newPath = _currentPath == '/'
          ? '/${file.name}'
          : '$_currentPath/${file.name}';
      _navigateToPath(newPath);
    } else {
      // TODO: 打开文件
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('打开 ${file.name}')));
    }
  }

  void _navigateToPath(String path) {
    setState(() {
      if (path == _currentPath) return;

      // 如果是返回上级目录
      if (!path.contains(_currentPath) && _pathHistory.length > 1) {
        _pathHistory.removeLast();
      } else {
        _pathHistory.add(path);
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static List<FileItem> _generateMockFiles() {
    final now = DateTime.now();
    return [
      FileItem(
        name: 'Documents',
        type: FileType.folder,
        size: 0,
        modifiedAt: now,
        path: '/Documents',
      ),
      FileItem(
        name: 'Images',
        type: FileType.folder,
        size: 0,
        modifiedAt: now,
        path: '/Images',
      ),
      FileItem(
        name: 'Projects',
        type: FileType.folder,
        size: 0,
        modifiedAt: now,
        path: '/Projects',
      ),
      FileItem(
        name: 'readme.md',
        type: FileType.document,
        size: 2048,
        modifiedAt: now.subtract(const Duration(days: 1)),
        path: '/readme.md',
      ),
      FileItem(
        name: 'config.json',
        type: FileType.code,
        size: 1024,
        modifiedAt: now.subtract(const Duration(hours: 3)),
        path: '/config.json',
      ),
      FileItem(
        name: 'screenshot.png',
        type: FileType.image,
        size: 512 * 1024,
        modifiedAt: now.subtract(const Duration(hours: 6)),
        path: '/screenshot.png',
      ),
      FileItem(
        name: 'backup.zip',
        type: FileType.archive,
        size: 10 * 1024 * 1024,
        modifiedAt: now.subtract(const Duration(days: 2)),
        path: '/backup.zip',
      ),
    ];
  }
}
