import '../bloc/anasayfa_bloc.dart';
import 'package:flutter/material.dart';

class AnasayfaBlocProvider extends InheritedWidget {
  final AnasayfaBloc anasayfaBloc;
  const AnasayfaBlocProvider({Key key, Widget child, this.anasayfaBloc})
      : super(child: child, key: key);

  static AnasayfaBlocProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(AnasayfaBlocProvider old) => false;
}
