import 'dart:convert';

import 'package:loyalty/services/fetch_content.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/services/fetch_content.dart';

class ContentRepository {
  final DataContent dataContent;

  ContentRepository({
    required this.dataContent,
  });

  Future<List<Highlight>> getHighlight() async {
    final response = await dataContent.getContents();
    if (response!.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jsonData = json['menuheader'] as List;
      final highlight = jsonData.map((e) => Highlight.fromJson(e)).toList();
      return highlight;
    } else {
      throw Exception('Gagal mengambil data Highlight');
    }
  }

  Future<List<Service>> getService() async {
    final response = await dataContent.getContents();
    if (response!.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jsonData = json['menu1'] as List;
      final service = jsonData.map((e) => Service.fromJson(e)).toList();
      return service;
    } else {
      throw Exception('Gagal mengambil data Service');
    }
  }

  Future<List<Promo>> getPromo() async {
    final response = await dataContent.getContents();
    if (response!.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jsonData = json['menulist'] as List;
      final promo = jsonData.map((e) => Promo.fromJson(e)).toList();
      return promo;
    } else {
      throw Exception('Gagal mengambil data Promo');
    }
  }

  Future<List<Banner>> getBanner() async {
    final response = await dataContent.getContents();
    if (response!.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jsonData = json['banner'] as List;
      final banner = jsonData.map((e) => Banner.fromJson(e)).toList();
      return banner;
    } else {
      throw Exception('Gagal mengambil data Banner');
    }
  }
}
