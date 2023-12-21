import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/screens/cart/cart_screen.dart';
import 'package:timberr/screens/search_delegate/product_search_delegate.dart';
import 'package:timberr/widgets/tabbed/bottom_navbar.dart';
import 'package:timberr/widgets/tabbed/category_tab_bar.dart';
import 'package:timberr/widgets/tiles/product_grid_tile.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  final HomeController _controller = Get.find();
  void _onCartTap() {
    Get.to(
      () => CartScreen(),
      transition: Transition.fade,
    );
  }
// Widget build(BuildContext context) {
//   return Scaffold(
//     bottomNavigationBar: const BottomNavBar(
//       selectedPos: 0,
//     ),
//     body: WillPopScope(
//       onWillPop: () async {
//         bool shouldPop = await kOnExitConfirmation();
//         return shouldPop;
//       },
//       child: CustomScrollView(
//         // ... rest of your code
//       ),
//     ),
//   );
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(
        selectedPos: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                showSearch(context: context, delegate: ProductSearchDelegate());
              },
              icon: SvgPicture.asset(
                'assets/icons/search_icon.svg',
                color: kGrey,
              ),
            ),
            title: Column(
              children: [
                Text(
                  'Make home',
                  style: kGelasio18.copyWith(
                    color: kTinGrey,
                  ),
                ),
                Text(
                  'BEAUTIFUL',
                  style: kGelasio18.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kOffBlack,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _onCartTap,
                icon: SvgPicture.asset(
                  'assets/icons/cart_icon.svg',
                  color: kGrey,
                ),
              )
            ],
            bottom: CategoryTabBar(),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: Obx(() {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 18,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductGridTile(
                      product: _controller.productsList.elementAt(index),
                    );
                  },
                  childCount: _controller.productsList.length,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
