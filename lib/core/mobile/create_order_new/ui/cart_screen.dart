import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:nb_posx/core/mobile/parked_orders/ui/orderlist_screen.dart';
import 'package:nb_posx/utils/ui_utils/spacer_widget.dart';
import 'package:nb_posx/widgets/long_button_widget.dart';
import '../../../../../configs/theme_config.dart';
import '../../../../../constants/app_constants.dart';

import '../../../../../database/db_utils/db_parked_order.dart';
import '../../../../../database/models/order_item.dart';
import '../../../../../database/models/park_order.dart';
import '../../../../../utils/ui_utils/padding_margin.dart';
import '../../../../../utils/ui_utils/text_styles/custom_text_style.dart';
import '../../../../../widgets/custom_appbar.dart';
import '../../../../../widgets/product_shimmer_widget.dart';
import '../../../../constants/asset_paths.dart';
import '../../../../database/db_utils/db_hub_manager.dart';
import '../../../../database/models/hub_manager.dart';
import '../../../../database/models/sale_order.dart';
import '../../../../utils/helper.dart';
import '../../add_products/ui/added_product_item.dart';
import '../../sale_success/ui/sale_success_screen.dart';
import 'new_create_order.dart';

// ignore: must_be_immutable
class CartScreen extends StatefulWidget {
  ParkOrder order;
  CartScreen({required this.order, Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCODSelected = false;
  double totalAmount = 0.0;
  double subTotalAmount = 0.0;
  double taxAmount = 0.0;
  int totalItems = 0;
  double taxPercentage = 0;
  late HubManager? hubManager;
  // String? transactionID;
  late String paymentMethod;

  @override
  void initState() {
    super.initState();
    _getHubManager();
    //totalAmount = Helper().getTotal(widget.order.items);
    totalItems = widget.order.items.length;
    paymentMethod = "Cash";
    _configureTaxAndTotal(widget.order.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppbar(
                    title: "Cart",
                    hideSidemenu: true,
                  ),

                  Padding(
                      padding: paddingXY(x: 16, y: 16),
                      child: Text(
                        widget.order.customer.name,
                        style: getTextStyle(
                            fontSize: MEDIUM_PLUS_FONT_SIZE,
                            color: MAIN_COLOR,
                            fontWeight: FontWeight.bold),
                      )),

                  Padding(
                    padding: paddingXY(x: 16, y: 16),
                    child: Text(
                      "Items",
                      style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MEDIUM_PLUS_FONT_SIZE,
                          color: BLACK_COLOR),
                    ),
                  ),
                  productList(widget.order.items),
                  // selectedCustomerSection,
                  // searchBarSection,
                  // productCategoryList()
                  hightSpacer15,
                  Padding(
                      padding: paddingXY(x: 16, y: 16),
                      child: Text(
                        'Payment Methods',
                        style: getTextStyle(
                            fontSize: MEDIUM_PLUS_FONT_SIZE,
                            color: BLACK_COLOR,
                            fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: paddingXY(x: 16),
                    child: Row(
                      children: [
                        getPaymentOption(PAYMENT_CARD_ICON, CARD_PAYMENT_TXT,
                            !_isCODSelected),
                        widthSpacer(15),
                        getPaymentOption(PAYMENT_CASH_ICON, CASH_PAYMENT_TXT,
                            _isCODSelected),
                      ],
                    ),
                  ),
                  hightSpacer20,
                  Padding(
                      padding: paddingXY(x: 16, y: 0),
                      child: _promoCodeSection()),
                  hightSpacer15,
                  Padding(
                      padding: paddingXY(x: 16, y: 0),
                      child: _subtotalSection('Subtotal',
                          '$APP_CURRENCY ${subTotalAmount.toStringAsFixed(2)}')),
                  hightSpacer10,
                  Padding(
                      padding: paddingXY(x: 16, y: 0),
                      child: _subtotalSection('Discount', '$APP_CURRENCY 0.00',
                          isDiscount: true)),
                  hightSpacer10,
                  Padding(
                      padding: paddingXY(x: 16, y: 0),
                      child: _subtotalSection(
                          'Tax (${taxPercentage.toStringAsFixed(2)} %)',
                          ' $APP_CURRENCY ${taxAmount.toStringAsFixed(2)}')),
                  hightSpacer10,
                ],
              )),

              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     margin: morePaddingAll(),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(5),
              //       color: MAIN_COLOR,
              //     ),
              //     child: ListTile(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) =>
              //                     CheckoutScreen(order: widget.order)));
              //       },
              //       title: Text(
              //         "${widget.order.items.length} Item",
              //         style: getTextStyle(
              //             fontSize: SMALL_FONT_SIZE,
              //             color: WHITE_COLOR,
              //             fontWeight: FontWeight.normal),
              //       ),
              //       subtitle: Text("USD ${_getItemTotal(widget.order.items)}",
              //           style: getTextStyle(
              //               fontSize: LARGE_FONT_SIZE,
              //               fontWeight: FontWeight.w600,
              //               color: WHITE_COLOR)),
              //       trailing: Text("Checkout",
              //           style: getTextStyle(
              //               fontSize: LARGE_FONT_SIZE,
              //               fontWeight: FontWeight.w400,
              //               color: WHITE_COLOR)),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        bottomNavigationBar: bottomBarWidget());
  }

  Widget bottomBarWidget() => Container(
        margin: const EdgeInsets.all(15),
        height: 100,
        child: Row(children: [
          GestureDetector(
              onTap: (() {
                _parkOrder();
              }),
              child: Container(
                height: 70,
                width: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: LIGHT_BLACK_COLOR,
                    borderRadius: BorderRadius.all(Radius.circular(7))),
                child: Text(
                  'Park Order',
                  style: getTextStyle(
                      color: WHITE_COLOR,
                      fontSize: MEDIUM_FONT_SIZE,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              )),
          Expanded(
              child: GestureDetector(
                  onTap: () => createSale(),
                  child: Container(
                      height: 70,
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: const BoxDecoration(
                          color: MAIN_COLOR,
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.items.length > 1
                                    ? "${widget.order.items.length} Items"
                                    : "${widget.order.items.length} Item",
                                style: getTextStyle(
                                    fontSize: MEDIUM_MINUS_FONT_SIZE,
                                    color: WHITE_COLOR,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                  "$APP_CURRENCY ${totalAmount.toStringAsFixed(2)}",
                                  style: getTextStyle(
                                      fontSize: LARGE_FONT_SIZE,
                                      fontWeight: FontWeight.w600,
                                      color: WHITE_COLOR)),
                            ],
                          ),
                          Text("Checkout",
                              style: getTextStyle(
                                  fontSize: LARGE_FONT_SIZE,
                                  fontWeight: FontWeight.w400,
                                  color: WHITE_COLOR)),
                        ],
                      ))))
        ]),
      );

  _parkOrder() async {
    await DbParkedOrder().saveOrder(widget.order);
    await showGeneralDialog(
        context: context,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        pageBuilder: ((context, animation, secondaryAnimation) {
          return Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: SizedBox(
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: (() {
                              Navigator.pop(context);
                            }),
                            icon: SvgPicture.asset(
                              CROSS_ICON,
                              color: BLACK_COLOR,
                              height: 15,
                              width: 15,
                            ))),
                    hightSpacer10,
                    Text(
                      "Order Parked",
                      style: getTextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: LARGE_FONT_SIZE,
                          color: BLACK_COLOR),
                    ),
                    hightSpacer30,
                    LongButton(
                        isAmountAndItemsVisible: false,
                        buttonTitle: 'Create a new order',
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewCreateOrder()),
                              (route) => route.isFirst);
                        }),
                    LongButton(
                        isAmountAndItemsVisible: false,
                        buttonTitle: 'Back to Home',
                        onTap: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }),
                    LongButton(
                        isAmountAndItemsVisible: false,
                        buttonTitle: 'View parked orders',
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OrderListScreen()),
                              (route) => route.isFirst);
                        }),
                    hightSpacer20
                  ],
                ),
              ));
        }));
  }

  getPaymentOption(String icon, String title, bool selected) {
    return SizedBox(
      child: InkWell(
        onTap: () {
          setState(() {
            if (!selected) {
              _isCODSelected = !_isCODSelected;
            }
          });
        },
        child: Container(
          height: 120,
          width: 100,
          decoration: BoxDecoration(
              color: selected ? OFF_WHITE_COLOR : WHITE_COLOR,
              border: Border.all(
                  color: selected ? MAIN_COLOR : DARK_GREY_COLOR, width: 0.4),
              borderRadius: BorderRadius.circular(BORDER_CIRCULAR_RADIUS_10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                height: 40,
              ),
              hightSpacer20,
              Text(title,
                  style: getTextStyle(
                      fontSize: MEDIUM_MINUS_FONT_SIZE,
                      color: DARK_GREY_COLOR)),
            ],
          ),
        ),
      ),
    );
  }

  Widget productList(List<OrderItem> prodList) {
    return Padding(
      padding: horizontalSpace(),
      child: ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider();
          },
          shrinkWrap: true,
          itemCount: prodList.isEmpty ? 10 : prodList.length,
          primary: false,
          itemBuilder: (context, position) {
            if (prodList.isEmpty) {
              return const ProductShimmer();
            } else {
              return InkWell(
                onTap: () {
                  // _openItemDetailDialog(context, prodList[position]);
                },
                child: AddedProductItem(
                  product: prodList[position],
                  onDelete: () {},
                  onItemAdd: () {
                    setState(() {
                      if (prodList[position].orderedQuantity <
                          prodList[position].stock) {
                        prodList[position].orderedQuantity =
                            prodList[position].orderedQuantity + 1;
                        _updateOrderPriceAndSave();
                      }
                    });
                  },
                  onItemRemove: () {
                    setState(() {
                      if (prodList[position].orderedQuantity > 0) {
                        prodList[position].orderedQuantity =
                            prodList[position].orderedQuantity - 1;
                        if (prodList[position].orderedQuantity == 0) {
                          widget.order.items.remove(prodList[position]);
                          if (prodList.isEmpty) {
                            DbParkedOrder().deleteOrder(widget.order);
                            Navigator.pop(context, "reload");
                          } else {
                            _updateOrderPriceAndSave();
                          }
                        } else {
                          _updateOrderPriceAndSave();
                        }
                      }
                    });
                  },
                ),
              );
              // return ListTile(title: Text(prodList[position].name));
            }
          }),
    );
  }

  Widget _promoCodeSection() {
    return Container(
      // height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
          color: MAIN_COLOR.withOpacity(0.1),
          border: Border.all(width: 1, color: MAIN_COLOR.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Promo Code",
            style: getTextStyle(
                fontWeight: FontWeight.w500,
                color: MAIN_COLOR,
                fontSize: MEDIUM_PLUS_FONT_SIZE),
          ),
          Column(
            children: [
              Text(
                "Deal 20",
                style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: MAIN_COLOR,
                    fontSize: MEDIUM_PLUS_FONT_SIZE),
              ),
              const SizedBox(height: 2),
              Row(
                children: List.generate(
                    15,
                    (index) => Container(
                          width: 2,
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: MAIN_COLOR,
                        )),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _subtotalSection(title, amount, {bool isDiscount = false}) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: getTextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDiscount ? GREEN_COLOR : BLACK_COLOR,
                  fontSize: MEDIUM_PLUS_FONT_SIZE),
            ),
            Text(
              amount,
              style: getTextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDiscount ? GREEN_COLOR : BLACK_COLOR,
                  fontSize: MEDIUM_PLUS_FONT_SIZE),
            ),
          ],
        ),
      );

  void createSale() async {
    paymentMethod = "Cash";

    DateTime currentDateTime = DateTime.now();
    String date =
        DateFormat('EEEE d, LLLL y').format(currentDateTime).toString();
    log('Date : $date');
    String time = DateFormat().add_jm().format(currentDateTime).toString();
    log('Time : $time');
    String orderId = await Helper.getOrderId();
    log('Order No : $orderId');

    SaleOrder saleOrder = SaleOrder(
        id: orderId,
        orderAmount: totalAmount,
        date: date,
        time: time,
        customer: widget.order.customer,
        manager: hubManager!,
        items: widget.order.items,
        transactionId: '',
        paymentMethod: paymentMethod,
        paymentStatus: "Paid",
        transactionSynced: false,
        parkOrderId:
            "${widget.order.transactionDateTime.millisecondsSinceEpoch}",
        tracsactionDateTime: currentDateTime);
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SaleSuccessScreen(placedOrder: saleOrder)));
  }

  // double _getItemTotal(items) {
  //   double total = 0;
  //   for (OrderItem item in items) {
  //     total = total + (item.orderedPrice * item.orderedQuantity);
  //   }
  //   return total;
  // }

  //TODO:: Siddhant - Need to correct the tax calculation logic here.
  _configureTaxAndTotal(List<OrderItem> items) {
    for (OrderItem item in items) {
      taxPercentage = taxPercentage + (item.tax * item.orderedQuantity);
      log('Tax Percentage after adding ${item.name} :: $taxPercentage');
      subTotalAmount =
          subTotalAmount + (item.orderedPrice * item.orderedQuantity);
      log('SubTotal after adding ${item.name} :: $subTotalAmount');
      if (item.attributes.isNotEmpty) {
        for (var attribute in item.attributes) {
          //taxPercentage = taxPercentage + attribute.tax;
          log('Tax Percentage after adding ${attribute.name} :: $taxPercentage');
          if (attribute.options.isNotEmpty) {
            for (var options in attribute.options) {
              taxPercentage = taxPercentage + options.tax;
              subTotalAmount = subTotalAmount + options.price;
              log('SubTotal after adding ${attribute.name} :: $subTotalAmount');
            }
          }
        }
      }
    }
    taxAmount = (subTotalAmount / 100) * taxPercentage;
    totalAmount = subTotalAmount + taxAmount;
    log('Subtotal :: $subTotalAmount');
    log('Tax percentage :: $taxAmount');
    log('Tax Amount :: $taxAmount');
    log('Total :: $totalAmount');
    //return taxPercentage;
  }

  void _getHubManager() async {
    hubManager = await DbHubManager().getManager();
  }

  void _updateOrderPriceAndSave() {
    double orderAmount = 0;
    for (OrderItem item in widget.order.items) {
      orderAmount += item.orderedPrice * item.orderedQuantity;
    }
    widget.order.orderAmount = orderAmount;

    //DbParkedOrder().saveOrder(widget.order);
  }
}
