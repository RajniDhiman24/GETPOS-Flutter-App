import 'dart:developer';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:nb_posx/core/mobile/transaction_history/model/transaction.dart';
import 'package:nb_posx/database/db_utils/db_order_tax.dart';
import '../../../../../constants/app_constants.dart';
import '../model/sale_order_list_response.dart';
import '../../../../../database/db_utils/db_constants.dart';
import '../../../../../database/db_utils/db_hub_manager.dart';
import '../../../../../database/db_utils/db_preferences.dart';
import '../../../../../database/db_utils/db_sale_order.dart';
import '../../../../../database/models/customer.dart';
import '../../../../../database/models/hub_manager.dart';
import '../../../../../database/models/order_item.dart';
import '../../../../../database/models/sale_order.dart';
import '../../../../../network/api_constants/api_paths.dart';
import '../../../../../network/service/api_utils.dart';
import '../../../../../utils/helper.dart';

class GetPreviousOrder {
  ///
  ///get old orders of hubmanager when user login in to the app
  ///
  Future<bool> getOrdersOnLogin() async {
    DateTime todaysDateTime = DateTime.now();

    var dataUpto =
        todaysDateTime.subtract(const Duration(days: OFFLINE_DATA_FOR));

    // Fetching hub manager id/email from DbPreferences
    String hubManagerId = await DBPreferences().getPreference(HubManagerId);

    //Getting the hub manager
    HubManager? hubManager = await DbHubManager().getManager();

    //Creating GET api url
    String apiUrl = SALES_HISTORY;
    //apiUrl += '?hub_manager=$hubManagerId';
    // changes done for domain
    //&from_date=$dataUpto&to_date=$todaysDateTime';

   apiUrl += '?hub_manager=$hubManagerId&from_date=$dataUpto&to_date=${DateTime.now()}';

    //Call to Sales History api
    var apiResponse = await APIUtils.getRequestWithHeaders(apiUrl);

    log('Sales History Response :: $apiResponse}');
    if (apiResponse["message"]["message"] == "success") {
      List<SaleOrder> sales = [];
      //Parsing the JSON Response
      SalesOrderResponse salesOrderResponse =
          SalesOrderResponse.fromJson(apiResponse);
      //If success response from api
      if (salesOrderResponse.message!.orderList!.isNotEmpty) {
        await Future.forEach(salesOrderResponse.message!.orderList!,
            (orderEntry) async {
          OrderList order = orderEntry as OrderList;
          List<OrderItem> orderedProducts = [];
          await Future.forEach(order.items!, (item) async {
            Items orderedProduct = item as Items;

            //Getting product image
            Uint8List productImage = Uint8List.fromList([]);

            if (item.image != null && item.image!.isNotEmpty) {
              productImage = await Helper.getImageBytesFromUrl(item.image!);
            }

            OrderItem product = OrderItem(
                id: orderedProduct.itemCode!,
                name: orderedProduct.itemName!,
                group: '',
                description: '',
                stock: 0,
                price: orderedProduct.rate!,
                attributes: [],
                orderedQuantity: orderedProduct.qty!,
                productImage: productImage,
                productUpdatedTime: DateTime.now(),
                productImageUrl: '',
                tax: []);
            orderedProducts.add(product);
          });

          //String orderTime = Helper.getTime(order.transactionTime);

          String transactionDateTime =
              "${order.transactionDate} ${order.transactionTime}";

          String date = DateFormat('EEEE d, LLLL y')
              .format(DateTime.parse(transactionDateTime))
              .toString();
          // log('Date :1 $date');

          //Need to convert 2:26:17 to 02:26 AM
          String time = DateFormat()
              .add_jm()
              .format(DateTime.parse(transactionDateTime))
              .toString();
          // log('Time : $time');

          //Getting customer image
          // Uint8List customerImage = Uint8List.fromList([]);

          // if (order.customerImage.isNotEmpty) {
          //   customerImage =
          //       await Helper.getImageBytesFromUrl(order.customerImage);
          // }
         String  orderId = await Helper.getOrderId();
      log('Order No : $orderId');
 var tax = await DbOrderTax().getOrderWiseTax(orderId!);
      log("OrderWise Taxes :: $tax");
          //Creating a SaleOrder
          SaleOrder saleOrder = SaleOrder(
              id: order.name!,
              date: date,
              time: time,
              customer: Customer(
                  id: order.customer!,
                  name: order.customerName!,
                  phone: order.contactPhone!,
                  email: order.contactEmail!,
                  isSynced: true,
                  modifiedDateTime: DateTime.now()),
              items: orderedProducts,
              manager: hubManager!,
              orderAmount: order.grandTotal!,
              tracsactionDateTime: DateTime.parse(transactionDateTime),
              transactionId: order.mpesaNo ?? "",
              paymentMethod: order.modeOfPayment!,
              paymentStatus: "",
              transactionSynced: true,
              taxes: tax ?? []
              );

          sales.add(saleOrder);
        });
        return await DbSaleOrder().saveOrders(sales);
      }
    }
    return false;
  }
  Future<List<Transaction>> getSavedOrders() async {
    List<SaleOrder> savedOrders = await DbSaleOrder().getOrders();
    List<Transaction> transactions = [];

    for (var order in savedOrders) {
      Transaction transaction = Transaction(
        id: order.id,
        date: order.date,
        time: order.time,
        customer: order.customer,
        items: order.items,
        orderAmount: order.orderAmount,
        tracsactionDateTime: order.tracsactionDateTime,
      );

      transactions.add(transaction);
    }

    return transactions;
  }
}
