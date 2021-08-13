import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loccon/pages/feed/single_feed_page.dart';

class DynamicLinkService {

  static Future<void> initialDynamicLinkCheck(BuildContext context, String userId) async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('initial path ${deepLink.path}');
      final queryParams = deepLink.queryParameters;
      if (queryParams.length > 0) {
        String feedId = queryParams['id'];
        print('feed id $feedId');
        Navigator.push(context, MaterialPageRoute(builder: (c) =>
            SingleFeedPage(feedId: feedId, userId: userId,)));
      }
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLinkData) async {
          final Uri deepLink = dynamicLinkData?.link;
          if (deepLink != null) {
            print('on link path ${deepLink.path}');
            final queryParams = deepLink.queryParameters;
            if (queryParams.length > 0) {
              String feedId = queryParams['id'];
              print('feed id $feedId');
              Navigator.push(context, MaterialPageRoute(builder: (c) =>
                  SingleFeedPage(feedId: feedId, userId: userId,)));
            }
          }
        },
        onError: (OnLinkErrorException e) async {
          print('Dynamic link failed ${e.message}');
        }
    );
  }

  static Future<String> createDynamicLink(String feedId, String description, Uri url) async {
    print("create link contains $feedId $url");
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://loccon.page.link',
      link: Uri.parse('https://loccon.page.link?id=$feedId'),
      androidParameters: AndroidParameters(packageName: 'com.proactii.loccon'),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,),
      socialMetaTagParameters: SocialMetaTagParameters(title: 'Loccon - #YourLocalHero', description: '$description', imageUrl: url)
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    print('created link ${shortDynamicLink.shortUrl.toString()}');
    return shortDynamicLink.shortUrl.toString();
  }

}