import 'package:example/home/model/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:lj_flutter_package/ui_component/lj_radio_title_bar.dart';
import 'package:lj_flutter_package/ui_component/lj_swiper.dart';
import 'package:lj_flutter_package/ui_component/lj_tile_area_view.dart';

import '../gen_a/A.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class ImageModel {
  String imageUrl;
  String contentUrl;

  ImageModel(this.imageUrl, this.contentUrl);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<ImageModel> imageList = [
    ImageModel(
        'https://img1.baidu.com/it/u=2093859625,3420507245&fm=253&fmt=auto&app=138&f=JPEG?w=649&h=437',
        'https:www.baidu.com'),
    ImageModel(
        'https://img2.baidu.com/it/u=3157650194,2969546188&fm=253&fmt=auto&app=120&f=JPEG?w=650&h=433',
        '''<span>这是一段HTML文本</span>'''),
    ImageModel(
        'https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com'
            '%2Fimages%2F20180920%2Fccc39d430a574d198d404608489419c0.jpeg'
            '&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com'
            '&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto'
            '?sec=1662275947&t=0a1c0fc072daf1a5356982789489de9f',
        'https:www.baidu.com'),
    ImageModel(
        'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.zcyy8.com'
            '%2Fuploadimg%2Fimage%2F20211104%2F20211104134820_29104.jpg'
            '&refer=http%3A%2F%2Fimg.zcyy8.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto'
            '?sec=1662275946&t=2fdece60028eb53f165f7a90a0370cad',
        'https:www.baidu.com'),
    ImageModel(
        'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-7.vcimg.com'
            '%2Ftrim%2F0ac056a1f8d11ca085769c49e41523651497503%2Ftrim.jpg&refer=http%3A%2F%2Fi-7.vcimg.com'
            '&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto'
            '?sec=1662275946&t=14ecf3f816e25b9561578e74bc53c8e7',
        'https:www.baidu.com'),
  ];

  final String _city = '石家庄';
  WeatherResult? _weatherResult;

  final List<String> _tileTitles = [
    '时令生鲜',
    '冲调速食',
    '个人洗护',
    '贵州茅台',
    '小时购',
    '沃尔玛',
    '小家电馆',
    '营养保健',
    '山姆会员店',
    '全部分类',
  ];
  final List<String> _tileImages = [
    A.assets_images_shilingshegnxian,
    A.assets_images_chongtiaosuchi,
    A.assets_images_gerenxihu,
    A.assets_images_guizhoumaotai,
    A.assets_images_xiaoshigou,
    'https://m.360buyimg.com/babel/jfs/t1/148375/36/22621/6938/621cd5f9E123bbc00/4f8cdc851593efc1.png!q70.webp',
    'https://m.360buyimg.com/babel/jfs/t1/90199/34/22168/17342/621ce16fEcc9cc02a/007ae51ef1dba418.png!q70.webp',
    'https://m.360buyimg.com/babel/jfs/t1/137278/18/22836/23014/621ce143Ee9b4d697/5c3010332a69e923.png!q70.webp',
    'https://m.360buyimg.com/babel/jfs/t1/213932/11/13689/8697/621cd5b3E1c8af2bd/9480d2409812dcb9.png!q70.webp',
    'https://m.360buyimg.com/babel/jfs/t1/116992/11/20508/7101/621ce160Ee2dfa475/2186f688e463920f.png!q70.webp',
  ];

  @override
  void initState() {
    _fetchWeather();

    super.initState();
  }

  _fetchWeather() {
    EasyLoading.show();
    LJNetwork.post<WeatherModel>('/simpleWeather/query', params: {
      'key': 'f359141d6b74e818a1bfc813b0e3fcb6',
      'city': _city,
    }, successCallback: (WeatherModel model) {
      EasyLoading.showSuccess(model.reason ?? '请求成功');
      print(model);
      setState(() {
        _weatherResult = model.result;
      });
    }, failureCallback: (error) {
      print(error);
      EasyLoading.showSuccess(error.errorMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: quickText(
          '$_city   ${_weatherResult?.realtime?.info ?? ''} ${_weatherResult?.realtime?.temperature ?? ''}℃',
          18,
          Colors.white,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            LJSwiper<ImageModel>(
              viewModels: imageList,
              fit: BoxFit.fitWidth,
              backgroundColor: Colors.black,
              pagination: const LJSwiperDotPagination(
                // width: 10,
                activeWidth: 20,
                // height: 10,
                // activeHeight: 20,
                color: Colors.orange,
                activeColor: Colors.blue,
              ),
              // pagination: LJSwiperTextPagination(),
              // loop: false,
              // autoplay: false,
              getImgUrl: (ImageModel model) {
                return model.imageUrl;
              },
              onTap: (model) {

              },
            ),
            LJTileAreaView(
              count: _tileImages.length,
              crossAxisCount: 5,
              itemHeight: 100,
              imageSize: 60,
              getImageUrl: (index) => _tileImages[index],
              getTitle: (index) => _tileTitles[index],
              clickCallback: (index) {},
            ),
            const SizedBox(height: 10),
            LJRadioTitleBar(
              count: 10,
              color: Colors.grey,
              selectedColor: Colors.red,
              fontColor: Colors.black,
              selectedFontColor: Colors.white,
              getTitle: (index) => '标题$index',
              selectedTap: (index) {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
