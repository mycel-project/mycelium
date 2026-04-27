import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/md_area.dart";

class MdEditor extends StatefulWidget {
  @override
  _MdEditorState createState() => _MdEditorState();
}

class _MdEditorState extends State<MdEditor> {
  bool editMode = true;
  String content =
      "# Salut\n ça marche!\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Cras mollis commodo metus finibus tincidunt. Maecenas egestas auctor justo vitae vehicula. Nullam in enim in leo suscipit vehicula pulvinar at purus. Curabitur vehicula nibh sed mi varius, quis condimentum libero venenatis. Suspendisse id ipsum bibendum, pulvinar arcu ut, sodales dolor. Donec sed sodales est, sit amet euismod ex. Nullam placerat diam at facilisis consequat. Pellentesque viverra pulvinar justo, non semper diam. Curabitur tincidunt enim ac mauris consectetur cursus.\n\nProin quis nulla convallis massa dignissim lobortis sed eget nulla. Curabitur sagittis euismod dictum. Integer pharetra dui nec magna posuere, in viverra neque commodo. Aenean sagittis nisi sed urna lobortis, vitae maximus purus convallis. Aliquam nec dolor sapien. Etiam vehicula interdum lectus, condimentum fermentum elit varius id. Aenean eget ornare lacus, a malesuada orci. Cras sed ipsum dignissim, mattis sapien vel, egestas nunc. Ut vitae ante condimentum est maximus ultrices eget a lacus. Proin faucibus nunc sed tortor pulvinar semper. Quisque id pharetra turpis. In dignissim ligula enim, sed sagittis eros tincidunt at. Praesent at nibh dapibus, laoreet lectus id, imperdiet enim. Donec finibus fermentum sodales.\n\nUt eu felis arcu. Morbi ut lectus congue, varius erat vitae, euismod nisl. Suspendisse potenti. Vivamus et ante convallis, mattis diam sit amet, facilisis nibh. Aliquam facilisis bibendum auctor. Aliquam sed pellentesque nulla. Nulla magna enim, ullamcorper non venenatis sit amet, venenatis nec ligula. Fusce dui sapien, auctor at vestibulum ut, suscipit ut ligula. Nullam egestas placerat pretium. Donec sed odio finibus, interdum purus nec, mollis dui. Phasellus tristique tincidunt tellus vel mollis. Praesent commodo nec dui nec molestie. Pellentesque felis est, aliquam eu viverra sit amet, eleifend et magna. Proin in euismod purus. Sed porttitor ut purus ac fermentum. Curabitur elementum, diam in dictum placerat, purus eros imperdiet sem, et condimentum nibh sem sit amet elit.\n\nInteger eu mollis ex. Sed consectetur tristique lectus id condimentum. Nulla feugiat ut neque vitae sodales. Curabitur libero arcu, feugiat ut lorem nec, pharetra rutrum ante. Mauris et sem purus. Praesent condimentum euismod ligula id blandit. Suspendisse quis nisi sagittis, vestibulum mauris ac, commodo arcu. Donec ullamcorper turpis ut ligula condimentum, ac faucibus velit volutpat. Nunc elementum erat nec dui egestas, nec malesuada turpis consectetur. Nullam iaculis ante sem. Quisque consectetur a lacus at euismod. Curabitur vel metus non turpis molestie maximus. Morbi semper euismod leo. Etiam eros massa, bibendum et fermentum id, porta at magna.\n\nEtiam bibendum placerat dolor at bibendum. Pellentesque tincidunt interdum fermentum. Nunc tristique gravida nisl non ornare. Phasellus facilisis lorem nec aliquam volutpat. Nullam mattis pulvinar luctus. Mauris lacus enim, venenatis sit amet blandit non, blandit sit amet elit. Donec iaculis ornare ante non suscipit. Donec vel enim commodo, ornare enim et, dapibus erat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Fusce fermentum massa elit, non congue velit semper vitae. Curabitur in nulla quis nulla viverra fermentum sed pulvinar eros. Proin ac velit id dui accumsan luctus pretium vel enim. Duis dolor mauris, pretium eget leo vitae, semper porta ipsum. Aliquam porta nulla vel sodales mattis. Vivamus rhoncus odio et fringilla posuere. ";

  late final TextEditingController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: content);
    scrollController = ScrollController();
  }
  
  void _toggleMode() {
    final offset = scrollController.offset;
    final maxScroll = scrollController.position.maxScrollExtent;

    final ratio = maxScroll == 0 ? 0 : offset / maxScroll;

    setState(() {
        editMode = !editMode;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
        final newMax = scrollController.position.maxScrollExtent;
        final target = newMax * ratio;

        scrollController.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          editMode
              ? Padding(
                  padding: EdgeInsetsGeometry.only(left: 16, right: 16),
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    scrollController: scrollController,
                    controller: controller,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                )
              : MdArea(
                  content: content,
                  selectionCallback: _toggleMode,
                  scrollController: scrollController,
                ),
          Positioned(
            bottom: 40,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                _toggleMode();
              },
              child: Icon(editMode ? Icons.visibility : Icons.edit),
            ),
          ),
        ],
      ),
    );
  }
}
