import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TextGeometryExample(),
    );
  }
}

class TextGeometryExample extends StatefulWidget {
  const TextGeometryExample({super.key});

  @override
  State<TextGeometryExample> createState() => _TextGeometryExampleState();
}

class _TextGeometryExampleState extends State<TextGeometryExample> {
  final GlobalKey textKey = GlobalKey();
  Size size = const Size(0, 0);

  @override
  void initState() {
    super.initState();

    /// Добавляем [postFrameCallback] в [SchedulerBinding]
    /// Он вызовется после отрисовки текущего кадра, в частности после
    /// отрисовки текста с [GlobalKey] = [textKey].
    ///
    /// Размеры виджета text будут известны
    /// в момент исполнения [_changeAnimatedContainerDimensions],
    /// тк он вызывается ПОСЛЕ отрисовки кадра, т.е. размер текста будет посчитан
    SchedulerBinding.instance
        .addPostFrameCallback(_changeAnimatedContainerDimensions);

    /// Аналогичного результата можно достичь используя Future api
    /// и геттер [endOfFrame] у [SchedulerBinding].
    ///
    /// Future будет завершен тогда, когда завершится отрисовка текущего кадра
    ///
    /// Пример:
    /// SchedulerBinding.instance.endOfFrame
    ///     .then((_) => _changeAnimatedContainerDimensions());
  }

  void _changeAnimatedContainerDimensions(
      [Duration? postframeCallbackDuration]) {
    /// Получаем [RenderObject] который относится к виджету Text.
    /// После отрисовки в нем есть информация о геометрии виджета.
    RenderBox logoBox = textKey.currentContext!.findRenderObject() as RenderBox;

    /// Получаем размер
    size = Size(
      logoBox.size.width + 5,
      logoBox.size.height + 5,
    );

    /// Обновляем стейт. Изменения размера [size] спровоцирует анимацию у [AnimatedContainer]
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /// [Stack] используется намеренно, чтобы продемонстрировать возможность
    /// получить размер виджета, расположенного параллельно в дереве.
    ///
    /// Данного эффекта можно добиться и не используя [postFrameCallback]
    return Scaffold(
      body: Stack(
        children: [
          /// Контейнер с конкретным размером. Ожидается что в переменной size
          /// будет размер текста, расположенного ниже по стеку.
          ///
          /// Текст в виджете ниже может быть произвольный и на момент верстки
          /// мы не можем точно знать его размер.
          Center(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.bounceInOut,
              width: size.width,
              height: size.height,
              color: Colors.amber,
            ),
          ),
          Center(
            child: Text(
              key: textKey,
              'Динамический текст',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
