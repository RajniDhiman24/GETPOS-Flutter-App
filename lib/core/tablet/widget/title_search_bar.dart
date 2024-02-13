import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_posx/configs/theme_dynamic_colors.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../utils/ui_utils/padding_margin.dart';
import '../../../../../utils/ui_utils/spacer_widget.dart';
import '../../../../../utils/ui_utils/text_styles/custom_text_style.dart';
import '../../../../../widgets/button.dart';
import '../../../widgets/search_widget_tablet.dart';

// ignore: must_be_immutable
class TitleAndSearchBar extends StatefulWidget {
  final String title;
  final String? searchHint;
  final double? searchBoxWidth;
  final bool searchBoxVisible;
  final bool parkedOrderVisible;
  final TextEditingController? searchCtrl;
  final bool hideOperatorDetails;
  Function(String changedtext)? onTextChanged;
  Function(String text)? onSubmit;
  VoidCallback? onTap;
  Function? parkOrderClicked;
  TextInputType keyboardType;
  List<TextInputFormatter>? inputFormatter;
 

  TitleAndSearchBar(
      {Key? key,
      required this.title,
      this.searchHint,
      this.onTap,
      this.searchCtrl,
      this.searchBoxWidth = 360, //330
      this.searchBoxVisible = true,
      this.parkedOrderVisible = false,
      this.hideOperatorDetails = false,
      this.onTextChanged,
   
      this.parkOrderClicked,
      this.onSubmit,
      this.inputFormatter,
      this.keyboardType = TextInputType.text})
      : super(key: key);

  @override
  State<TitleAndSearchBar> createState() => _TitleAndSearchBarState();
}

class _TitleAndSearchBarState extends State<TitleAndSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 3,
            ),
            Text(
              widget.title,
              style: getTextStyle(
                  fontSize: EXTRA_LARGE_FONT_SIZE,
                  fontWeight: FontWeight.w800,
                  color: AppColors.getTextandCancelIcon()),
            ),
            const Spacer(),
            Visibility(
              visible: widget.searchBoxVisible,
              child: Container(
                width: widget.searchBoxWidth,
                padding: horizontalSpace(x: 10),
                child: SearchWidgetTablet(
                  onTap: widget.onTap,
                  searchHint: widget.searchHint,
                  searchTextController: widget.searchCtrl,
                  onTextChanged: (val) => widget.onTextChanged!(val),
                  onSubmit: (val) => widget.onSubmit!(val),
                  keyboardType: widget.keyboardType,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            widget.parkedOrderVisible ? const Spacer() : Container(),
            Visibility(
              visible: widget.parkedOrderVisible,
              child: parkOrderBtnWidget,
            ),
          ],
        ),
        hightSpacer10,
        // Visibility(
        //   visible: !widget.hideOperatorDetails,
        //   child: Padding(
        //     padding: topSpace(y: 10),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         // SvgPicture.asset(
        //         //   MY_PROFILE_TAB_IMAGE,
        //         //   // color: MAIN_COLOR,
        //         //   width: 15,
        //         // ),
        //         // widthSpacer(10),
        //         // Text(
        //         //   Helper.hubManager != null
        //         //       ? Helper.hubManager!.name
        //         //       : "Hub manager",
        //         //   style: getTextStyle(
        //         //       fontSize: MEDIUM_PLUS_FONT_SIZE,
        //         //       fontWeight: FontWeight.bold),
        //         // ),
        //         // widthSpacer(10)
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget get parkOrderBtnWidget => Expanded(
        child: SizedBox(
          // width: double.infinity,
          child: ButtonWidget(
            onPressed: () => widget.parkOrderClicked!(),
            title: "Parked Orders",
            colorTxt: AppColors.fontWhiteColor,
            primaryColor: AppColors.getTextandCancelIcon(),
            width: 200,
            borderRadius: 15,
            fontSize: LARGE_MINUS_FONT_SIZE,
          ),
        ),
      );
}
