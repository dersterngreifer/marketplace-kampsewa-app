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
  List<FollowUserModel> _list = [];

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

    List<FollowUserModel> sorted = List.from(result.data);

    // Sorting: akun "Anda" diletakkan paling atas
    final currentId = _currentUserId;
    if (currentId != null) {
      final myIndex = sorted.indexWhere((u) => u.id == currentId);
      if (myIndex > 0) {
        final me = sorted.removeAt(myIndex);
        sorted.insert(0, me);
      }
    }

    setState(() {
      _list = sorted;
      _errorMessage = result.errorMessage;
      _isLoading = false;
    });
  }

  /// Toggle follow/unfollow untuk item tertentu di dalam list.
  Future<void> _toggleFollow(int index) async {
    final item = _list[index];
    final bool willFollow = !item.isFollowedByMe;

    // Optimistic UI update
    setState(() {
      _list[index] = item.copyWith(isFollowedByMe: willFollow);
    });

    final result = willFollow
        ? await _apiFollow.followUser(item.id)
        : await _apiFollow.unfollowUser(item.id);

    if (!result.success) {
      // Rollback jika gagal
      if (mounted) {
        setState(() {
          _list[index] = item.copyWith(isFollowedByMe: !willFollow);
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
                    : RefreshIndicator(
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

              // ── Nama ────────────────────────────────────────────────────
              Expanded(
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
