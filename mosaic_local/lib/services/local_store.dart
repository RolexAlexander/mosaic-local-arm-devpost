import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

class LocalStore {
  static const _brandKey = 'mosaic.brand';
  static const _campaignsKey = 'mosaic.campaigns';

  Future<void> saveBrand(BrandProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brandKey, jsonEncode(profile.toJson()));
  }

  Future<BrandProfile?> loadBrand() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_brandKey);
    if (value == null) return null;
    return BrandProfile.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<List<Campaign>> loadCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_campaignsKey);
    if (value == null) return [];
    return (jsonDecode(value) as List)
        .map((item) => Campaign.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCampaign(Campaign campaign) async {
    final campaigns = await loadCampaigns();
    campaigns.removeWhere((item) => item.id == campaign.id);
    campaigns.insert(0, campaign);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _campaignsKey,
      jsonEncode(campaigns.map((item) => item.toJson()).toList()),
    );
  }
}

