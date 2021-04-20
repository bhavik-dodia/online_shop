import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../helpers/snackbar_helper.dart';
import '../../models/menu_item.dart';
import '../../providers/carts_data.dart';
import '../../screens/orders/orders_page.dart';
import '../../widgets/auth/google_log_in.dart';
import '../../widgets/profile/update_profile.dart';
import 'menu_tile.dart';

/// Displays the hidden menu containing user profile and application navigation options.
class Menu extends StatelessWidget {
  final Function manageDrawer;
  Menu({
    Key key,
    @required Animation<Offset> slideAnimation,
    @required Animation<double> menuScaleAnimation,
    this.manageDrawer,
  })  : _slideAnimation = slideAnimation,
        _menuScaleAnimation = menuScaleAnimation,
        super(key: key);

  final Animation<Offset> _slideAnimation;
  final Animation<double> _menuScaleAnimation;

  final List<MenuItem> _menuItems = [
    MenuItem(
      iconData: Icons.home_rounded,
      name: 'Home',
      action: (context) {},
    ),
    MenuItem(
      iconData: Icons.payment_rounded,
      name: 'Orders',
      action: (context) =>
          Navigator.of(context).pushNamed(OrdersPage.routeName),
    ),
    MenuItem(
      iconData: Icons.person_rounded,
      name: 'Profile',
      action: (context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        builder: (context) => UpdateProfile(),
      ),
    ),
    MenuItem(
      iconData: Icons.logout,
      name: 'Logout',
      action: (context) {
        SnackBarHelper.showSnackBar(
            context, 'Saving cart items, please wait...');
        Provider.of<CartsData>(context, listen: false).saveCartItems();
        GoogleLogIn.signOut();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData)
                  FirebaseAuth.instance.currentUser.updateProfile(
                    displayName: snapshot.data.get('name'),
                    photoURL: snapshot.data.get('imageUrl'),
                  );
                return UserAccountsDrawerHeader(
                  onDetailsPressed: () {
                    manageDrawer();
                    return showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        ),
                      ),
                      builder: (context) => UpdateProfile(),
                    );
                  },
                  decoration: BoxDecoration(color: Colors.transparent),
                  accountName: snapshot.hasData
                      ? Text(
                          snapshot.data.get('name'),
                          style: GoogleFonts.laila(
                            color: Colors.blueAccent,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : FractionallySizedBox(
                          heightFactor: 0.3,
                          widthFactor: 0.4,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                  accountEmail: snapshot.hasData
                      ? Text(
                          snapshot.data.get('email'),
                          style: GoogleFonts.laila(color: Colors.blueAccent),
                        )
                      : FractionallySizedBox(
                          heightFactor: 0.3,
                          widthFactor: 0.5,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                  currentAccountPicture: snapshot.hasData
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data.get('imageUrl'),
                          ),
                        )
                      : const CircleAvatar(
                          child: const Icon(Icons.person_rounded)),
                );
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 0.6 * MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final menuitem = _menuItems[index];
                    return MenuTile(
                      icon: menuitem.iconData,
                      title: menuitem.name,
                      isSelected: index == 0 ? true : false,
                      onTap: () {
                        manageDrawer();
                        menuitem.action(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
