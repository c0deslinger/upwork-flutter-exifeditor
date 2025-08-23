import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'consumable_store.dart';

/// Kelas InAppPurchaseController bertanggung jawab untuk mengelola pembelian dalam aplikasi.
class InAppPurchaseController extends GetxController {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  var notFoundIds = <String>[].obs;
  var products = <ProductDetails>[].obs;
  var purchases = <PurchaseDetails>[].obs;
  var consumables = <String>[].obs;
  var isAvailable = false.obs;
  var purchasePending = false.obs;
  var loading = true.obs;
  var queryProductError = Rx<String?>(null);

  final bool kAutoConsume = Platform.isIOS || true;

  String productId = 'exifphoto_tip';
  // String kUpgradeId = 'upgrade';
  // String kSilverSubscriptionId = 'subscription_silver';
  // String kGoldSubscriptionId = 'subscription_gold';
  List<String> kProductIds = [];

  /// Metode yang dipanggil saat controller diinisialisasi.
  @override
  void onInit() {
    kProductIds = <String>[
      productId,
      // kUpgradeId,
      // kSilverSubscriptionId,
      // kGoldSubscriptionId,
    ];
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
    super.onInit();
  }

  /// Metode untuk menginisialisasi informasi toko.
  Future<void> initStoreInfo() async {
    final bool isStoreAvailable = await inAppPurchase.isAvailable();
    if (!isStoreAvailable) {
      isAvailable.value = isStoreAvailable;
      products.value = <ProductDetails>[];
      purchases.value = <PurchaseDetails>[];
      notFoundIds.value = <String>[];
      consumables.value = <String>[];
      purchasePending.value = false;
      loading.value = false;
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(kProductIds.toSet());
    if (productDetailResponse.error != null) {
      queryProductError.value = productDetailResponse.error!.message;
      isAvailable.value = isStoreAvailable;
      products.value = productDetailResponse.productDetails;
      purchases.value = <PurchaseDetails>[];
      notFoundIds.value = productDetailResponse.notFoundIDs;
      consumables.value = <String>[];
      purchasePending.value = false;
      loading.value = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError.value = null;
      isAvailable.value = isStoreAvailable;
      products.value = productDetailResponse.productDetails;
      purchases.value = <PurchaseDetails>[];
      notFoundIds.value = productDetailResponse.notFoundIDs;
      consumables.value = <String>[];
      purchasePending.value = false;
      loading.value = false;
      return;
    }

    final List<String> consumablesStore = await ConsumableStore.load();
    isAvailable.value = isStoreAvailable;
    products.value = productDetailResponse.productDetails;
    notFoundIds.value = productDetailResponse.notFoundIDs;
    consumables.value = consumablesStore;
    purchasePending.value = false;
    loading.value = false;
  }

  /// Metode yang dipanggil saat controller ditutup.
  @override
  void onClose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.onClose();
  }

  // Metode untuk mengonsumsi pembelian.
  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumablesStore = await ConsumableStore.load();
    consumables.value = consumablesStore;
  }

  // Metode untuk menampilkan UI yang sedang menunggu pembelian.
  void showPendingUI() {
    purchasePending.value = true;
  }

  // Metode untuk memberikan produk setelah pembelian berhasil.
  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == productId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumablesStore = await ConsumableStore.load();
      purchasePending.value = false;
      consumables.value = consumablesStore;
    } else {
      purchases.add(purchaseDetails);
      purchasePending.value = false;
    }
  }

  // Metode untuk menangani kesalahan pembelian.
  void handleError(IAPError error) {
    purchasePending.value = false;
  }

  // Metode untuk memverifikasi pembelian.
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  // Metode untuk menangani pembelian yang tidak valid.
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if _verifyPurchase` failed.
  }

  // Metode untuk mendengarkan pembaruan pembelian.
  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == productId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Metode untuk mengonfirmasi perubahan harga.
  Future<void> confirmPriceChange() async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  // // Metode untuk mendapatkan langganan lama.
  GooglePlayPurchaseDetails? getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == productId && purchases[productId] != null) {
      oldSubscription = purchases[productId]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}

// Kelas yang menangani delegasi antrian pembayaran contoh.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
