import 'package:flutter/cupertino.dart';

import '../models/getAllMember.dart';
import 'member_service.dart';

class MembersProvider extends ChangeNotifier {
  final MemberService service;

  MembersProvider(this.service);

  List<Members> _members = [];
  bool _loaded = false;

  List<Members> get members => _members;

  Future<void> load() async {
    if (_loaded) return;

    _members = await service.getMembers(limit: 500);
    _loaded = true;
    notifyListeners();
  }
}
