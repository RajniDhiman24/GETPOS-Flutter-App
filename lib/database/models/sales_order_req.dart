import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:nb_posx/core/mobile/sales_history/ui/sales_details_item.dart';
import 'package:nb_posx/database/db_utils/db_constants.dart';
import 'package:nb_posx/database/models/sales_order_req_items.dart';

part 'sales_order_req.g.dart';

@HiveType(typeId: SalesOrderRequestId)
class SalesOrderRequest extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? hubManager;

  @HiveField(2)
  String? customer;

  @HiveField(3)
  String? transactionDate;

  @HiveField(4)
  String? deliveryDate;

  @HiveField(5)
  List<SaleOrderRequestItems>? items;

  @HiveField(6)
  String? modeOfPayment;

  @HiveField(7)
  String? mpesaNo;

  SalesOrderRequest({
    required this.id,
    required this.hubManager,
    required this.customer,
    required this.transactionDate,
    required this.deliveryDate,
    required this.items,
    required this.modeOfPayment,
    required this.mpesaNo,
   
  });

  SalesOrderRequest copyWith({
    String? id,
    String? hubManager,
    String? customer,
    String? transactionDate,
    String? deliveryDate,
    List<SaleOrderRequestItems>? items,
    String? modeOfPayment,
    String? mpesaNo,
  }) {
    return SalesOrderRequest(
      id: id ?? this.id,
      hubManager: hubManager ?? this.hubManager,
      customer: customer ?? this.customer,
      transactionDate: transactionDate ?? this.transactionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      modeOfPayment: modeOfPayment ?? this.modeOfPayment,
      mpesaNo: mpesaNo ?? this.mpesaNo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hubManager': hubManager,
      'customer': customer,
      'transactionDate': transactionDate,
      'deliveryDate': deliveryDate,
      'items': items!.map((x) => x.toMap()).toList(),
      'modeOfPayment': modeOfPayment,
      'mpesaNo': mpesaNo,
    };
  }

  factory SalesOrderRequest.fromMap(Map<String, dynamic> map) {
    return SalesOrderRequest(
      id: map['id'],
      hubManager: map['hubManager'],
      customer: map['customer'],
      transactionDate: map['transactionDate'],
      deliveryDate: map['deliveryDate'],
      items: List<SaleOrderRequestItems>.from(
          map['selectedOption']?.map((x) => SaleOrderRequestItems.fromMap(x))),
      modeOfPayment: map['modeOfPayment'],
      mpesaNo: map['mpesaNo'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesOrderRequest.fromJson(String source) =>
      SalesOrderRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SaleOrder(id: $id, hubManager: $hubManager, customer: $customer,  items: $items, modeOfPayment: $modeOfPayment, mpesaNo: $mpesaNo )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SalesOrderRequest &&
        other.id == id &&
        other.hubManager == hubManager &&
        other.customer == customer &&
        other.items == items &&
        listEquals(other.items, items) &&
        other.modeOfPayment == modeOfPayment &&
        other.mpesaNo == mpesaNo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        hubManager.hashCode ^
        customer.hashCode ^
        items.hashCode ^
        modeOfPayment.hashCode ^
        mpesaNo.hashCode;
  }
}