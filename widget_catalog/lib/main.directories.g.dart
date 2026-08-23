// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widget_catalog/main.dart' as _widget_catalog_main;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'ui',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'layouts',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AdaptativeScaffold',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _widget_catalog_main.adaptativeScaffold,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'MyAppBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _widget_catalog_main.myAppBar,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
