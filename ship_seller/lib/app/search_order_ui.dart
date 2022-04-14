import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/home_networking.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/models/order.dart';
import 'package:ship_seller/utils/widgets.dart';

class SearchOrderUI extends StatefulWidget {
  const SearchOrderUI({Key? key}) : super(key: key);

  @override
  State<SearchOrderUI> createState() => _SearchOrderUIState();
}

class _SearchOrderUIState extends State<SearchOrderUI> {

  late TextEditingController searchTextEditingController;


  @override
  void initState() {
    super.initState();

    searchTextEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          searchBox(),
          searchButton()
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      child: Center(
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: EdgeInsets.only(bottom: 4, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 2),
                  color: Color(yellow).withOpacity(0.2),
                  blurRadius: 5)
            ],
            borderRadius: BorderRadius.circular(8),),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  expands: false,
                  controller: searchTextEditingController,
                  cursorColor: Color(yellow),
                  style: TextStyle(color: Color(yellow), fontSize: 16),
                  decoration: InputDecoration(
                      hintText: 'Search by order id',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color(black).withAlpha(100), fontSize: 16)),
                  maxLines: 1,
                  onFieldSubmitted: (value){
                    //TODO: to search for the order
                    search();
                  },
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.search,
                  color: Color(blue),
                  size: 24,
                ),
                onTap: (){
                  //TODO: to search for the order
                  search();
                },)
            ],
          ),
        ),
      ),
    );
  }

  Widget searchButton(){
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(blue),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 5),
                  color: Color(blue).withOpacity(0.3),
                  blurRadius: 10)
            ]),
        child: FittedBox(child: Text(
          'Search',
          style: TextStyle(color: Color(white), fontSize: 16),
        ),),
      ),
      onTap: search,
    );
  }

  Future<void> search() async {
    if(searchTextEditingController.text.isEmpty){
      return;
    }
    loadingWidget('Please wait...');
    HomeNetworking().searchOrder(searchTextEditingController.text).then((res){
      Get.back();

      try{
        if(res == 0){
          alertBox('Oops!', 'Order ID not found!');
        }else if(res == 1){
          alertBox('Error', 'Something went wrong!');
        }else{
          Order order = HomeController().createOrder(res.data['data']);
          Get.to(SingleOrderUI(order: order));
        }
      }catch(e){
        alertBox('Error', 'Something went wrong!');
      }
    });
  }
}
