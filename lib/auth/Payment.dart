import 'package:apollodemo1/auth/user_profile/freeplan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

void main() => runApp(const MySample());

class MySample extends StatefulWidget {
  const MySample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MySampleState();
}

class MySampleState extends State<MySample> {
  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Flutter Credit Card View Demo',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        textTheme: const TextTheme(
          // Text style for text fields' input.
          headline6: TextStyle(color: Colors.black, fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      darkTheme: ThemeData(
        textTheme: const TextTheme(
          headline6:
              TextStyle(color: Color.fromARGB(255, 89, 33, 243), fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.white),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(
                    isLightTheme ? 'assets/bg-light.png' : 'assets/bg-dark.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyWidget()));
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            isLightTheme = !isLightTheme;
                          }),
                          icon: Icon(
                            isLightTheme ? Icons.light_mode : Icons.dark_mode,
                          ),
                        ),
                      ],
                    ),
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: true,
                      onCreditCardWidgetChange: (CreditCardBrand cardBrand) {},
                      frontCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      backCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      cardBgColor: isLightTheme
                          ? AppColors.cardBgLightColor
                          : AppColors.cardBgColor,
                      backgroundImage:
                          useBackgroundImage ? 'assets/card_bg.png' : null,
                      isSwipeGestureEnabled: true,
                      customCardTypeIcons: [
                        CustomCardTypeIcon(
                          cardType: CardType.unionpay,
                          cardImage: Image.asset(
                            "assets/images/credit.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                ),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Glassmorphism'),
                                  const Spacer(),
                                  Switch(
                                    value: useGlassMorphism,
                                    inactiveTrackColor: Colors.grey,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.colorE5D1B2,
                                    onChanged: (bool value) => setState(() {
                                      useGlassMorphism = value;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Card Image'),
                                  const Spacer(),
                                  Switch(
                                    value: useBackgroundImage,
                                    inactiveTrackColor: Colors.grey,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.colorE5D1B2,
                                    onChanged: (bool value) => setState(() {
                                      useBackgroundImage = value;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Floating Card'),
                                  const Spacer(),
                                  Switch(
                                    value: useFloatingAnimation,
                                    inactiveTrackColor: Colors.grey,
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.colorE5D1B2,
                                    onChanged: (bool value) => setState(() {
                                      useFloatingAnimation = value;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      AppColors.colorB58D67,
                                      AppColors.colorB58D67,
                                      AppColors.colorE5D1B2,
                                      AppColors.colorF9EED2,
                                      AppColors.colorEFEFED,
                                      AppColors.colorF9EED2,
                                      AppColors.colorB58D67,
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'halter',
                                    fontSize: 14,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reference to Firestore
        CollectionReference cardCollection =
            FirebaseFirestore.instance.collection('cards');

        // Add card details to Firestore
        cardCollection.add({
          'userId': user.uid,
          'cardNumber': cardNumber,
          'cardHolderName': cardHolderName,
          'timestamp':
              FieldValue.serverTimestamp(), // Use FieldValue for timestamp
        });
      } else {
        // Handle the case when the user is not authenticated
        print('User not authenticated');
      }
    } else {
      print('invalid!');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

class AppColors {
  static const Color cardBgLightColor = Color(0xFFF0F0F0);
  static const Color cardBgColor = Color(0xFF212121);
  static const Color colorB58D67 = Color(0xFFB58D67);
  static const Color colorE5D1B2 = Color(0xFFE5D1B2);
  static const Color colorF9EED2 = Color(0xFFF9EED2);
  static const Color colorEFEFED = Color(0xFFEFEFED);
}

class Glassmorphism {
  final double blurX;
  final double blurY;
  final LinearGradient? gradient;

  Glassmorphism({
    required this.blurX,
    required this.blurY,
    this.gradient,
  });

  factory Glassmorphism.defaultConfig() {
    return Glassmorphism(blurX: 8.0, blurY: 16.0);
  }
}
