import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nb_posx/configs/theme_dynamic_colors.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../constants/asset_paths.dart';
import '../../../../../database/models/attribute.dart';
import '../../../../../database/models/order_item.dart';
import '../../../../../utils/helper.dart';
import '../../../../../utils/ui_utils/card_border_shape.dart';
import '../../../../../utils/ui_utils/padding_margin.dart';
import '../../../../../utils/ui_utils/spacer_widget.dart';
import '../../../../../utils/ui_utils/text_styles/custom_text_style.dart';

// ignore: must_be_immutable
class TransactionDetailItem extends StatefulWidget {
  final OrderItem product;

  const TransactionDetailItem({Key? key, required this.product})
      : super(key: key);

  @override
  State<TransactionDetailItem> createState() => _TransactionDetailItemState();
}

class _TransactionDetailItemState extends State<TransactionDetailItem> {
 // bool isUserOnline = true;
  bool isInternetAvailable = true;
  @override
  void initState() {
    checkInternetAvailability();
 //   _checkUserAvailability();
    super.initState();
  }

  // _checkUserAvailability() async {
  //   isUserOnline = await Helper.isNetworkAvailable();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: cardBorderShape(),
        margin: mediumPaddingAll(),
        elevation: 0,
        child: Container(
          padding: horizontalSpace(),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                height: 90,
                width: 90,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppColors.getPrimary().withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: _getOrderedProductImage()),
            widthSpacer(15),
            Expanded(
              flex: 4,
              child: Container(
                height: 85,
                padding: verticalSpace(x: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.orderedQuantity > 0
                          ? '${widget.product.name} (${widget.product.orderedQuantity.round()})'
                          : widget.product.name,
                      style: getTextStyle(fontSize: SMALL_PLUS_FONT_SIZE),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      _getItemVariants(widget.product.attributes),
                      style: getTextStyle(
                          fontSize: SMALL_FONT_SIZE,
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      '$appCurrency ${widget.product.price.toStringAsFixed(2)}',
                     // '$appCurrency ${widget.product.orderedPrice.toStringAsFixed(2)}',
                      style: getTextStyle(
                          fontSize: SMALL_PLUS_FONT_SIZE,
                          color: AppColors.getPrimary(),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }

  String _getItemVariants(List<Attribute> itemVariants) {
    String variants = '';
    if (itemVariants.isNotEmpty) {
      for (var variantData in itemVariants) {
        for (var selectedOption in variantData.options) {
          variants = variants.isEmpty
              ? '${selectedOption.name} [$appCurrency ${selectedOption.price.toStringAsFixed(2)}]'
              : "$variants, ${selectedOption.name} [$appCurrency ${selectedOption.price.toStringAsFixed(2)}]";
        }
      }
    }
    return variants;
  }

  _getOrderedProductImage() {
    if (isInternetAvailable&&
        widget.product.productImage.isEmpty &&
        widget.product.productImageUrl!.isEmpty) {
      //To check when images are needed
      log('Image Url : ${widget.product.productImageUrl!}');
      return ClipRRect(
        borderRadius: BorderRadius.circular(8), // Image border
        child: SizedBox(
          // Image radius
          height: 80,
          child:
              Image.network(widget.product.productImageUrl!, fit: BoxFit.cover),
        ),
      );
    } else {
      log('Local image');
      return (isInternetAvailable &&
              widget.product.productImageUrl !=
                  null)
          ? Image.network(
              widget.product.productImageUrl!,
              fit: BoxFit.fill,
            )
          : (isInternetAvailable &&
                 widget.product.productImageUrl ==
                      null)
              ? Image.asset(
                  NO_IMAGE,
                  fit: BoxFit.fill,
                )
              : Image.asset(
                  NO_IMAGE,
                  fit: BoxFit.fill,
                );
      // Image.memory(widget.product.productImage);
    }
  }

  Future<void> checkInternetAvailability() async {
    try {
      bool internetAvailable = await Helper.isNetworkAvailable();
      setState(() {
        isInternetAvailable = internetAvailable;
      });
    } catch (error) {
      // Handle the error if needed
      print('Error: $error');
    }
  }
}
