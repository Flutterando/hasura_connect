class ModelData {
  int userId;
  String userEmail;
  String userPassword;

  ModelData({this.userId, this.userEmail, this.userPassword});

  ModelData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userEmail = json['user_email'] ;
    userPassword = json['user_password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_email'] = this.userEmail;
    data['user_password'] = this.userPassword;
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "ModelData: $userEmail";
  }

}