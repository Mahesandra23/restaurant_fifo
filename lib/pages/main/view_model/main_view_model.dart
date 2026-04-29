import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/main/repositories/main_repository.dart';

class MainViewModel extends BaseViewModel {
  final MainRepository _repository;

  MainViewModel(this._repository);
}
