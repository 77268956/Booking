import 'package:flutter_test/flutter_test.dart';

import 'package:login/controller/login_controller.dart';
import 'package:login/main.dart';

void main() {
  test('LoginController valida las credenciales registradas', () async {
    const controller = LoginController();

    expect(
      await controller.authenticate('usuario@correo.com', '123456'),
      isTrue,
    );
    expect(await controller.authenticate('ana@correo.com', '654321'), isTrue);
    expect(await controller.authenticate('otro@correo.com', '123456'), isFalse);
  });

  testWidgets('LoginPage muestra error si el formulario está vacío', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Crear cuenta'), findsOneWidget);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('LoginPage navega a la vista de crear cuenta', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Registrarme'), findsOneWidget);
  });
}
