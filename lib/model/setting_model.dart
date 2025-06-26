// To parse this JSON data, do
//
//     final settingModel = settingModelFromJson(jsonString);

import 'dart:convert';

SettingModel settingModelFromJson(String str) =>
    SettingModel.fromJson(json.decode(str));

String settingModelToJson(SettingModel data) => json.encode(data.toJson());

class SettingModel {
  final Data? data;

  SettingModel({this.data});

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class Data {
  final String? companyName;
  final String? themeLogo;
  final String? themeFooterLogo;
  final String? themeFaviconLogo;

  Data({
    this.companyName,
    this.themeLogo,
    this.themeFooterLogo,
    this.themeFaviconLogo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    companyName: json["company_name"],
    themeLogo: json["theme_logo"],
    themeFooterLogo: json["theme_footer_logo"],
    themeFaviconLogo: json["theme_favicon_logo"],
  );

  Map<String, dynamic> toJson() => {
    "company_name": companyName,
    "theme_logo": themeLogo,
    "theme_footer_logo": themeFooterLogo,
    "theme_favicon_logo": themeFaviconLogo,
  };
}
