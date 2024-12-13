class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final AccountInfo accountInfo;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accountInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    accountInfo: AccountInfo.fromJson(json['account_info']),
  );
}

class AccountInfo {
  final String id;
  final String name;
  final String tagLine;
  final String logo;
  final String placeHolderImage;

  AccountInfo({
    required this.id,
    required this.name,
    required this.tagLine,
    required this.logo,
    required this.placeHolderImage,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    tagLine: json['tag_line'] ?? '',
    logo: json['logo'] ?? '',
    placeHolderImage: json['place_holder_image'] ?? '',
  );
} 