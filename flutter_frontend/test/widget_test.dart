import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/main.dart';
import 'package:flutter_frontend/features/folders/repository/folder_repository.dart';
import 'package:flutter_frontend/features/documents/repository/document_repository.dart';
import 'package:flutter_frontend/core/services/lock_service.dart';
import 'package:flutter_frontend/data/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MyApp> buildApp({String initialRoute = '/home'}) async {
    // Ensure database is initialized for repositories
    await AppDatabase.instance.initialize();
    final folderRepo = FolderRepository();
    final docRepo = DocumentRepository();
    await folderRepo.initialize();
    await docRepo.initialize();
    final lockService = LockService();

    return MyApp(
      folderRepository: folderRepo,
      documentRepository: docRepo,
      lockService: lockService,
      initialRoute: initialRoute,
    );
  }

  testWidgets('App boots to /home route', (WidgetTester tester) async {
    final app = await buildApp(initialRoute: '/home');
    await tester.pumpWidget(app);
    // Expect our placeholder Home screen text to be visible
    expect(find.text('Home - Folders Overview'), findsOneWidget);
  });

  testWidgets('App boots to /lock route', (WidgetTester tester) async {
    final app = await buildApp(initialRoute: '/lock');
    await tester.pumpWidget(app);
    expect(find.text('Locked - authenticate to continue'), findsOneWidget);
  });
}
