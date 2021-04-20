import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants_helper.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/orders_helper.dart';
import '../../helpers/snackbar_helper.dart';
import '../../providers/carts_data.dart';

/// Displays page for getting shipping details.
class ShippingDetailsPage extends StatefulWidget {
  @override
  _ShippingDetailsPageState createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
  bool isLoading = false;
  String _address = '', _userAddress = '', _userState = 'Gujarat';
  final _addressController = TextEditingController();

  User get user => FirebaseAuth.instance.currentUser;

  /// Fetches and sets the default shipping address of the user.
  void setDefaultAddress() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Addresses')
        .where('isDefault', isEqualTo: true)
        .get();
    if (snapshot.docs.isEmpty)
      setState(() => _address =
          'No default address available.\n Please add default address from profile menu.');
    setState(() => _address =
        '${snapshot.docs.first.get('address')}, ${snapshot.docs.first.get('state')}, India.');
  }

  @override
  void initState() {
    super.initState();
    setDefaultAddress();
  }

  /// Adds a new address to the database.
  void submit() async {
    if (_userAddress == '') return;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Addresses')
        .add({
      'isDefault': false,
      'address': _userAddress,
      'state': _userState,
    }).whenComplete(() {
      _addressController.clear();
      _userAddress = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartsData = Provider.of<CartsData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Details')),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        physics: const BouncingScrollPhysics(),
        children: [
          buildHeadingDataPair(
            heading: 'Ship to',
            data: user.displayName,
            theme: theme,
          ),
          buildHeadingDataPair(
            heading: 'Shipping address',
            data: _address,
            theme: theme,
          ),
          buildHeadingDataPair(
            heading: 'Choose shipping address',
            data: '',
            theme: theme,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('Addresses')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              final docs = snapshot.data?.docs ?? [];
              return Column(
                children: docs
                    .map(
                      (doc) => RadioListTile(
                        activeColor: Colors.blueAccent,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value:
                            '${doc.get('address')}, ${doc.get('state')}, India.',
                        groupValue: _address,
                        onChanged: (value) => setState(() => _address = value),
                        title: Text(
                          '${doc.get('address')}, ${doc.get('state')}, India.',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          buildHeadingDataPair(
            heading: 'Add new address',
            data: '',
            theme: theme,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            cursorColor: theme.accentColor,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_city_outlined),
              hintText: 'Address',
              border: border(),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              contentPadding: contentPadding(),
            ),
            minLines: 1,
            maxLines: 3,
            onChanged: (value) => _userAddress = value,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: border(),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
            ),
            items: Constants.states
                .map(
                  (state) => DropdownMenuItem(child: Text(state), value: state),
                )
                .toList(),
            value: _userState,
            onChanged: (value) => _userState = value,
            onTap: () => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: submit,
            child: const Text('Add address'),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: isLoading
            ? LinearProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'Cancel Order',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(primary: Colors.redAccent),
                    onPressed: () async {
                      setState(() => isLoading = true);
                      var clear = await DialogHelper.showAlertDialog(
                        context,
                        'Are you sure?',
                        'All items from cart will be removed. This action can\'t be undone.',
                      );
                      if (clear == null) {
                        setState(() => isLoading = false);
                        return;
                      }
                      if (clear) {
                        cartsData.clear();
                        Navigator.of(context).pop();
                      }
                      setState(() => isLoading = false);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text(
                      'Place Order',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: cartsData.cartItems.isEmpty ||
                            _address ==
                                'No default address available.\n Please add default address from profile menu.'
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            try {
                              await OrdersHelper.placeOrder(
                                cartsData.cartItems,
                                cartsData.totalAmount,
                                _address,
                              );
                              cartsData.clear();
                              setState(() => isLoading = false);
                              SnackBarHelper.showSnackBar(
                                context,
                                'Your order has been placed successfully',
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              SnackBarHelper.showSnackBar(
                                context,
                                'Something went wrong. Check your network and try again.',
                              );
                            }
                          },
                  ),
                ],
              ),
      ),
    );
  }

  EdgeInsets contentPadding() {
    return const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    );
  }

  /// Displays heading of a section.
  Text buildSectionTitle({String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Displays heading and data for the section details.
  Text buildHeadingDataPair({String heading, String data, ThemeData theme}) {
    return Text.rich(
      TextSpan(
        text: '$heading: ',
        children: [
          TextSpan(
            text: data,
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
      style: TextStyle(
        fontSize: 17.0,
        color: Colors.blue,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
