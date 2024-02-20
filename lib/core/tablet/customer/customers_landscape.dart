import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../database/db_utils/db_customer.dart';
import '../../../../../database/models/customer.dart';
import '../../../../../utils/ui_utils/spacer_widget.dart';
import '../../../../../widgets/customer_tile.dart';
import '../../../../../widgets/shimmer_widget.dart';
import '../../../network/api_helper/comman_response.dart';
import '../../../utils/helper.dart';
import '../../service/login/api/verify_instance_service.dart';
import '../widget/title_search_bar.dart';

class CustomersLandscape extends StatefulWidget {
  const CustomersLandscape({Key? key}) : super(key: key);

  @override
  State<CustomersLandscape> createState() => _CustomersLandscapeState();
}

class _CustomersLandscapeState extends State<CustomersLandscape> {
  late TextEditingController searchCtrl;
  List<Customer> customers = [];
  bool isCustomersFound = true;

  @override
  void initState() {   
    searchCtrl = TextEditingController();
    super.initState();
    getCustomersFromDB(0);
  }

  Future<void> getCustomersFromDB(val) async {
    //Fetch the data from local database
    customers = await DbCustomer().getCustomers();
    isCustomersFound = customers.isNotEmpty;
    if (val == 0) setState(() {});
  }
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // color: const Color(0xFFF9F8FB),
      // padding: paddingXY(),
      child:GestureDetector (onTap: _handleTap,child:Column(
        children: [
          TitleAndSearchBar(
            title: "Customers",
            keyboardType: TextInputType.number,
            onSubmit: (text) {
              if (text.isNotEmpty) {
                filterCustomerData(text);
              } else {
                getCustomersFromDB(0);
              }
            },
            onTextChanged: (text) {
              if (text.isNotEmpty) {
                filterCustomerData(text);
              } else {
                getCustomersFromDB(0);
              }
            },
            searchCtrl: searchCtrl,
            searchHint: "Enter customer mobile number",
          ),
          hightSpacer20,
          isCustomersFound
              ? customerGrid()
              : const Center(
                  child: Text("No Customer found!!!"),
                ),
        ],
      ),
    ));
  }

  Widget customerGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 15, 15),
      child: GridView.builder(
        itemCount: customers.isEmpty ? 10 : customers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 5, //6.5
        ),
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (context, position) {
          if (customers.isEmpty) {
            return const ShimmerWidget();
          } else {
            return CustomerTile(
              isCheckBoxEnabled: false,
              isDeleteButtonEnabled: false,
              customer: customers[position],
              isSubtitle: true,
            );
          }
        },
      ),
    );
  }

  void filterCustomerData(String searchText) async {
    await getCustomersFromDB(1);
    customers = customers
        .where((element) =>
            //element.name.toLowerCase().contains(searchText.toLowerCase()) ||
            element.phone.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    isCustomersFound = customers.isNotEmpty;

    if (!isCustomersFound) {
      // CommanResponse response =
      //     await CustomerService().getCustomers(searchTxt: searchText);
    }

    setState(() {});
  }
  // verify() async {
  //   CommanResponse res = await VerificationUrl.checkAppStatus();
  //   if (res.message == true) {
  //   } else {
  //     Helper.showPopup(context, "Please update your app to latest version",
  //         barrierDismissible: true);
  //   }
  // }
}
