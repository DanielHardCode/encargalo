import 'package:encargalo/screens/formulario_screen.dart';
import 'package:encargalo/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Draft recovery does not require SQLite or a platform database plugin.
class DraftAppState extends AppState {
  @override
  Future<void> cargar() async {}
}

void main() {
  testWidgets('new request restores every draft field after background save', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final original = DraftAppState();
    await original.init();
    addTearDown(original.dispose);
    final initialDate = DateTime.now().add(const Duration(days: 14));
    final selectedDate = initialDate.day > 1
        ? initialDate.subtract(const Duration(days: 1))
        : initialDate.add(const Duration(days: 1));
    final expectedDate = selectedDate.toIso8601String().substring(0, 10);

    Future<DraftAppState> rebuildForm() async {
      await tester.pumpWidget(const SizedBox.shrink());
      final state = DraftAppState();
      await state.init();
      addTearDown(state.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: FormularioScreen()),
        ),
      );
      await tester.pumpAndSettle();
      return state;
    }

    await rebuildForm();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Polos del equipo');
    await tester.enterText(fields.at(1), 'Bordado azul en ambas caras');
    await tester.enterText(fields.at(2), '27');
    await tester.enterText(fields.at(3), 'Castilla');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bordado').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.event));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${selectedDate.day}').last);
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final addPhoto = find.byType(ActionChip).last;
    await tester.tap(addPhoto);
    await tester.pump();
    await tester.tap(addPhoto);
    await tester.pump();
    final savedPhotos = tester
        .widgetList<Chip>(find.byType(Chip))
        .map((chip) => (chip.label as Text).data!)
        .toList();

    // Call the public observer callback and await its persistence work.
    final dynamic observer = tester.state(find.byType(FormularioScreen));
    await tester.runAsync(() async {
      await observer.didChangeAppLifecycleState(AppLifecycleState.paused);
    });

    await rebuildForm();
    final restoredFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(restoredFields.map((field) => field.controller!.text), [
      'Polos del equipo',
      'Bordado azul en ambas caras',
      '27',
      'Castilla',
    ]);
    final restoredCategory = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(restoredCategory.value, 'Bordado');
    expect(find.text('Fecha deseada: $expectedDate'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Fotos (2/3)'), findsOneWidget);
    for (final photo in savedPhotos) {
      expect(find.text(photo), findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
