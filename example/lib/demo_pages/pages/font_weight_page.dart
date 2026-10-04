import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class FontWeightPage extends StatelessWidget {
  const FontWeightPage({super.key});

  // w100 ~ w900，每 50 一档（含 150/250/.../850 中间值），
  // 用于观察 Flutter 对非整百字重的合成/匹配效果。
  static const List<int> _weights = [
    100, 150, 200, 250, 300, 350, 400, 450, //
    500, 550, 600, 650, 700, 750, 800, 850, 900,
  ];

  // 设计档（整百）-> 包内平台适配后的字重（iOS 上为补偿值，其他平台为标准值）。
  // 中间值（150/250/...）没有定义设计档，不展示补偿行。
  FontWeight _compensated(int design) {
    switch (design) {
      case 100:
        return ultralight;
      case 200:
        return thin;
      case 300:
        return light;
      case 400:
        return regular;
      case 500:
        return medium;
      case 600:
        return semibold;
      case 700:
        return bold;
      default:
        return FontWeight(design);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('字重'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FlutterOnlyWeightPage(),
                ),
              );
            },
            child: const Text('仅Flutter'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _weights.map(_buildWeightItem).toList(),
        ),
      ),
    );
  }

  Widget _buildWeightItem(int weight) {
    final FontWeight compensated = _compensated(weight);
    final bool isDesignStep = weight % 100 == 0;
    final bool sameAsRaw = compensated.value == weight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'w$weight',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'Flutter 字重 Font Weight',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight(weight)),
          ),
          // 仅设计档（整百）有平台适配；中间值无对应映射
          if (isDesignStep) ...[
            const SizedBox(height: 4),
            Text(
              sameAsRaw
                  ? 'iOS 补偿后：w${compensated.value}（与原始相同，未补偿）'
                  : 'iOS 补偿后：w${compensated.value}',
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
            Text(
              'Flutter 字重 Font Weight',
              style: TextStyle(fontSize: 22, fontWeight: compensated),
            ),
            const SizedBox(height: 4),
            const Text(
              'iOS 原生效果（原生 App 中同字号 22pt 的真实显示，基准）：',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // 图片由原生工程以 @3x 离屏渲染导出（FontWeightCompareApp
            // 的 -exportWeights 模式）。9 张统一画布（宽=最宽一行文字，
            // 约 258pt，与机型无关），同排版原点左缘对齐；scale:3 按
            // 22pt 原字号显示，浅边框标示统一画布宽度。
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Image.asset(
                'assets/weights/w$weight.png',
                scale: 3,
                width: 295,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

// 仅展示 Flutter 原始字重（w100~w900，每 50 一档），不含补偿行与原生对比图
class FlutterOnlyWeightPage extends StatelessWidget {
  const FlutterOnlyWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 字重')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: FontWeightPage._weights
              .map(
                (weight) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Flutter 字重 Font Weight',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight(weight),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'w$weight',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
