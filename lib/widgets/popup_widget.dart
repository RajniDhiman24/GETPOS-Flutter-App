import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nb_posx/configs/theme_dynamic_colors.dart';
import 'package:nb_posx/core/mobile/products/ui/model/category.dart';
import 'package:nb_posx/database/db_utils/db_constants.dart';
import 'package:nb_posx/database/models/hub_manager.dart';
import 'package:nb_posx/database/models/order_item.dart';
import 'package:nb_posx/database/models/park_order.dart';
import 'package:nb_posx/database/models/product.dart';
import 'package:nb_posx/database/models/sale_order.dart';

import '../constants/app_constants.dart';
import '../database/models/customer.dart';
import '../utils/ui_utils/card_border_shape.dart';
import '../utils/ui_utils/padding_margin.dart';
import '../utils/ui_utils/spacer_widget.dart';
import '../utils/ui_utils/text_styles/custom_text_style.dart';

class SimplePopup extends StatefulWidget {
  final String message;
  final String buttonText;
  final Function onOkPressed;
  final bool hasCancelAction;
  bool? barrier = false;

  SimplePopup(
      {Key? key,
      required this.message,
      this.barrier,
      required this.buttonText,
      required this.onOkPressed,
      this.hasCancelAction = false})
      : super(key: key);

  @override
  State<SimplePopup> createState() => _SimplePopupState();
}

Box<dynamic>? box;

class _SimplePopupState extends State<SimplePopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        margin: morePaddingAll(x: 20),
        child: Center(
            child: Card(
          shape: cardBorderShape(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hightSpacer15,
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: getTextStyle(fontSize: MEDIUM_PLUS_FONT_SIZE),
              ),
              hightSpacer20,
              const Divider(),
              widget.hasCancelAction
                  ? SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: () => widget.onOkPressed(),
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 4.0,
                                  child: Center(
                                      child: Text(
                                    widget.buttonText,
                                    style: getTextStyle(
                                        fontSize: MEDIUM_MINUS_FONT_SIZE),
                                  )))),
                          const VerticalDivider(
                            thickness: 1,
                          ),
                          InkWell(
                              onTap: () => Navigator.of(context)
                                  .pop(OPTION_CANCEL.toLowerCase()),
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 4.0,
                                  child: Center(
                                      child: Text(
                                    OPTION_CANCEL,
                                    style: getTextStyle(
                                        fontSize: MEDIUM_MINUS_FONT_SIZE,
                                        color: AppColors.getAsset()),
                                  ))))
                        ],
                      ),
                    )
                  : InkWell(
                      onTap: () => widget.onOkPressed(),
                      child: SizedBox(
                          height: 20,
                          width: MediaQuery.of(context).size.width - 30,
                          child: Center(
                              child: Text(
                            widget.buttonText,
                            style:
                                getTextStyle(fontSize: MEDIUM_MINUS_FONT_SIZE),
                          )))),
              hightSpacer10
            ],
          ),
        )));
  }
}
