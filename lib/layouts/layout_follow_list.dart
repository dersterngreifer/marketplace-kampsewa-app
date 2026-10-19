import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/models/follow_model.dart';
import 'package:project_camp_sewa/services/api_follow.dart';
import 'package:project_camp_sewa/services/api_data_user.dart';
import 'package:project_camp_sewa/theme_colors.dart';
import 'package:project_camp_sewa/layouts/layout_public_store_profile.dart';
import 'package:shimmer/shimmer.dart';

/// Tipe daftar yang ditampilkan: Followers atau Following.
enum FollowListType { followers, following }

/// Opsi sorting daftar: Terbaru atau Terlama.
enum FollowSortOption { terbaru, terlama }

class LayoutFollowList extends StatefulWidget {
  /// ID user yang daftar followers/following-nya ingin dilihat.
  final int idUser;
  final FollowListType type;

  const LayoutFollowList({
    super.key,
    required this.idUser,
    required this.type,
  });

  @override
  State<LayoutFollowList> createState() => _LayoutFollowListState();
}

class _LayoutFollowListState extends State<LayoutFollowList> {
  final ApiFollow _apiFollow = Get.put(ApiFollow());

  bool _isLoading = true;
  String? _errorMessage;
  List<FollowUserModel> _rawList = [];
  List<FollowUserModel> _list = [];
  FollowSortOption _sortOption = FollowSortOption.terbaru;

  /// ID user yang sedang login, dipakai untuk fitur label "Anda".
  int? get _currentUserId =>
      Get.isRegistered<ApiDataUser>()
          ? Get.find<ApiDataUser>().dataUser.value?.id
          : null;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = widget.type == FollowListType.followers
        ? await _apiFollow.getFollowers(widget.idUser)
        : await _apiFollow.getFollowing(widget.idUser);

    if (!mounted) return;

    setState(() {
      _rawList = List.from(result.data);
      _errorMessage = result.errorMessage;
      _isLoading = false;
      _applySorting();
    });
  }

  /// Menerapkan sorting berdasarkan opsi yang dipilih (_sortOption).
  void _applySorting() {
    List<FollowUserModel> sorted = List.from(_rawList);

    sorted.sort((a, b) {
      final DateTime dateA =
          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime dateB =
          b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (_sortOption == FollowSortOption.terbaru) {
        final cmp = dateB.compareTo(dateA);
        return cmp != 0 ? cmp : b.id.compareTo(a.id);
      } else {
        final cmp = dateA.compareTo(dateB);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      }
    });

    // Sorting: akun "Anda" diletakkan paling atas jika ada
    final currentId = _currentUserId;
    if (currentId != null) {
      final myIndex = sorted.indexWhere((u) => u.id == currentId);
      if (myIndex > 0) {
        final me = sorted.removeAt(myIndex);
        sorted.insert(0, me);
      }
    }

    _list = sorted;
  }

  /// Toggle follow/unfollow untuk item tertentu di dalam list.
  Future<void> _toggleFollow(int index) async {
    final item = _list[index];
    final bool willFollow = !item.isFollowedByMe;

    // Optimistic UI update
    setState(() {
      _list[index] = item.copyWith(isFollowedByMe: willFollow);
      final rawIndex = _rawList.indexWhere((u) => u.id == item.id);
      if (rawIndex != -1) {
        _rawList[rawIndex] =
            _rawList[rawIndex].copyWith(isFollowedByMe: willFollow);
      }
    });

    final result = willFollow
        ? await _apiFollow.followUser(item.id)
        : await _apiFollow.unfollowUser(item.id);

    if (!result.success) {
      // Rollback jika gagal
      if (mounted) {
        setState(() {
          _list[index] = item.copyWith(isFollowedByMe: !willFollow);
          final rawIndex = _rawList.indexWhere((u) => u.id == item.id);
          if (rawIndex != -1) {
            _rawList[rawIndex] =
                _rawList[rawIndex].copyWith(isFollowedByMe: !willFollow);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Terjadi kesalahan.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  String _formatFollowTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
  }

  Widget _buildFilterBar(String title) {
    final newCount = _list.where((u) => u.isNew).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                '${_list.length} $title',
                style: AppColors.fontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
              if (newCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$newCount baru',
                    style: AppColors.fontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortChip(FollowSortOption.terbaru, 'Terbaru'),
                const SizedBox(width: 4),
                _buildSortChip(FollowSortOption.terlama, 'Terlama'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(FollowSortOption option, String label) {
    final bool isSelected = _sortOption == option;
    return GestureDetector(
      onTap: () {
        if (_sortOption != option) {
          setState(() {
            _sortOption = option;
            _applySorting();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option == FollowSortOption.terbaru
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 12,
              color: isSelected ? AppColors.mainColor : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppColors.fontStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.mainColor
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.type == FollowListType.followers
        ? 'Followers'
        : 'Following';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1E1E1E)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            title,
            style: AppColors.fontStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? _buildShimmer()
            : _errorMessage != null && _list.isEmpty
                ? _buildError()
                : _list.isEmpty
                    ? _buildEmpty(title)
                    : Column(
                        children: [
                          _buildFilterBar(title),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.mainColor,
                              onRefresh: _fetchData,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                itemCount: _list.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    _buildUserTile(index),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildUserTile(int index) {
    final FollowUserModel user = _list[index];
    final bool isMe = user.id == _currentUserId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi ke profil publik akun tersebut
          Get.to(
            () => LayoutPublicStoreProfile(
              idUser: user.id,
              initialStoreName: user.name,
              initialStoreLogo: user.avatar,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────────────────────
              Stack(
                children: [
                  ClipOval(
                    child: user.avatar.isNotEmpty
                        ? Image.network(
                            user.avatar,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarFallback(user.name, 50),
                          )
                        : _buildAvatarFallback(user.name, 50),
                  ),
                  // Badge "Anda"
                  if (isMe)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          'Anda',
                          style: AppColors.fontStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // ── Nama & Status Baru ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: AppColors.fontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E1E1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isNew) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Baru',
                                  style: AppColors.fontStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (user.createdAt != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatFollowTime(user.createdAt!),
                        style: AppColors.fontStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Tombol Follow / Mengikuti (tidak tampil untuk akun sendiri) ──
              if (!isMe)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: user.isFollowedByMe
                      ? OutlinedButton(
                          key: const ValueKey('unfollow'),
                          onPressed: () => _toggleFollow(index),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mainColor,
                            side: const BorderSide(
                                color: AppColors.mainColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Mengikuti',
                            style: AppColors.fontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          key: const ValueKey('follow'),
                          onPressed: () => _toggleFollow(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Ikuti',
                            style: AppColors.fontStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name, double size) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      color: AppColors.mainColor.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: AppColors.mainColor,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada $type.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Gagal memuat data.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
