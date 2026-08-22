import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';
import '../../helpers/viewmodel_mocks.dart';

import '../../fixtures/node_fixtures.dart';

void main() {
  late MdEditorViewModel vm;

  setUp(() {
    vm = createTestMdEditorViewModel();
  });

  group('MdEditorViewModel - Load Node', () {
    test("Text opens correctly when loading a fragment Node", () {
      final node = buildTestNode(
        id: "node_1",
        fields: {"front": "Fragment content"},
        type: "fragment",
        collectionId: "col_1",
      );

      vm.loadNode(node);

      expect(vm.content, "Fragment content");
      expect(vm.isDirty, isFalse);
      expect(vm.isEditing, isFalse);
      expect(vm.isAnswerVisible, isFalse);
    });

    test("Text clears correctly when loading a null Node", () {
      vm.updateContentLazy(() => "Previous text");
      
      vm.loadNode(null);

      expect(vm.content, isEmpty);
      expect(vm.isDirty, isFalse);
      expect(vm.node, isNull);
    });
  });

  group('MdEditorViewModel - Selection and Cursor', () {
    test("Selection correctly enables hasSelection", () {
      vm.onSelectionChanged(() => 5, () => 10, true);

      expect(vm.hasSelection, isTrue);
      expect(vm.cursorPosition, 10);
      expect(vm.selection?.baseOffset, 5);
      expect(vm.selection?.extentOffset, 10);
    });

    test("Cursor without selection disables hasSelection", () {
      vm.onSelectionChanged(() => 15, () => 15, false);

      expect(vm.hasSelection, isFalse);
      expect(vm.cursorPosition, 15);
      expect(vm.selection, isNull);
    });
  });
}
