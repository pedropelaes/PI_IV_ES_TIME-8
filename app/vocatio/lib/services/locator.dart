import 'package:get_it/get_it.dart';
import 'socket/socket_service.dart'; 

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => SocketService());
}