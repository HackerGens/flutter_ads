import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bannerLoaded = false;
  bool rewardLoaded = false;
  bool rewardInterstitialLoaded = false;
  bool interstitialLoaded = false;

  late BannerAd bannerAd;

  late InterstitialAd interstitialAd;

  late RewardedAd rewardedAd;

  late RewardedInterstitialAd rewardedInterstitialAd;

  late NativeAd nativeAd;

  loadBannerAd(String id) {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: id,
        listener: BannerAdListener(
          onAdClicked: (ad) {
            print("$ad clicked");
          },
          onAdClosed: (ad) {
            print("$ad closed");
          },
          onAdFailedToLoad: (ad, error) {
            print("$ad failed to load $error");
          },
          onAdImpression: (ad) {
            print("$ad Impression");
          },
          onAdLoaded: (ad) {
            setState(() {
              bannerLoaded = true;
              print("$ad loaded");
            });
          },
          onAdOpened: (ad) {
            print("$ad opened");
          },
          onAdWillDismissScreen: (ad) {
            print("$ad Will dismiss");
          },
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            print("$ad paid");
            print("$ad , $valueMicros , $precision , $currencyCode");
          },
        ),
        request: AdRequest());
    bannerAd.load();
  }

  loadRewardedAd(String id) {
    RewardedAd.load(
        adUnitId: id,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            setState(() {
              rewardedAd = ad;
              rewardLoaded = true;
            });
          },
          onAdFailedToLoad: (error) {
            print(error);
            rewardLoaded = false;
          },
        ));
  }

  loadRewardedInterstitialAd(String id) {
    RewardedInterstitialAd.load(
        adUnitId: id,
        request: AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            setState(() {
              rewardedInterstitialAd = ad;
              rewardInterstitialLoaded = true;
            });
          },
          onAdFailedToLoad: (error) {
            print(error);
            rewardInterstitialLoaded = false;
          },
        ));
  }

  initInterstitial() async {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdImpression: (ad) {
                print("$ad impression");
              },
              onAdClicked: (ad) {
                print("$ad clicked");
              },
              onAdDismissedFullScreenContent: (ad) {
                print("$ad dismissed");
                initInterstitial();
              },
            );
            setState(() {
              interstitialLoaded = true;
              interstitialAd = ad;
            });
          },
          onAdFailedToLoad: (error) {
            print("$error ==============");
            setState(() {
              interstitialLoaded = false;
            });
          },
        ));
  }

  @override
  void initState() {
    loadBannerAd("ca-app-pub-3940256099942544/6300978111");
    initInterstitial();
    loadRewardedAd("ca-app-pub-3940256099942544/5224354917");
    loadRewardedInterstitialAd("ca-app-pub-3940256099942544/5354046379");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          bannerLoaded
              ? SizedBox(
                  width: bannerAd.size.width.toDouble(),
                  height: bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd),
                )
              : Container(),
          ElevatedButton(
              onPressed: () {
                interstitialLoaded
                    ? interstitialAd.show()
                    : print("Not Loaded Yet");
              },
              child: const Text("Show Interstitial Ad")),
          ElevatedButton(
              onPressed: () {
                rewardLoaded
                    ? rewardedAd.show(onUserEarnedReward:
                        (AdWithoutView ad, RewardItem reward) {
                        print(ad);
                        print(reward);
                      })
                    : print("Not Loaded Yet");
              },
              child: const Text("Show Rewarded Ad")),
          ElevatedButton(
              onPressed: () {
                rewardInterstitialLoaded
                    ? rewardedInterstitialAd.show(onUserEarnedReward:
                        (AdWithoutView ad, RewardItem reward) {
                        print(ad);
                        print(reward);
                      })
                    : print("Not Loaded Yet");
              },
              child: const Text("Show Rewarded Interstitial Ad")),
        ],
      ),
    );
  }
}
