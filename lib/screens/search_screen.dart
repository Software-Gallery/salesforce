import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/barang_promo_item_card_widget.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/screens/barang_details_screen.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

List<Color> gridColors = [
  Color(0xff53B175),
  Color(0xffF8A44C),
  Color(0xffF7A593),
  Color(0xffD3B0E0),
  Color(0xffFDE598),
  Color(0xffB7DFF5),
  Color(0xff836AF6),
  Color(0xffD73B77),
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchApproveController = TextEditingController();
  late FocusNode _focusNodeSearch;
  bool isSearch = false;   
  bool isItemLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });
    _focusNodeSearch.requestFocus();
  }   

  @override
  Widget build(BuildContext context) {

    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.only(
                        right: AppConfig.appSize(context, .01),
                        bottom: AppConfig.appSize(context, .01),
                        top: AppConfig.appSize(context, .01)
                      ),                      
                      color: Colors.transparent,
                      child: InkWell(child: FaIcon(FontAwesomeIcons.arrowLeft, size: AppConfig.appSize(context, .018),))
                    ),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(width: AppConfig.appSize(context, .016),),
                  Flexible(
                    // width: MediaQuery.of(context).size.width *.5,
                    child: Hero(
                      tag: "search_field",
                      child: TextFormField(
                        onFieldSubmitted: (value) async {
                          setState(() {
                            isItemLoad = true;
                            isSearch = true;
                          });
                          // barangProvider.searchLoaded(true);
                          barangProvider.itemSearchLists = [];
                          await barangProvider.produkSearchPopulateFromApi(_searchApproveController.text);
                          setState(() {
                            isItemLoad = false;
                          });
                          // barangProvider.searchLoaded(false);
                        },
                        onTapOutside: (event) {
                          _focusNodeSearch.unfocus();
                        },
                        textInputAction: TextInputAction.search,
                        controller: _searchApproveController,
                        focusNode: _focusNodeSearch,
                        decoration: InputDecoration(
                          suffix: GestureDetector(
                            onTap: () {
                            // Clear search and reset state when the suffix icon (X mark) is clicked
                            _searchApproveController.clear();
                            setState(() {
                              isSearch = false;
                            });
                          },
                            child: FaIcon(FontAwesomeIcons.xmark, color: AppColors.darkGrey,size: 20,),
                          ),
                          filled: !_focusNodeSearch.hasFocus,
                          fillColor: Colors.grey.shade200,
                          hintText: 'Cari produk',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400),
                          focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                          
                          borderSide: _focusNodeSearch.hasFocus
                              ? BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                )
                              : BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                          borderSide: _focusNodeSearch.hasFocus
                              ? BorderSide(
                                  color: const Color.fromARGB(255, 54, 45, 45),
                                  width: 2.0,
                                )
                              : BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // isSearch ?
              // barangProvider.itemSearchLists == [] 
              // ? Center(child: CircularProgressIndicator(),)
              // : 
              Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10
                    ),
                    child: 
                    SkeletonLoader(
                      isLoading: isItemLoad, 
                      skeleton: 
                      Skeletonizer(
                        effect: ShimmerEffect(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          duration: Duration(milliseconds: 1200),
                        ),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          // I only need two card horizontally
                          children: barangList.asMap().entries.map<Widget>((e) {
                            BarangItem groceryItem = e.value;
                            return Container(
                              padding: EdgeInsets.all(4),
                              child: Skeleton.leaf(
                                child: Card(
                                  child: BarangPromoItemCardWidget(
                                    item: groceryItem,
                                    heroSuffix: "search_screen",
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          mainAxisSpacing: 3.0,
                          crossAxisSpacing: 0.0, // add some space
                        ),
                      ),
                      child: 
                      barangProvider.itemSearchLists.length <= 0
                      ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: AppConfig.appSize(context, .1),
                            ),
                            Text(
                              'Item tidak tersedia',
                              style: TextStyle(fontSize: AppConfig.appSize(context, .013), fontWeight: FontWeight.bold, color: AppColors.darkGrey),
                            ),
                          ],
                        ),
                      )
                      : StaggeredGrid.count(
                        crossAxisCount: 2,
                        // I only need two card horizontally
                        children: barangProvider.itemSearchLists.asMap().entries.map<Widget>((e) {
                          BarangItem groceryItem = e.value;
                          return GestureDetector(
                            onTap: () {
                              onItemClicked(context, groceryItem);  
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: BarangPromoItemCardWidget(
                                item: groceryItem,
                                heroSuffix: "search_screen",
                              ),
                            ),
                          );
                        }).toList(),
                        mainAxisSpacing: 3.0,
                        crossAxisSpacing: 0.0, // add some space
                      ),
                ),
              )
            )
            // : Expanded(
            //   child: getStaggeredGridView(context, categoriesList),
            // ),
          ],
        ),
      ));
    });
  }

  void onItemClicked(BuildContext context, BarangItem barangItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarangDetailsScreen(
          barangItem,
          false,
          heroSuffix: "explore_screen",
        ),
      ),
    );
  }

  // Widget getStaggeredGridView(BuildContext context, List<CategoryItem> categoryItem) {
  //   return SingleChildScrollView(
  //     padding: EdgeInsets.symmetric(
  //       vertical: 10,
  //       horizontal: 10
  //     ),
  //     child: StaggeredGrid.count(
  //       crossAxisCount: 2,
  //       children: categoryItem.asMap().entries.map<Widget>((e) {
  //         int index = e.key;
  //         CategoryItem categoryItem = e.value;
  //         return GestureDetector(
  //           onTap: () {
  //             onCategoryItemClicked(context, categoryItem);
  //           },
  //           child: Container(
  //             padding: EdgeInsets.all(10),
  //             child: CategoryItemCardWidget(
  //               item: categoryItem,
  //               color: gridColors[index % gridColors.length],
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //       mainAxisSpacing: 3.0,
  //       crossAxisSpacing: 4.0, // add some space
  //     ),
  //   );
  // }
}
