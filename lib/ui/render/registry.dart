import 'package:mycelium/ui/render/block_renderer.dart';
import 'package:mycelium/ui/render/header_renderer.dart';
import 'package:mycelium/ui/render/list_renderer.dart';

class BlockRegistry {
  final List<BlockRenderer> renderers = [
    // Not adding blockquote as it is a speacial renderer that can wrap markdown
    const HeaderRenderer(),
    const ListRenderer(),
  ];  
}
