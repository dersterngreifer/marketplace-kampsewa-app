import 'package:project_camp_sewa/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/components/buttionanimation/swiperight.dart';
import 'package:project_camp_sewa/screens/screen_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class KontenOnboarding {
  final String title;
  final String deskripsi;
  final String image;
  KontenOnboarding(
      {required this.title, required this.deskripsi, required this.image});
}

class OnboardingItems {
  List<KontenOnboarding> items = [
    KontenOnboarding(
        title: "Temukan Peralatan",
        deskripsi:
            "Pilih peralatan yang anda inginkan sebelum memulai petualangan yang menyenangkan. ",
        image: "assets/images/onboarding-img1.jpg"),
    KontenOnboarding(
        title: "Sesuaikan Kebutuhan",
        deskripsi:
            "Pilih peralatan yang sesuai dengan kebutuhan anda Selama berpetualang dialam bebas. ",
        image: "assets/images/onboarding-img2.jpg"),
    KontenOnboarding(
        title: "Pergi Berpetualang",
        deskripsi:
            "Berpetualan dengan perlatan yang memadai dan menikmati petualangan tanpa batas.",
        image: "assets/images/onboarding-img3.jpg")
  ];
}

class OnboardLayout extends StatefulWidget {
  const OnboardLayout({super.key});

  @override
  State<OnboardLayout> createState() => _OnboardLayoutState();
}

class _OnboardLayoutState extends State<OnboardLayout>
    with TickerProviderStateMixin {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  late AnimationController _textAnimController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Badges removed as requested

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ));

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeOut,
    ));
    _textAnimController.forward();
  }

  @override
  void dispose() {
    _textAnimController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      isLastPage = controller.items.length - 1 == index;
    });
    _textAnimController.reset();
    _textAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
              onPageChanged: _onPageChanged,
              itemCount: controller.items.length,
              controller: pageController,
              itemBuilder: (context, index) {
                return Container(
              decoration: const BoxDecoration(color: Colors.white),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage(controller.items[index].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.5,
                        ),
                      ),
                      // Gradient overlay: bottom fade ke putih
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.55, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top dark gradient untuk status bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Page counter chip
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${index + 1} / ${controller.items.length}',
                            style: AppColors.fontStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge chip removed
                            Text(
                              controller.items[index].title,
                              style: AppColors.fontStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2F2828),
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            // Accent divider
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.mainColor,
                                    AppColors.mainColor.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              controller.items[index].deskripsi,
                              style: AppColors.fontStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 10
            : 20,
      ),
      child: isLastPage
          ? getStarted()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () =>
                      pageController.jumpToPage(controller.items.length - 1),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey.shade100,
                  ),
                  child: Text(
                    'Skip',
                    style: AppColors.fontStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                //Indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index) => pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn),
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.mainColor,
                      dotColor: Colors.black12,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Next',
                        style: AppColors.fontStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.navigate_next_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget getStarted() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width * .9,
        height: 60,
        child: ButtonSwipeRight(
          title: "Mulai Sekarang!",
          bgColor: Colors.black,
          fungsi: () async {
            final pres = await SharedPreferences.getInstance();
            pres.setBool("onboarding", true);

            //After we press get started button this onboarding value become true
            // same key
            if (!mounted) return;
            // Navigator.pushReplacement(
            //     context,
            //     PageTransition(
            //         type: PageTransitionType.fade, child: const LoginScreen()));
            Get.off(const LoginScreen(),
                transition: Transition.fade,
                duration: const Duration(milliseconds: 500));
          },
        ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Mulai dari kiri atas ke kiri bawah (sebelum melengkung)
    path.lineTo(0, size.height - 80);

    // Gelombang pertama (turun)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Gelombang kedua (naik)
    var secondControlPoint = Offset(size.width * 0.75, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Tarik garis ke kanan atas lalu tutup path
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Metode ini digunakan untuk menentukan apakah path perlu dipotong ulang
    // Di sini, kita mengembalikan false karena path tidak perlu diubah.
    return true;
  }
}
