import 'dart:developer';

import 'package:nb_posx/core/service/theme/api/model/theme_response.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../database/db_utils/db_constants.dart';
import '../../../../../database/db_utils/db_preferences.dart';
import '../../../../../network/api_constants/api_paths.dart';
import '../../../../../network/api_helper/api_status.dart';
import '../../../../../network/api_helper/comman_response.dart';
import '../../../../../network/service/api_utils.dart';
import '../../../../../utils/helper.dart';
import '../../../../database/db_utils/db_instance_url.dart';
// Import your ThemeResponse class here

class ThemeService {
  static Future<CommanResponse> fetchTheme(String url) async {
    // if (!_isValidUrl(url)) {
    //   return CommanResponse(status: false, message: INVALID_URL);
    // }

    // Check for the internet connection
    var isInternetAvailable = await Helper.isNetworkAvailable();

    await DbInstanceUrl().saveUrl(url);
    String savedUrl = await DbInstanceUrl().getUrl();
    log('Saved URL :: $savedUrl');
    instanceUrl = "https://getpos.in/api/";

    if (isInternetAvailable) {
      String apiUrl = THEME_PATH;
      // Call  theme settings API
      var apiResponse = await APIUtils.getRequest(apiUrl);

      // Parsing the theme settings response
      ThemeResponse themeResponse = ThemeResponse.fromJson(apiResponse);

      // API success
      // ignore: unnecessary_null_comparison
      if (themeResponse.message != null) {
        // You can access theme settings data like themeResponse.message.data.primary

        // Return the Success Theme Response
        return CommanResponse(
            status: true,
            message: SUCCESS,
            apiStatus: ApiStatus.REQUEST_SUCCESS,
            data: themeResponse.message.data);
      }

      // API Failure
      else {
        // Return the Failure Theme Response
        return CommanResponse(
            status: false,
            message: themeResponse.message.data,
            apiStatus: ApiStatus.REQUEST_FAILURE);
      }
    }

    // If internet is not available
    else {
      return CommanResponse(
          status: false,
          message: NO_INTERNET,
          apiStatus: ApiStatus.NO_INTERNET);
    }
  }
}

  /// Function to check whether the input URL is valid or not
  // static bool _isValidUrl(String url) {
  //   // Regex to check valid URL
  //   String regex =
  //       "((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)";

  //   return RegExp(regex).hasMatch(url);
  // }
