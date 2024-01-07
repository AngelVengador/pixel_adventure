import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({
    required this.levelName,
    required this.player,
  });
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer("Background");
    if (backgroundLayer == null) return;

    final backgroundColor =
        backgroundLayer.properties.getValue("BackgroundColor") ?? "Gray";

    final backgroundTile = BackgroundTile(
      color: backgroundColor,
      position: Vector2(0, 0),
    );

    add(backgroundTile);
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            break;
          case 'Saw':
            final saw = Saw(
                isVertical: spawnPoint.properties.getValue("isVertical"),
                offPos: spawnPoint.properties.getValue("offPos"),
                offNeg: spawnPoint.properties.getValue("offNeg"),
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(checkpoint);
            break;
          case 'Chicken':
            final chicken = Chicken(
              offPos: spawnPoint.properties.getValue("offPos"),
              offNeg: spawnPoint.properties.getValue("offNeg"),
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(chicken);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collitions');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        final platform = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
          isPlatform: (collision.class_ == "Platform"),
        );
        collisionBlocks.add(platform);
        add(platform);
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
