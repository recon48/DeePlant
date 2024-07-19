//
//
// 데이터 추가 페이지 (ViewModel) : Researcher
//
//

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure/dataSource/remote_data_source.dart';
import 'package:structure/model/meat_model.dart';
import 'package:structure/screen/data_management/researcher/add_deep_aging_data_screen.dart';
import 'package:structure/viewModel/data_management/researcher/add_deep_aging_data_view_model.dart';

class DataAddHomeViewModel with ChangeNotifier {
  MeatModel meatModel;
  DataAddHomeViewModel(this.meatModel) {
    _initialize();
  }

  bool isLoading = false;

  bool infoCheck = false;

  // 필드 값 표현 변수
  String userName = '-';
  String butcheryDate = '-';
  String species = '-';
  String secondary = '-';

  String total = '-';

  // 초기 값 할당 (육류 정보 데이터)
  void _initialize() async {
    if (meatModel.userName != null) {
      dynamic user = await RemoteDataSource.getUserInfo(meatModel.userName!);
      userName = user['name'];
    } else {
      userName = '-';
    }

    butcheryDate = meatModel.butcheryYmd ?? '-';
    species = meatModel.speciesValue ?? '-';
    secondary = meatModel.secondaryValue ?? '-';
    _setTotal();

    notifyListeners();
  }

  // 딥에이징 데이터 삭제
  Future<void> deleteList(int idx) async {
    isLoading = true;
    notifyListeners();
    try {
      int deepAgeIdx = int.parse(
          meatModel.deepAgingData![idx]["deepAgingNum"].split('회')[0]);
      dynamic response =
          await RemoteDataSource.deleteDeepAging(meatModel.meatId!, deepAgeIdx);
      if (response == null) {
        throw Error();
      } else {
        meatModel.deepAgingData!.removeAt(idx);
      }
    } catch (e) {
      print("에러발생: $e");
    }
    _setTotal();
    isLoading = false;
    notifyListeners();
  }

  // 딥 에이징 데이터 추가
  void addDeepAgingData(BuildContext context) {
    isLoading = true;
    notifyListeners();

    // 위젯을 누를 때, 아래 기능이 작동 : 페이지 이동
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) =>
                AddDeepAgingDataViewModel(meatModel: meatModel),
            child: const AddDeepAgingDataScreen(),
          ),
        )).then((value) async {
      _setTotal();
      dynamic response = await RemoteDataSource.getMeatData(meatModel.meatId!);
      if (response == null) throw Error();
      meatModel.reset();
      meatModel.fromJson(response);
      isLoading = false;
      notifyListeners();
    });
  }

  bool? infoCheckFunc() {
    if (meatModel.rawmeatDataComplete == true) infoCheck = true;
    return infoCheck;
  }

  // 처리육 총 결산
  void _setTotal() {
    int totalMinutes = meatModel.deepAgingData!
        .map((item) => item['minute'] as int)
        .fold(0, (sum, minute) => sum + minute);

    total = '${meatModel.deepAgingData!.length}회 / $totalMinutes분';
  }

  // 원육 필드를 누를 때 작동 : 데이터 할당
  Future<void> clickedRawMeat(BuildContext context) async {
    dynamic response = await RemoteDataSource.getMeatData(meatModel.meatId!);
    if (response == null) throw Error();
    meatModel.reset();
    meatModel.fromJson(response);
    meatModel.fromJsonAdditional('RAW');
    meatModel.seqno = 0;
    if (context.mounted) {
      context.go('/home/data-manage-researcher/add/raw-meat');
    }
  }

  late BuildContext _context;

  // 처리육 필드를 누를 때 작동 : 데이터 할당
  Future<void> clickedProcessedMeat(int idx, BuildContext context) async {
    dynamic response = await RemoteDataSource.getMeatData(meatModel.meatId!);
    print('meat response : $response');
    // Map<String, dynamic> data = jsonDecode(response);
    // deepaging_data 추출
    var deepAgingData =
        response['processedmeat']['1회']['sensory_eval']['deepaging_data'];

    // deepaging_data 출력
    print('deepaging_data: $deepAgingData');
    if (response == null) throw Error();
    meatModel.reset();
    meatModel.fromJson(response);
    meatModel.fromJsonAdditional(meatModel.deepAgingData![idx]["deepAgingNum"]);
    meatModel.seqno = idx + 1;
    _context = context;
    _movePage();
  }

  void _movePage() {
    _context.go('/home/data-manage-researcher/add/processed-meat');
  }
}
