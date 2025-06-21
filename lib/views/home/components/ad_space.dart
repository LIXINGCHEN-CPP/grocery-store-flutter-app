import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class AdVideoItem {
  final String url;
  final String title;

  const AdVideoItem({required this.url, required this.title});
}

class AdSpace extends StatefulWidget {
  const AdSpace({super.key});

  @override
  State<AdSpace> createState() => _AdSpaceState();
}

class _AdSpaceState extends State<AdSpace> {
  // 广告视频列表
  final List<AdVideoItem> adVideoItems = const [
    AdVideoItem(
      url: 'https://files.catbox.moe/39ibcz.mp4',
      title: '苹果',
    ),
    AdVideoItem(
      url: 'https://files.catbox.moe/fb061r.mp4',
      title: '果蔬',
    ),
    AdVideoItem(
      url: 'https://files.catbox.moe/e2q68t.mp4',
      title: '水果',
    ),
    AdVideoItem(
      url: 'https://files.catbox.moe/e8e4dc.mp4',
      title: '果盘',
    ),
    AdVideoItem(
      url: 'https://files.catbox.moe/e2q68t.mp4',
      title: '大杂烩',
    ),
  ];

  int _currentIndex = 0;
  List<VideoPlayerController?> _controllers = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // 初始化所有视频控制器
    _controllers = List.generate(adVideoItems.length, (index) => null);

    // 先初始化第一个视频
    await _initializeControllerAtIndex(0);

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (_controllers[index] == null) {
      final controller = VideoPlayerController.network(adVideoItems[index].url);
      _controllers[index] = controller;
      await controller.initialize();
      controller.setLooping(true);
      if (index == _currentIndex) {
        controller.play();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 屏幕可用宽度
    final screenWidth = MediaQuery.of(context).size.width;

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: SizedBox(
        width: screenWidth,
        // 保证宽高比 16:9
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CarouselSlider.builder(
            itemCount: adVideoItems.length,
            itemBuilder: (context, index, realIdx) {
              // 预加载下一个视频
              if (index == _currentIndex + 1 ||
                  (index == 0 && _currentIndex == adVideoItems.length - 1)) {
                _initializeControllerAtIndex(index);
              }

              final controller = _controllers[index];
              if (controller == null || !controller.value.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayer(controller),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          adVideoItems[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              // 视口占满整个 AspectRatio 区域
              viewportFraction: 1.0,
              // 自动播放
              autoPlay: true,
              // 中心放大，去掉也行，按需设
              enlargeCenterPage: true,
              // 不再使用 aspectRatio 参数，外层 AspectRatio 已固定大小
              // aspectRatio: 16/9,

              // 每隔 10 秒切换一次，视频播放时间更长
              autoPlayInterval: const Duration(seconds: 10),
              // 滑动动画持续 800 毫秒
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              // 动画曲线（可选）
              autoPlayCurve: Curves.easeInOut,

              // 页面变化时的回调
              onPageChanged: (index, reason) {
                setState(() {
                  // 暂停当前视频
                  _controllers[_currentIndex]?.pause();
                  // 更新当前索引
                  _currentIndex = index;
                  // 播放新的视频
                  _controllers[index]?.play();
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
