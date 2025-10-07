import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @login_header.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get login_header;

  /// No description provided for @login_subheader.
  ///
  /// In en, this message translates to:
  /// **'You`ve been missed'**
  String get login_subheader;

  /// No description provided for @login_button_label.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_button_label;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @already_have_account_link.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get already_have_account_link;

  /// No description provided for @dont_have_acocunt.
  ///
  /// In en, this message translates to:
  /// **'Dont have an account?'**
  String get dont_have_acocunt;

  /// No description provided for @dont_have_acocunt_link.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dont_have_acocunt_link;

  /// No description provided for @signup_header.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get signup_header;

  /// No description provided for @signup_subheader.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get signup_subheader;

  /// No description provided for @signup_button_label.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup_button_label;

  /// No description provided for @navigator_label_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigator_label_home;

  /// No description provided for @navigator_label_promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get navigator_label_promo;

  /// No description provided for @navigator_label_shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navigator_label_shop;

  /// No description provided for @navigator_label_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navigator_label_activity;

  /// No description provided for @navigator_label_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navigator_label_account;

  /// No description provided for @home_welcome_word.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get home_welcome_word;

  /// No description provided for @home_location_word.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get home_location_word;

  /// No description provided for @home_search_word.
  ///
  /// In en, this message translates to:
  /// **'Find you needed'**
  String get home_search_word;

  /// No description provided for @home_produk_slider_title.
  ///
  /// In en, this message translates to:
  /// **'Best Deal'**
  String get home_produk_slider_title;

  /// No description provided for @home_produk_slider_title_new_items.
  ///
  /// In en, this message translates to:
  /// **'New Items'**
  String get home_produk_slider_title_new_items;

  /// No description provided for @home_produk_slder_more.
  ///
  /// In en, this message translates to:
  /// **'see all'**
  String get home_produk_slder_more;

  /// No description provided for @category_fruits_vegetables.
  ///
  /// In en, this message translates to:
  /// **'Fruits and Vegetables'**
  String get category_fruits_vegetables;

  /// No description provided for @category_drink.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get category_drink;

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get category_food;

  /// No description provided for @category_home_supplies.
  ///
  /// In en, this message translates to:
  /// **'Home Supplies'**
  String get category_home_supplies;

  /// No description provided for @category_kitchen_supplies.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Supplies'**
  String get category_kitchen_supplies;

  /// No description provided for @category_health_essentials.
  ///
  /// In en, this message translates to:
  /// **'Health Essentials'**
  String get category_health_essentials;

  /// No description provided for @category_parcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel Products'**
  String get category_parcel;

  /// No description provided for @category_choose_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get category_choose_title;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search Produk'**
  String get search_hint;

  /// No description provided for @activity_title.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity_title;

  /// No description provided for @activity_tab_title_shopping_list.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get activity_tab_title_shopping_list;

  /// No description provided for @activity_tab_title_history.
  ///
  /// In en, this message translates to:
  /// **'Purchasing history'**
  String get activity_tab_title_history;

  /// No description provided for @activity_budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get activity_budget;

  /// No description provided for @activity_clear_items.
  ///
  /// In en, this message translates to:
  /// **'Clear items'**
  String get activity_clear_items;

  /// No description provided for @activity_add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get activity_add_to_cart;

  /// No description provided for @activity_clear_items_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Clear Items'**
  String get activity_clear_items_modal_title;

  /// No description provided for @activity_clear_items_modal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all the items?'**
  String get activity_clear_items_modal_subtitle;

  /// No description provided for @activity_clear_items_modal_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get activity_clear_items_modal_confirm;

  /// No description provided for @activity_clear_items_modal_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get activity_clear_items_modal_cancel;

  /// No description provided for @activity_empty.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get activity_empty;

  /// No description provided for @activity_to_cart_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Empty the cart?'**
  String get activity_to_cart_modal_title;

  /// No description provided for @activity_to_cart_modal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'All Items in the cart will be deleted'**
  String get activity_to_cart_modal_subtitle;

  /// No description provided for @activity_to_cart_modal_confirm.
  ///
  /// In en, this message translates to:
  /// **'Don`t'**
  String get activity_to_cart_modal_confirm;

  /// No description provided for @activity_to_cart_modal_cancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Clear first'**
  String get activity_to_cart_modal_cancel;

  /// No description provided for @activity_budget_change_title.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get activity_budget_change_title;

  /// No description provided for @activity_budget_change_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Rp 100.000'**
  String get activity_budget_change_hint;

  /// No description provided for @activity_budget_change_button.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get activity_budget_change_button;

  /// No description provided for @account_help_title.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get account_help_title;

  /// No description provided for @account_about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get account_about_title;

  /// No description provided for @account_about_language.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get account_about_language;

  /// No description provided for @account_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get account_logout;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart_title;

  /// No description provided for @cart_payments_title.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get cart_payments_title;

  /// No description provided for @cart_payments_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cart_payments_subtotal;

  /// No description provided for @cart_payments_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cart_payments_discount;

  /// No description provided for @cart_payments_total_payment.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get cart_payments_total_payment;

  /// No description provided for @cart_checkout_button_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cart_checkout_button_title;

  /// No description provided for @cart_checkout_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cart_checkout_modal_title;

  /// No description provided for @cart_checkout_modal_method_title.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get cart_checkout_modal_method_title;

  /// No description provided for @cart_checkout_modal_method_subtitle.
  ///
  /// In en, this message translates to:
  /// **'choose a method'**
  String get cart_checkout_modal_method_subtitle;

  /// No description provided for @cart_checkout_modal_method_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a Method'**
  String get cart_checkout_modal_method_tab_title;

  /// No description provided for @cart_checkout_modal_method_tab_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get cart_checkout_modal_method_tab_choose;

  /// No description provided for @cart_checkout_modal_total_payment.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get cart_checkout_modal_total_payment;

  /// No description provided for @cart_checkout_modal_by_placing.
  ///
  /// In en, this message translates to:
  /// **'By placing an order you agree to our'**
  String get cart_checkout_modal_by_placing;

  /// No description provided for @cart_checkout_modal_terms_condition.
  ///
  /// In en, this message translates to:
  /// **'Terms And Conditions'**
  String get cart_checkout_modal_terms_condition;

  /// No description provided for @cart_checkout_modal_button.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get cart_checkout_modal_button;

  /// No description provided for @favorite_title.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite_title;

  /// No description provided for @product_detail_add_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get product_detail_add_cart;

  /// No description provided for @product_detail_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get product_detail_location;

  /// No description provided for @product_detail_desc.
  ///
  /// In en, this message translates to:
  /// **'Products Details'**
  String get product_detail_desc;

  /// No description provided for @product_detail_modal_budget_title.
  ///
  /// In en, this message translates to:
  /// **'Set a budget'**
  String get product_detail_modal_budget_title;

  /// No description provided for @product_detail_modal_budget_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Rp 100.000'**
  String get product_detail_modal_budget_hint;

  /// No description provided for @product_detail_modal_budget_button.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get product_detail_modal_budget_button;

  /// No description provided for @scan_title.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scan_title;

  /// No description provided for @scan_field_hint.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode or input SKU'**
  String get scan_field_hint;

  /// No description provided for @branch_select_sheet.
  ///
  /// In en, this message translates to:
  /// **'Select Store Branch'**
  String get branch_select_sheet;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get history_title;

  /// No description provided for @history_order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get history_order_number;

  /// No description provided for @history_total_payment.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get history_total_payment;

  /// No description provided for @history_order_date.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get history_order_date;

  /// No description provided for @history_method_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get history_method_title;

  /// No description provided for @history_order_details_title.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get history_order_details_title;

  /// No description provided for @history_invoice_title.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get history_invoice_title;

  /// No description provided for @history_invoice_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice will be saved as PDF'**
  String get history_invoice_subtitle;

  /// No description provided for @history_invoice_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get history_invoice_cancel;

  /// No description provided for @history_invoice_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get history_invoice_confirm;

  /// No description provided for @favorite_is_empty.
  ///
  /// In en, this message translates to:
  /// **'No favorite items yet.'**
  String get favorite_is_empty;

  /// No description provided for @history_is_empty.
  ///
  /// In en, this message translates to:
  /// **'You haven`t shopped yet.'**
  String get history_is_empty;

  /// No description provided for @activity_create_title.
  ///
  /// In en, this message translates to:
  /// **'Start Making Lists'**
  String get activity_create_title;

  /// No description provided for @activity_saved_invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved in download'**
  String get activity_saved_invoice;

  /// No description provided for @cart_is_empty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_is_empty;

  /// No description provided for @location_not_found.
  ///
  /// In en, this message translates to:
  /// **'This item is not available at this store branch'**
  String get location_not_found;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
