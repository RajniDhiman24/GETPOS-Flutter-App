import 'package:hive_flutter/hive_flutter.dart';
import 'package:nb_posx/core/mobile/create_order_new/ui/widget/calculate_taxes.dart';
import 'package:nb_posx/database/db_utils/db_constants.dart';
import 'package:nb_posx/database/models/sales_order_req_items.dart';
import 'package:nb_posx/database/models/taxes.dart';

class DbSaleOrderRequestItems {
  late Box box;

  Future<List> saveItemWiseTaxRequest(orderId, List<Taxation> list) async {
    box = await Hive.openBox<Taxation>(SALES_ORDER_REQUEST_BOX);
    for (Taxation item in list) {
      await box.put(item.taxType, item);
    }

    return list;
  }
}