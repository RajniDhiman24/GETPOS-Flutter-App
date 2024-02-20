//import 'dart:html';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_posx/configs/theme_dynamic_colors.dart';

import 'package:nb_posx/database/db_utils/db_customer.dart';
import 'package:nb_posx/database/db_utils/db_instance_url.dart';
import 'package:nb_posx/database/db_utils/db_preferences.dart';
import 'package:nb_posx/database/models/sale_order.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../constants/asset_paths.dart';

import '../../../../../database/db_utils/db_hub_manager.dart';
import '../../../../../database/db_utils/db_sale_order.dart';
import '../../../../../database/models/hub_manager.dart';
import '../../../../../utils/helper.dart';
import '../../../../../utils/helpers/sync_helper.dart';
import '../../../../../utils/ui_utils/padding_margin.dart';
import '../../../../../utils/ui_utils/spacer_widget.dart';
import '../../../../../utils/ui_utils/text_styles/custom_text_style.dart';
import '../../../../../utils/ui_utils/text_styles/edit_text_hint_style.dart';
import '../../../../../widgets/custom_appbar.dart';
import '../../../../configs/local_notification_service.dart';
import '../../change_password/ui/change_password.dart';
import '../../login/ui/login.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String? name, email, phone, version;
  bool syncNowActive = true;
  bool internetAvailable = true;
  late Uint8List profilePic;
  SaleOrder? offlineOrderPlaced;
  @override
  void initState() {
    super.initState();
    checkNetworkAvailable();
    profilePic = Uint8List.fromList([]);
    getManagerName();
  }

  ///Function to fetch the hub manager account details
  getManagerName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    //Fetching the data from database
    HubManager manager = await DbHubManager().getManager() as HubManager;

    name = manager.name;
    email = manager.emailId;
    phone = manager.phone;
    version = "$APP_VERSION - ${packageInfo.version}";
    profilePic = manager.profileImage;
    setState(() {});
  }

  Widget _actionListItem(imageAsset, label) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                MY_ACCOUNT_ICON_PADDING_LEFT,
                MY_ACCOUNT_ICON_PADDING_TOP,
                MY_ACCOUNT_ICON_PADDING_RIGHT,
                MY_ACCOUNT_ICON_PADDING_BOTTOM),
            child: SvgPicture.asset(
              imageAsset,
              width: MY_ACCOUNT_ICON_WIDTH,
            ),
          ),
          Text(
            label,
            style: getBoldStyle(),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // endDrawer: MainDrawer(
      //   menuItem: Helper.getMenuItemList(context),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(title: MY_ACCOUNT_TXT, hideSidemenu: true),
            hightSpacer30,
            _getProfileImage(),
            hightSpacer10,
            Text(name ?? "",
                style: getTextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: MEDIUM_PLUS_FONT_SIZE,
                )),
            Padding(
              padding: smallPaddingAll(),
              child: Text(email ?? "",
                  style: getTextStyle(
                      color: AppColors.getPrimary(),
                      fontSize: MEDIUM_MINUS_FONT_SIZE,
                      fontWeight: FontWeight.normal)),
            ),
            Text(phone ?? "",
                style: getTextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: MEDIUM_PLUS_FONT_SIZE,
                )),
            hightSpacer25,
            Container(
              margin: horizontalSpace(x: 32),
              height: 100,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePassword()));
                    },
                    child:
                        _actionListItem(CHANGE_PASSWORD_IMAGE, CHANGE_PASSWORD),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => handleLogout(),
                    child: _actionListItem(LOGOUT_IMAGE, LOGOUT_TITLE),
                  ),
                ],
              ),
              // decoration: BoxDecoration(
              //     borderRadius:
              //         BorderRadius.circular(BORDER_CIRCULAR_RADIUS_20),
              //     boxShadow: [boxShadow]),
            ),
            const Spacer(),
            Center(
                child: Text(
              version ?? APP_VERSION_FALLBACK,
              style: getHintStyle(),
            )),
            hightSpacer10
          ],
        ),
      ),
    );
  }

  Future<void> handleLogout() async {
    checkNetworkAvailable();
    var offlineOrders = await DbSaleOrder().getOfflineOrders();
    // var offlineOrders = await DbSaleOrder().getOrders();

    ///if there are no offline orders
    ///scessfully logout
    if (offlineOrders.isEmpty && internetAvailable) {
      if (!mounted) return;
      var res = await Helper.showConfirmationPopup(
          context, LOGOUT_QUESTION, OPTION_YES,
          hasCancelAction: true);
      if (res != OPTION_CANCEL.toLowerCase()) {
        //check this later
        // await SyncHelper().logoutFlow();
        await fetchMasterAndDeleteTransaction();
      }
    }
    // else if (isInternetAvailable == true) {
    //   LocalNotificationService().showNotification(
    //       id: 0,
    //       title: 'Background Sync',
    //       body: 'Please wait Background sync work in progess');
    // }
    else {
      // if (!mounted) return;

      ///there are offline orders
      ///and internet is on
      if (offlineOrders.isNotEmpty && internetAvailable == false) {
        var res = await Helper.showConfirmationPopup(
            context, OFFLINE_ORDER_MSG, OPTION_OK);
        if (res == OPTION_OK.toLowerCase()) {
          checkNetworkAvailable();
          if (internetAvailable == true) {
            LocalNotificationService().showNotification(
                id: 0,
                title: 'Background Sync',
                body: 'Please wait Background sync work in progess');
            var response = await SyncHelper().syncNowFlow();

            if (response == true) {
              // ignore: use_build_context_synchronously
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            }
            await DbSaleOrder().modifySevenDaysOrdersFromToday();
          } else {
            // Navigator.of(context).pop();
            // Navigator.pop(context);
          }
        }
      } else if (offlineOrders.isEmpty && internetAvailable == false) {
        if (!mounted) return;
        await Helper.showConfirmationPopup(
            context, OFFLINE_ORDER_MSG, OPTION_OK);
      } else {
        if (internetAvailable) {
          LocalNotificationService().showNotification(
              id: 0,
              title: 'Background Sync',
              body: 'Please wait Background sync work in progess');
          // var response =
          await SyncHelper().syncNowFlow();
          // if (response == true) {
          LocalNotificationService().showNotification(
              id: 1,
              title: 'Background Sync',
              body: 'Background Sync completed.');

          // ignore: use_build_context_synchronously
          var res = await Helper.showConfirmationPopup(
              context, LOGOUT_QUESTION, OPTION_YES,
              hasCancelAction: true);
          if (res != OPTION_CANCEL.toLowerCase()) {
            // ignore: use_build_context_synchronously
            await fetchMasterAndDeleteTransaction();
          }
          // await Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const Login(),
          //   ),
          // );
          // }
          await DbSaleOrder().modifySevenDaysOrdersFromToday();
        } else {
          // Navigator.of(context).pop();
          // Navigator.pop(context);
        }

        // var resp = await Helper.showConfirmationPopup(
        //     context, GET_ONLINE_MSG, OPTION_OK);

        // if (res == OPTION_OK.toLowerCase() && isInternetAvailable) {
        // await   _checkForSyncNow();
        //for testing only : await fetchDataAndNavigate();
        // await fetchMasterAndDeleteTransaction();

        // }
      }
    }
  }

// _checkForSyncNow() async {
//  List< SaleOrder> offlineOrders =await DbSaleOrder().getOfflineOrders();
//   syncNowActive = offlineOrders.isNotEmpty;

//   if (syncNowActive) {
//     for (var order in offlineOrders) {
//       await _syncOrder(order);
//     }
//     await SyncHelper().syncNowFlow();
//   }

//   var categories = await DbCategory().getCategories();
//   debugPrint("Category: ${categories.length}");
//   setState(() {});
// }

// Future<void> _syncOrder(SaleOrder order) async {
//   try {
//     var response = await CreateOrderService().createOrder(order);

//     if (response.status!) {
//       // Order synced successfully
//       DbSaleOrder().createOrder(order);
//       log('Order synced and deleted from local storage');
//       //If order synced successfully , delete transaction data
//      await fetchMasterAndDeleteTransaction();

//     } else {
//       // Handling synchronization failure
//       print('Order synchronization failed: ${response.message}');
//     }
//   } catch (e) {
//     // Handling exceptions during synchronization
//     print('Error during order synchronization: $e');
//   }
// }

  Future<void> fetchDataAndNavigate() async {
    // log('Entering fetchDataAndNavigate');
    try {
      // Fetch the URL
      String url = await DbInstanceUrl().getUrl();
      // Clear the database
      await DBPreferences().delete();
      log("Cleared the DB");
      //to save the url
      await DbInstanceUrl().saveUrl(url);
      log("Saved Url:$url");
      // Navigate to a different screen
      // ignore: use_build_context_synchronously
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );

      // Save the URL again
      //await DBPreferences().savePreference('url', url);
    } catch (e) {
      // Handle any errors that may occur during this process
      log('Error: $e');
    }
  }

  Widget _getProfileImage() {
    return profilePic.isEmpty
        ? SvgPicture.asset(
            MY_ACCOUNT_IMAGE,
            width: 200,
          )
        : CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.getPrimary(),
            foregroundImage: MemoryImage(profilePic),
          );
  }

  Future<void> fetchMasterAndDeleteTransaction() async {
    // log('Entering fetchDataAndNavigate');
    try {
      // Fetch the URL
      String url = await DbInstanceUrl().getUrl();
      // Clear the transactional data
      // await DBPreferences().deleteTransactionData;
      await DbCustomer().deleteCustomer(DeleteCustomers);
      await DbSaleOrder().delete();
      log("Cleared the transactional data");
      //to save the url
      await DbInstanceUrl().saveUrl(url);
      log("Saved Url:$url");
      // Navigate to a different screen
      // ignore: use_build_context_synchronously
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );

      // Save the URL again
      //await DBPreferences().savePreference('url', url);
    } catch (e) {
      // Handle any errors that may occur during this process
      log('Error: $e');
    }
  }

  checkNetworkAvailable() async {
    try {
      bool isInternetAvailable = await Helper.isNetworkAvailable();
      setState(() {
        internetAvailable = isInternetAvailable;
      });
    } catch (error) {
      // Handle the error if needed
      print('Error: $error');
    }
  }
}
