import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

main() {
  test('Generate uuid', () {
    var uuid = Uuid();
    print(uuid.v5(Uuid.NAMESPACE_URL, 'ferfweiofjpijeprwfihpaeigrpoijaeprgohipgirhpaihrgpoihaperhpoihpoihgpihjrv0´9u09jpaeirghpihdpvinaeprghpaohp89j409jpevjpjpjep5g9jpé9gj´9ejrzgpíjfpvkmpíoj0´9jergpíjdz´fj´zejrt´9jg0´9je´rz09j´09zfjgó9jzdf´gojpeirzgjnlçdkznvçkndpzçiopçdziogpiojrgpoijpofivjonfvionoivefv'));
    print(uuid.v5(Uuid.NAMESPACE_URL, 'ferfweiofjpijeprwfihpaeigrpoijaeprgohipgirhpaihrgpoihaperhpoihpoihgpihjrv0´9u09jpaeirghpihdpvinaeprghpaohp89j409jpevjpjpjep5g9jpé9gj´9ejrzgpíjfpvkmpíoj0´9jergpíjdz´fj´zejrt´9jg0´9je´rz09j´09zfjgó9jzdf´gojpeirzgjnlçdkznvçkndpzçiopçdziogpiojrgpoijpofivjonfvionoivefv'));
    print(uuid.v5(Uuid.NAMESPACE_URL, 'ferfweiofjpijeprwfihpaeigrpoijaeprgohipgirhpaihrgpoihaperhpoihpoihgpihjrv0´9u09jpaeirghpihdpvinaeprghpaohp89j409jpevjpjpjep5g9jpé9gj´9ejrzgpíjfpvkmpíoj0´9jergpíjdz´fj´zejrt´9jg0´9je´rz09j´09zfjgó9jzdf´gojpeirzgjnlçdkznvçkndpzçiopçdziogpiojrgpoijpofivjonfvionoivefv'));
  });
}
