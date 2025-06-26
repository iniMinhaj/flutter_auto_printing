import 'package:auto_printing/data/repository/setting_repo.dart';
import 'package:auto_printing/model/setting_model.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  final SettingRepo _settingRepo = SettingRepo();
  final settingModel = SettingModel().obs;

  Future<void> getSettings() async {
    final result = await _settingRepo.getSettings();
    result.fold((error) {}, (orders) {
      settingModel.value = orders;
    });
  }
}
