//
//
// 전자혀 데이터 ViewModel
//
//

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:structure/components/custom_pop_up.dart';
import 'package:structure/dataSource/remote_data_source.dart';
import 'package:structure/model/meat_model.dart';
import 'package:structure/model/user_model.dart';

class InsertionTongueDataViewModel with ChangeNotifier {
  final MeatModel meatModel;
  final UserModel userModel;
  final bool isRaw;
  BuildContext context;
  InsertionTongueDataViewModel(
      this.meatModel, this.userModel, this.isRaw, this.context) {
    _initialize();
  }
  bool isLoading = false;
  String title = '전자혀 데이터';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 컨트롤러
  TextEditingController sourness = TextEditingController();
  TextEditingController bitterness = TextEditingController();
  TextEditingController umami = TextEditingController();
  TextEditingController richness = TextEditingController();

  bool inputComplete = false;

  // 초기 값 할당 (모델에 값이 존재하면 할당)
  void _initialize() {
    isLoading = true;
    notifyListeners();

    if (isRaw) {
      // 원육/처리육
      sourness.text = '${meatModel.probExpt?['sourness'] ?? ''}';
      bitterness.text = '${meatModel.probExpt?['bitterness'] ?? ''}';
      umami.text = '${meatModel.probExpt?['umami'] ?? ''}';
      richness.text = '${meatModel.probExpt?['richness'] ?? ''}';

      if (meatModel.seqno == 0) {
        title = '원육 전자혀 데이터';
      } else {
        title = '처리육 전자혀 데이터';
      }
    } else {
      // 가열육
      sourness.text = '${meatModel.heatedProbExpt?['sourness'] ?? ''}';
      bitterness.text = '${meatModel.heatedProbExpt?['bitterness'] ?? ''}';
      umami.text = '${meatModel.heatedProbExpt?['umami'] ?? ''}';
      richness.text = '${meatModel.heatedProbExpt?['richness'] ?? ''}';

      title = '가열육 전자혀 데이터';
    }

    isLoading = false;
    notifyListeners();
  }

  /// 모든 필드가 입력 되었는지 확인하는 함수
  void inputCheck() {
    inputComplete = sourness.text.isNotEmpty &&
        bitterness.text.isNotEmpty &&
        umami.text.isNotEmpty &&
        richness.text.isNotEmpty &&
        formKey.currentState!.validate();
  }

  // 데이터를 객체에 할당 - 이후 POST
  Future<void> saveData() async {
    isLoading = true;
    notifyListeners();

    // probExpt가 없으면 post로 진행해야 함
    bool isPost = false;

    // 데이터 생성
    if (isRaw) {
      // 원육/처리육
      if (meatModel.probExpt == null) {
        // POST의 경우 신규 데이터 생성
        isPost = true;

        meatModel.probExpt = {};
        meatModel.probExpt!['meatId'] = meatModel.meatId;
        meatModel.probExpt!['userId'] = userModel.userId;
        meatModel.probExpt!['seqno'] = meatModel.seqno;
      }
      // 전자혀 데이터 입력
      meatModel.probExpt!['sourness'] = double.parse(sourness.text);
      meatModel.probExpt!['bitterness'] = double.parse(bitterness.text);
      meatModel.probExpt!['umami'] = double.parse(umami.text);
      meatModel.probExpt!['richness'] = double.parse(richness.text);
    } else {
      // 가열육
      if (meatModel.heatedProbExpt == null) {
        // POST의 경우 신규 데이터 생성
        isPost = true;

        meatModel.heatedProbExpt = {};
        meatModel.heatedProbExpt!['meatId'] = meatModel.meatId;
        meatModel.heatedProbExpt!['userId'] = userModel.userId;
        meatModel.heatedProbExpt!['seqno'] = meatModel.seqno;
      }
      // 전자혀 데이터 입력
      meatModel.heatedProbExpt!['sourness'] = double.parse(sourness.text);
      meatModel.heatedProbExpt!['bitterness'] = double.parse(bitterness.text);
      meatModel.heatedProbExpt!['umami'] = double.parse(umami.text);
      meatModel.heatedProbExpt!['richness'] = double.parse(richness.text);
    }

    // API 전송
    try {
      dynamic response;

      if (isRaw) {
        // 원육/처리육
        if (isPost) {
          response = await RemoteDataSource.createMeatData(
              'probexpt-data', meatModel.toJsonProbExpt());
        } else {
          response = await RemoteDataSource.patchMeatData(
              'probexpt-data', meatModel.toJsonProbExpt());
        }
      } else {
        // 가열육
        if (isPost) {
          response = await RemoteDataSource.createMeatData(
              'probexpt-data', meatModel.toJsonHeatedProbExpt());
        } else {
          response = await RemoteDataSource.patchMeatData(
              'probexpt-data', meatModel.toJsonHeatedProbExpt());
        }
      }

      if (response == 200) {
        if (isRaw) {
          meatModel.updateProbExpt();
        } else {
          meatModel.updateHeatedProbExpt();
        }
      } else {
        throw ErrorDescription(response);
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      debugPrint("Error: $e");
      if (context.mounted) showErrorPopup(context, error: e.toString());
    }

    // 완료 검사
    meatModel.checkCompleted();

    isLoading = false;
    notifyListeners();

    if (context.mounted) context.pop();
  }

  String? validate(String? value, double min, double max) {
    double parsedValue = double.tryParse(value!) ?? 0.0;
    if (parsedValue < min || parsedValue > max) {
      return '$min~$max 사이의 값을 입력하세요.';
    }
    return null;
  }
}
